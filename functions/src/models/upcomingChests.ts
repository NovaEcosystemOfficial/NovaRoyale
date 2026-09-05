import {Timestamp} from "firebase-admin/firestore";

import {CrApiChestItem} from "./api/clashRoyale.js";
import {SyncState} from "./sync.js";

/** Cached upcoming chest queue for a player. */
export interface UpcomingChestsDocument {
  playerTag: string;
  items: CrApiChestItem[];
  sync: SyncState;
  updatedAt: Timestamp;
}
