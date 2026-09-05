import {defineSecret} from "firebase-functions/params";

/**
 * Clash Royale API key — server-side only.
 * Set via: firebase functions:secrets:set CLASH_ROYALE_API_KEY
 * Local emulator: functions/.secret.local
 */
export const clashRoyaleApiKey = defineSecret("CLASH_ROYALE_API_KEY");
