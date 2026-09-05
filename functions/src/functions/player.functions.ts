import {onCall} from "firebase-functions/v2/https";

import {FUNCTIONS_REGION} from "../config/constants.js";
import {clashRoyaleApiKey} from "../config/secrets.js";
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
      throw new Error("playerTag is required.");
    }

    const syncService = createSyncService();
    const result = await syncService.linkAndSyncPlayer(
      uid,
      data.playerTag,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return {
      player: result.player,
      synced: result.synced,
      fromCache: result.fromCache,
    };
  } catch (error) {
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

    const syncService = createSyncService();
    const result = await syncService.getPlayerForUser(
      uid,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return {
      player: result.player,
      synced: result.synced,
      fromCache: result.fromCache,
    };
  } catch (error) {
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
    const tag = await resolvePlayerTag(uid, data.playerTag, syncService);
    const result = await syncService.getBattleLog(
      tag,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return result;
  } catch (error) {
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
    const tag = await resolvePlayerTag(uid, data.playerTag, syncService);
    const result = await syncService.getUpcomingChests(
      tag,
      {forceRefresh: data.forceRefresh ?? false},
    );

    return result;
  } catch (error) {
    throw toHttpsError(error);
  }
});

async function resolvePlayerTag(
  uid: string,
  playerTagInput: string | undefined,
  syncService: ReturnType<typeof createSyncService>,
) {
  if (playerTagInput) {
    return normalizePlayerTag(playerTagInput);
  }

  const result = await syncService.getPlayerForUser(uid);
  return normalizePlayerTag(result.player.tag);
}
