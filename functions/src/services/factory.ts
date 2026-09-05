import {ClashRoyaleClient} from "../clashRoyale/client.js";
import {clashRoyaleApiKey} from "../config/secrets.js";
import {ClashRoyaleService} from "../services/clashRoyale.service.js";
import {SyncService} from "../services/sync.service.js";

/** Builds service instances wired with the current API key. */
export function createSyncService(apiKey?: string): SyncService {
  const key = apiKey ?? clashRoyaleApiKey.value();
  if (!key) {
    throw new Error(
      "CLASH_ROYALE_API_KEY is not configured. " +
      "Set it via Firebase secrets or .secret.local for local development.",
    );
  }

  const client = new ClashRoyaleClient({apiKey: key});
  const clashRoyaleService = new ClashRoyaleService(client);
  return new SyncService(clashRoyaleService);
}
