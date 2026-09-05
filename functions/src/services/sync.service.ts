import {logger} from "firebase-functions";

import {CACHE_TTL_MS, MIN_SYNC_INTERVAL_MS} from "../config/constants.js";
import {CrApiPlayer} from "../models/api/clashRoyale.js";
import {PlayerDocument} from "../models/player.js";
import {SyncResourceType, SyncState} from "../models/sync.js";
import {BattleLogRepository} from "../repositories/battleLog.repository.js";
import {
  PlayerRepository,
  SyncMetadataRepository,
} from "../repositories/player.repository.js";
import {UpcomingChestsRepository} from "../repositories/upcomingChests.repository.js";
import {UserRepository} from "../repositories/user.repository.js";
import {sanitizeForFirestore} from "../utils/firestoreSanitize.js";
import {
  buildSyncState,
  canForceSync,
  isCacheFresh,
  nowTimestamp,
} from "../utils/timestamps.js";
import {NormalizedPlayerTag, normalizePlayerTag} from "../utils/playerTag.js";
import {ClashRoyaleService} from "./clashRoyale.service.js";

export interface GetPlayerOptions {
  forceRefresh?: boolean;
}

export interface SyncPlayerResult {
  player: PlayerDocument;
  synced: boolean;
  fromCache: boolean;
}

export interface GetBattleLogResult {
  battles: Array<{battleTime: string; type: string; raw: unknown}>;
  synced: boolean;
  fromCache: boolean;
}

export interface GetUpcomingChestsResult {
  items: Array<{index: number; name: string}>;
  synced: boolean;
  fromCache: boolean;
}

/**
 * Orchestrates sync between Clash Royale API and Firestore.
 * Enforces cache TTLs and minimum sync intervals to reduce API usage.
 */
export class SyncService {
  constructor(
    private readonly clashRoyale: ClashRoyaleService,
    private readonly playerRepo = new PlayerRepository(),
    private readonly battleLogRepo = new BattleLogRepository(),
    private readonly upcomingChestsRepo = new UpcomingChestsRepository(),
    private readonly syncMetadataRepo = new SyncMetadataRepository(),
    private readonly userRepo = new UserRepository(),
  ) {}

  async linkAndSyncPlayer(
    uid: string,
    playerTagInput: string,
    options: GetPlayerOptions = {},
  ): Promise<SyncPlayerResult> {
    const tag = normalizePlayerTag(playerTagInput);
    await this.userRepo.linkPlayerTag(uid, tag.tag, tag.tagId);
    return this.getPlayer(tag, options);
  }

  async getPlayerForUser(
    uid: string,
    options: GetPlayerOptions = {},
  ): Promise<SyncPlayerResult> {
    const user = await this.userRepo.getByUid(uid);
    if (!user?.playerTag) {
      throw new Error("No player tag linked. Call syncPlayer first.");
    }
    const tag = normalizePlayerTag(user.playerTag);
    return this.getPlayer(tag, options);
  }

  async getPlayer(
    tag: NormalizedPlayerTag,
    options: GetPlayerOptions = {},
  ): Promise<SyncPlayerResult> {
    const cached = await this.playerRepo.getByTagId(tag.tagId);

    if (
      cached &&
      isCacheFresh(cached.sync) &&
      !options.forceRefresh
    ) {
      return {player: cached, synced: false, fromCache: true};
    }

    if (
      cached &&
      !options.forceRefresh &&
      !canForceSync(cached.sync, MIN_SYNC_INTERVAL_MS.player)
    ) {
      return {player: cached, synced: false, fromCache: true};
    }

    try {
      const apiPlayer = await this.clashRoyale.getPlayer(tag);
      const player = this.mapPlayerDocument(tag, apiPlayer, cached);
      await this.playerRepo.upsert(tag.tagId, player);
      await this.syncMetadataRepo.updateResource(
        tag.tagId,
        tag.tag,
        "player",
        player.sync,
      );
      return {player, synced: true, fromCache: false};
    } catch (error) {
      await this.recordSyncError(tag, "player", error);
      if (cached) {
        return {player: cached, synced: false, fromCache: true};
      }
      throw error;
    }
  }

