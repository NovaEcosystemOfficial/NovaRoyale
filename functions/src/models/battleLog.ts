import {Timestamp} from "firebase-admin/firestore";

import {CrApiBattle} from "./api/clashRoyale.js";
import {SyncState} from "./sync.js";

/** Single battle entry cached under a player. */
export interface BattleLogDocument {
  battleTime: string;
  type: string;
  raw: CrApiBattle;
  syncedAt: Timestamp;
}

/** Summary doc tracking battle log sync for a player. */
export interface BattleLogSyncDocument {
  playerTag: string;
  count: number;
  sync: SyncState;
  updatedAt: Timestamp;
}
