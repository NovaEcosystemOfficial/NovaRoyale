import {describe, expect, it, jest} from "@jest/globals";

import {ClashRoyaleClient} from "../clashRoyale/client.js";
import {ClashRoyaleApiError} from "../clashRoyale/errors.js";

describe("ClashRoyaleClient", () => {
  const mockPlayer = {
    tag: "#ABC123",
    name: "TestPlayer",
    expLevel: 14,
    trophies: 6500,
    bestTrophies: 7000,
    wins: 1000,
    losses: 500,
    battleCount: 1500,
    threeCrownWins: 400,
    challengeCardsWon: 0,
    challengeMaxWins: 0,
    tournamentCardsWon: 0,
    tournamentBattleCount: 0,
    donations: 100,
    donationsReceived: 50,
    totalDonations: 100,
    warDayWins: 10,
    clanCardsCollected: 0,
  };

  it("sends Authorization header and returns player data", async () => {
    const fetchFn = jest.fn<typeof fetch>().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => mockPlayer,
    } as Response);

    const client = new ClashRoyaleClient({
      apiKey: "test-api-key",
      fetchFn,
    });

    const result = await client.getPlayer("%23ABC123");

    expect(result).toEqual(mockPlayer);
    expect(fetchFn).toHaveBeenCalledWith(
      "https://api.clashroyale.com/v1/players/%23ABC123",
      expect.objectContaining({
        method: "GET",
        headers: expect.objectContaining({
          Authorization: "Bearer test-api-key",
        }),
      }),
    );
  });

  it("throws ClashRoyaleApiError on 404", async () => {
    const fetchFn = jest.fn<typeof fetch>().mockResolvedValue({
      ok: false,
      status: 404,
      json: async () => ({reason: "notFound"}),
    } as Response);

    const client = new ClashRoyaleClient({
      apiKey: "test-api-key",
      fetchFn,
    });

    await expect(client.getPlayer("%23NOTFOUND")).rejects.toBeInstanceOf(
      ClashRoyaleApiError,
    );
  });

  it("throws ClashRoyaleApiError on 429 rate limit", async () => {
    const fetchFn = jest.fn<typeof fetch>().mockResolvedValue({
      ok: false,
      status: 429,
      json: async () => ({reason: "rateLimited"}),
    } as Response);

    const client = new ClashRoyaleClient({
      apiKey: "test-api-key",
      fetchFn,
    });

    await expect(client.getPlayer("%23ABC123")).rejects.toMatchObject({
      statusCode: 429,
    });
  });
});
