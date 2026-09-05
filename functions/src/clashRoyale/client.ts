import {CLASH_ROYALE_API_BASE_URL} from "../config/constants.js";
import {
  CrApiBattle,
  CrApiCardsResponse,
  CrApiClan,
  CrApiClanMember,
  CrApiPlayer,
  CrApiUpcomingChests,
} from "../models/api/clashRoyale.js";
import {CR_ENDPOINTS} from "./endpoints.js";
import {ClashRoyaleApiError} from "./errors.js";

export interface ClashRoyaleClientOptions {
  apiKey: string;
  baseUrl?: string;
  fetchFn?: typeof fetch;
}

type HttpMethod = "GET";

/**
 * Centralized HTTP client for the Clash Royale API.
 * All external API access must go through this class.
 */
export class ClashRoyaleClient {
  private readonly apiKey: string;
  private readonly baseUrl: string;
  private readonly fetchFn: typeof fetch;

  constructor(options: ClashRoyaleClientOptions) {
    this.apiKey = options.apiKey;
    this.baseUrl = options.baseUrl ?? CLASH_ROYALE_API_BASE_URL;
    this.fetchFn = options.fetchFn ?? fetch;
  }

  async getPlayer(encodedTag: string): Promise<CrApiPlayer> {
    return this.get<CrApiPlayer>(CR_ENDPOINTS.player(encodedTag));
  }

  async getPlayerBattleLog(encodedTag: string): Promise<CrApiBattle[]> {
    return this.get<CrApiBattle[]>(CR_ENDPOINTS.playerBattleLog(encodedTag));
  }

  async getPlayerUpcomingChests(encodedTag: string): Promise<CrApiUpcomingChests> {
    return this.get<CrApiUpcomingChests>(
      CR_ENDPOINTS.playerUpcomingChests(encodedTag),
    );
  }

  async getClan(encodedTag: string): Promise<CrApiClan> {
    return this.get<CrApiClan>(CR_ENDPOINTS.clan(encodedTag));
  }

  async getClanMembers(encodedTag: string): Promise<{items: CrApiClanMember[]}> {
    return this.get<{items: CrApiClanMember[]}>(
      CR_ENDPOINTS.clanMembers(encodedTag),
    );
  }

  async getCards(): Promise<CrApiCardsResponse> {
    return this.get<CrApiCardsResponse>(CR_ENDPOINTS.cards());
  }

  async getLocations(): Promise<unknown> {
    return this.get<unknown>(CR_ENDPOINTS.locations());
  }

  private async get<T>(path: string): Promise<T> {
    const url = `${this.baseUrl}${path}`;
    const response = await this.fetchFn(url, {
      method: "GET" as HttpMethod,
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        Accept: "application/json",
      },
    });

    if (!response.ok) {
      let reason: string | undefined;
      try {
        const body = await response.json() as {reason?: string; message?: string};
        reason = body.reason ?? body.message;
      } catch {
        // Response body may not be JSON
      }

      throw new ClashRoyaleApiError(
        response.status,
        reason ?? `Clash Royale API request failed (${response.status})`,
        reason,
      );
    }

    return response.json() as Promise<T>;
  }
}
