/** Clash Royale API base URL (Supercell). */
export const CLASH_ROYALE_API_BASE_URL = "https://api.clashroyale.com/v1";

/** Firebase Functions region — close to Firestore eur3. */
export const FUNCTIONS_REGION = "europe-west1";

/** Cache TTL values in milliseconds. */
export const CACHE_TTL_MS = {
  player: 5 * 60 * 1000,
  battleLog: 2 * 60 * 1000,
  upcomingChests: 15 * 60 * 1000,
  cards: 24 * 60 * 60 * 1000,
  clan: 10 * 60 * 1000,
} as const;

/** Minimum interval between forced API syncs per resource type. */
export const MIN_SYNC_INTERVAL_MS = {
  player: 60 * 1000,
  battleLog: 60 * 1000,
  upcomingChests: 5 * 60 * 1000,
} as const;

/** Firestore collection names. */
export const COLLECTIONS = {
  users: "users",
  players: "players",
  clans: "clans",
  cards: "cards",
  syncMetadata: "syncMetadata",
  battleLogs: "battleLogs",
  upcomingChests: "upcomingChests",
} as const;

/** Document IDs for singleton resources. */
export const DOC_IDS = {
  cardsGlobal: "global",
  upcomingChestsCurrent: "current",
} as const;
