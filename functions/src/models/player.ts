import {Timestamp} from "firebase-admin/firestore";

import {CrApiPlayer} from "./api/clashRoyale.js";
import {SyncState} from "./sync.js";

/** Cached player profile stored in Firestore. */
export interface PlayerDocument {
  tag: string;
  name: string;
  expLevel: number;
  trophies: number;
  bestTrophies: number;
  wins: number;
  losses: number;
  battleCount: number;
  clanTag?: string;
  clanName?: string;
  arenaId?: number;
  arenaName?: string;
  role?: string;
  donations: number;
  donationsReceived: number;
  raw: CrApiPlayer;
  sync: SyncState;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
