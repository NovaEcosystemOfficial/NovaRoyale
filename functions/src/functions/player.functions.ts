import {logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";

import {FUNCTIONS_REGION} from "../config/constants.js";
import {clashRoyaleApiKey} from "../config/secrets.js";
import {PlayerDocument} from "../models/player.js";
import {UserRepository} from "../repositories/user.repository.js";
import {createSyncService} from "../services/factory.js";
import {requireAuth, toHttpsError} from "../utils/errors.js";
import {normalizePlayerTag} from "../utils/playerTag.js";

const callableOptions = {
  region: FUNCTIONS_REGION,
  secrets: [clashRoyaleApiKey],
};

interface SyncPlayerRequest {
  playerTag: string;
  forceRefresh?: boolean;
}

interface GetPlayerRequest {
  forceRefresh?: boolean;
}

interface GetByTagRequest {
  playerTag?: string;
  forceRefresh?: boolean;
}

/**
 * Links a player tag to the authenticated user and syncs profile data.
 */
export const syncPlayer = onCall(callableOptions, async (request) => {
  try {
    const uid = requireAuth(request.auth?.uid);
    const data = request.data as SyncPlayerRequest;

    if (!data?.playerTag || typeof data.playerTag !== "string") {
      throw new HttpsError("invalid-argument", "playerTag is required.");
    }

    const syncService = createSyncService();
    const result = await syncService.linkAndSyncPlayer(
      uid,
      data.playerTag,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return {
      player: serializePlayer(result.player),
      synced: result.synced,
      fromCache: result.fromCache,
    };
  } catch (error) {
    logger.error("syncPlayer failed", error);
    throw toHttpsError(error);
  }
});

/**
 * Returns the cached or freshly synced player profile for the linked user.
 */
export const getPlayer = onCall(callableOptions, async (request) => {
  try {
    const uid = requireAuth(request.auth?.uid);
    const data = (request.data ?? {}) as GetPlayerRequest;

    // Cheap link check first so first-launch clients get a clear
    // failed-precondition instead of a generic INTERNAL.
    const user = await new UserRepository().getByUid(uid);
    if (!user?.playerTag) {
      throw new HttpsError(
        "failed-precondition",
        "No player tag linked. Call syncPlayer first.",
      );
    }

    const syncService = createSyncService();
    const result = await syncService.getPlayerForUser(
      uid,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return {
      player: serializePlayer(result.player),
      synced: result.synced,
      fromCache: result.fromCache,
    };
  } catch (error) {
    logger.error("getPlayer failed", error);
    throw toHttpsError(error);
  }
});

/**
 * Returns battle log entries for the linked or specified player tag.
 */
export const getBattleLog = onCall(callableOptions, async (request) => {
  try {
    const uid = requireAuth(request.auth?.uid);
    const data = (request.data ?? {}) as GetByTagRequest;

    const syncService = createSyncService();
    const tag = await resolvePlayerTag(uid, data.playerTag);
    const result = await syncService.getBattleLog(
      tag,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return result;
  } catch (error) {
    logger.error("getBattleLog failed", error);
    throw toHttpsError(error);
  }
});

/**
 * Returns the upcoming chest queue for the linked or specified player tag.
 */
export const getUpcomingChests = onCall(callableOptions, async (request) => {
  try {
    const uid = requireAuth(request.auth?.uid);
    const data = (request.data ?? {}) as GetByTagRequest;

    const syncService = createSyncService();
    const tag = await resolvePlayerTag(uid, data.playerTag);
    const result = await syncService.getUpcomingChests(
      tag,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return result;
  } catch (error) {
    logger.error("getUpcomingChests failed", error);
    throw toHttpsError(error);
  }
});

async function resolvePlayerTag(
  uid: string,
  playerTagInput: string | undefined,
) {
  if (playerTagInput) {
    return normalizePlayerTag(playerTagInput);
  }

  const user = await new UserRepository().getByUid(uid);
  if (!user?.playerTag) {
    throw new HttpsError(
      "failed-precondition",
      "No player tag linked. Call syncPlayer first.",
    );
  }
  return normalizePlayerTag(user.playerTag);
}

/** Strip Firestore Timestamps / raw blob so callables always JSON-serialize. */
function serializePlayer(player: PlayerDocument) {
  return {
    tag: player.tag,
    name: player.name,
    expLevel: player.expLevel,
    trophies: player.trophies,
    bestTrophies: player.bestTrophies,
    wins: player.wins,
    losses: player.losses,
    battleCount: player.battleCount,
    clanTag: player.clanTag ?? null,
    clanName: player.clanName ?? null,
    arenaId: player.arenaId ?? null,
    arenaName: player.arenaName ?? null,
    role: player.role ?? null,
    donations: player.donations,
    donationsReceived: player.donationsReceived,
    raw: player.raw ?? null,
  };
}
