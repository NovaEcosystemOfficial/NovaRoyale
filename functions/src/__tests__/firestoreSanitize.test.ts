import {describe, expect, it} from "@jest/globals";

import {
  findEmptyMapKeys,
  sanitizeForFirestore,
  stripEmptyMapKeys,
} from "../utils/firestoreSanitize.js";

describe("firestoreSanitize", () => {
  it("detects empty map keys nested under badges.iconUrls", () => {
    const payload = {
      tag: "#29G9Q92RL",
      badges: [
        {
          name: "Classic12Wins",
          iconUrls: {
            "": "https://example.com/empty-key.png",
            large: "https://example.com/large.png",
          },
        },
      ],
    };

    const hits = findEmptyMapKeys(payload);
    expect(hits).toEqual([
      {path: '$["badges"][0]["iconUrls"][""]'},
    ]);
  });

  it("strips empty map keys while preserving valid keys", () => {
    const payload = {
      badges: [
        {
          iconUrls: {
            "": "https://example.com/empty-key.png",
            large: "https://example.com/large.png",
          },
        },
      ],
    };

    expect(stripEmptyMapKeys(payload)).toEqual({
      badges: [
        {
          iconUrls: {
            large: "https://example.com/large.png",
          },
        },
      ],
    });
  });

  it("sanitizeForFirestore reports removals and returns clean data", () => {
    const payload = {
      raw: {
        cards: [{iconUrls: {"": "x", medium: "y"}}],
      },
    };

    const result = sanitizeForFirestore(payload);
    expect(result.removedEmptyKeys).toHaveLength(1);
    expect(result.value).toEqual({
      raw: {
        cards: [{iconUrls: {medium: "y"}}],
      },
    });
  });

  it("leaves payloads without empty keys unchanged", () => {
    const payload = {name: "Player", iconUrls: {medium: "ok"}};
    const result = sanitizeForFirestore(payload);
    expect(result.removedEmptyKeys).toEqual([]);
    expect(result.value).toBe(payload);
  });
});
