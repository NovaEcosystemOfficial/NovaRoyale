import {Timestamp} from "firebase-admin/firestore";

export type SyncResourceType =
  | "player"
  | "battleLog"
  | "upcomingChests"
  | "clan"
  | "cards";

export type SyncStatus = "ok" | "error" | "pending";

/** Per-resource sync state embedded in documents or syncMetadata. */
export interface SyncState {
  status: SyncStatus;
  lastSyncAt: Timestamp | null;
  lastError: string | null;
  nextSyncAt: Timestamp | null;
}

/** Top-level sync metadata document keyed by normalized player tag. */
export interface SyncMetadataDocument {
  playerTag: string;
  resources: Partial<Record<SyncResourceType, SyncState>>;
  updatedAt: Timestamp;
}
