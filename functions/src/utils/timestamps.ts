import {Timestamp} from "firebase-admin/firestore";

import {SyncState, SyncStatus} from "../models/sync.js";

/** Returns the current Firestore server timestamp. */
export function nowTimestamp(): Timestamp {
  return Timestamp.now();
}

/** Builds a SyncState object for successful syncs. */
export function buildSyncState(
  status: SyncStatus,
  ttlMs: number,
  lastError: string | null = null,
): SyncState {
  const now = nowTimestamp();
  return {
    status,
    lastSyncAt: status === "ok" ? now : null,
    lastError,
    nextSyncAt: status === "ok" ?
      Timestamp.fromMillis(now.toMillis() + ttlMs) :
      null,
  };
}

/** Returns true when cached data is still fresh. */
export function isCacheFresh(sync: SyncState | undefined): boolean {
  if (!sync || sync.status !== "ok" || !sync.nextSyncAt) {
    return false;
  }
  return sync.nextSyncAt.toMillis() > Date.now();
}

/** Returns true when a forced sync is allowed (respects minimum interval). */
export function canForceSync(
  sync: SyncState | undefined,
  minIntervalMs: number,
): boolean {
  if (!sync?.lastSyncAt) {
    return true;
  }
  return Date.now() - sync.lastSyncAt.toMillis() >= minIntervalMs;
}