  async getBattleLog(
    tag: NormalizedPlayerTag,
    options: GetPlayerOptions = {},
  ): Promise<GetBattleLogResult> {
    const syncSummary = await this.battleLogRepo.getSyncSummary(tag.tagId);

    if (
      syncSummary &&
      isCacheFresh(syncSummary.sync) &&
      !options.forceRefresh
    ) {
      const battles = await this.battleLogRepo.getBattles(tag.tagId);
      return {
        battles: battles.map((b) => ({
          battleTime: b.battleTime,
          type: b.type,
          raw: b.raw,
        })),
        synced: false,
        fromCache: true,
      };
    }

    if (
      syncSummary &&
      !options.forceRefresh &&
      !canForceSync(syncSummary.sync, MIN_SYNC_INTERVAL_MS.battleLog)
    ) {
      const battles = await this.battleLogRepo.getBattles(tag.tagId);
      return {
        battles: battles.map((b) => ({
          battleTime: b.battleTime,
          type: b.type,
          raw: b.raw,
        })),
        synced: false,
        fromCache: true,
      };
    }

    try {
      const apiBattles = await this.clashRoyale.getPlayerBattleLog(tag);
      await this.battleLogRepo.replaceBattles(tag.tagId, tag.tag, apiBattles);
      const sync = buildSyncState("ok", CACHE_TTL_MS.battleLog);
      await this.syncMetadataRepo.updateResource(
        tag.tagId,
        tag.tag,
        "battleLog",
        sync,
      );
      return {
        battles: apiBattles.map((b) => ({
          battleTime: b.battleTime,
          type: b.type,
          raw: b,
        })),
        synced: true,
        fromCache: false,
      };
    } catch (error) {
      await this.recordSyncError(tag, "battleLog", error);
      const battles = await this.battleLogRepo.getBattles(tag.tagId);
      if (battles.length > 0) {
        return {
          battles: battles.map((b) => ({
            battleTime: b.battleTime,
            type: b.type,
            raw: b.raw,
          })),
          synced: false,
          fromCache: true,
        };
      }
      throw error;
    }
  }

  async getUpcomingChests(
    tag: NormalizedPlayerTag,
    options: GetPlayerOptions = {},
  ): Promise<GetUpcomingChestsResult> {
    const cached = await this.upcomingChestsRepo.get(tag.tagId);

    if (cached && isCacheFresh(cached.sync) && !options.forceRefresh) {
      return {items: cached.items, synced: false, fromCache: true};
    }

    if (
      cached &&
      !options.forceRefresh &&
      !canForceSync(cached.sync, MIN_SYNC_INTERVAL_MS.upcomingChests)
    ) {
      return {items: cached.items, synced: false, fromCache: true};
    }

    try {
      const apiChests = await this.clashRoyale.getPlayerUpcomingChests(tag);
      const sync = buildSyncState("ok", CACHE_TTL_MS.upcomingChests);
      await this.upcomingChestsRepo.upsert(
        tag.tagId,
        tag.tag,
        apiChests.items,
        sync,
      );
      await this.syncMetadataRepo.updateResource(
        tag.tagId,
        tag.tag,
        "upcomingChests",
        sync,
      );
      return {items: apiChests.items, synced: true, fromCache: false};
    } catch (error) {
      await this.recordSyncError(tag, "upcomingChests", error);
      if (cached) {
        return {items: cached.items, synced: false, fromCache: true};
      }
      throw error;
    }
  }

  private mapPlayerDocument(
    tag: NormalizedPlayerTag,
    api: CrApiPlayer,
    existing: PlayerDocument | null,
  ): PlayerDocument {
    const now = nowTimestamp();
    const sync = buildSyncState("ok", CACHE_TTL_MS.player);

    // Clash Royale API may include empty-string map keys (e.g. badges[].iconUrls[""]).
    // Firestore rejects those keys with: Element at index 0 should not be an empty string [600].
    const {value: safeRaw, removedEmptyKeys} = sanitizeForFirestore(api);
    if (removedEmptyKeys.length > 0) {
      logger.warn("Stripped empty Firestore map keys from Clash Royale player payload", {
        playerTag: tag.tag,
        removedCount: removedEmptyKeys.length,
        paths: removedEmptyKeys.map((hit) => hit.path).slice(0, 20),
      });
    }

    return {
      tag: tag.tag,
      name: api.name,
      expLevel: api.expLevel,
      trophies: api.trophies,
      bestTrophies: api.bestTrophies,
      wins: api.wins,
      losses: api.losses,
      battleCount: api.battleCount,
      clanTag: api.clan?.tag,
      clanName: api.clan?.name,
      arenaId: api.arena?.id,
      arenaName: api.arena?.name,
      role: api.role,
      donations: api.donations,
      donationsReceived: api.donationsReceived,
      raw: safeRaw,
      sync,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    };
  }

  private async recordSyncError(
    tag: NormalizedPlayerTag,
    resource: SyncResourceType,
    error: unknown,
  ): Promise<void> {
    const message = error instanceof Error ? error.message : "Unknown sync error";
    const sync: SyncState = {
      status: "error",
      lastSyncAt: nowTimestamp(),
      lastError: message,
      nextSyncAt: null,
    };
    await this.syncMetadataRepo.updateResource(
      tag.tagId,
      tag.tag,
      resource,
      sync,
    );
  }
}
