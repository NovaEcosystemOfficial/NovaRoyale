/**
 * Official Clash Royale API.
 * Note: keys are IP-locked; Cloud Functions egress IPs are dynamic, so production
 * uses the RoyaleAPI community proxy (whitelist 45.79.218.79 on the key).
 */
export const CLASH_ROYALE_API_BASE_URL = "https://api.clashroyale.com/v1";

/**
 * Community proxy with a stable egress IP for Supercell key whitelisting.
 * @see https://docs.royaleapi.com/proxy.html
 */
export const CLASH_ROYALE_API_PROXY_BASE_URL = "https://proxy.royaleapi.dev/v1";

/** IP to whitelist on developer.clashroyale.com when using the RoyaleAPI proxy. */
export const CLASH_ROYALE_PROXY_WHITELIST_IP = "45.79.218.79";

/**
 * Base URL used by Cloud Functions.
 * Override with env CLASH_ROYALE_API_BASE_URL if needed.
 */
export function resolveClashRoyaleApiBaseUrl(): string {
  const fromEnv = process.env.CLASH_ROYALE_API_BASE_URL?.trim();
  if (fromEnv) {
    return fromEnv.replace(/\/$/, "");
  }
  // Default to proxy so a single fixed IP works from Firebase Functions.
  return CLASH_ROYALE_API_PROXY_BASE_URL;
}

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
