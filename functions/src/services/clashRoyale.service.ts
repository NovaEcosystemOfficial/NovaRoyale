import {ClashRoyaleClient} from "../clashRoyale/client.js";
import {
  CrApiBattle,
  CrApiCardsResponse,
  CrApiClan,
  CrApiPlayer,
  CrApiUpcomingChests,
} from "../models/api/clashRoyale.js";
import {NormalizedPlayerTag} from "../utils/playerTag.js";

/**
 * Service layer over ClashRoyaleClient.
 * Translates normalized tags into API calls and can be extended
 * with caching, retries, or circuit-breaking in the future.
 */
export class ClashRoyaleService {
  constructor(private readonly client: ClashRoyaleClient) {}

  getPlayer(tag: NormalizedPlayerTag): Promise<CrApiPlayer> {
    return this.client.getPlayer(tag.encodedTag);
  }

  getPlayerBattleLog(tag: NormalizedPlayerTag): Promise<CrApiBattle[]> {
    return this.client.getPlayerBattleLog(tag.encodedTag);
  }

  getPlayerUpcomingChests(tag: NormalizedPlayerTag): Promise<CrApiUpcomingChests> {
    return this.client.getPlayerUpcomingChests(tag.encodedTag);
  }

  getClan(tag: NormalizedPlayerTag): Promise<CrApiClan> {
    return this.client.getClan(tag.encodedTag);
  }

  getCards(): Promise<CrApiCardsResponse> {
    return this.client.getCards();
  }
}
