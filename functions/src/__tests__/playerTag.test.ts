import {describe, expect, it} from "@jest/globals";

import {isValidPlayerTag, normalizePlayerTag} from "../utils/playerTag.js";

describe("normalizePlayerTag", () => {
  it("adds # prefix and uppercases", () => {
    const result = normalizePlayerTag("9yc2pqv");
    expect(result.tag).toBe("#9YC2PQV");
    expect(result.tagId).toBe("9YC2PQV");
    expect(result.encodedTag).toBe("%239YC2PQV");
  });

  it("preserves existing # prefix", () => {
    const result = normalizePlayerTag("#2PP");
    expect(result.tag).toBe("#2PP");
    expect(result.tagId).toBe("2PP");
  });

  it("trims whitespace", () => {
    const result = normalizePlayerTag("  #9YC2PQV  ");
    expect(result.tag).toBe("#9YC2PQV");
  });

  it("rejects tags that are too short", () => {
    expect(() => normalizePlayerTag("2P")).toThrow("Invalid player tag");
  });

  it("rejects invalid characters", () => {
    expect(() => normalizePlayerTag("#ABC1O1")).toThrow("Invalid player tag");
    expect(isValidPlayerTag("#ABC1O1")).toBe(false);
  });

  it("accepts valid Supercell charset tags", () => {
    expect(isValidPlayerTag("#2PP")).toBe(true);
    expect(isValidPlayerTag("2PP")).toBe(true);
    expect(isValidPlayerTag("#0289PYLQGRJCUV")).toBe(true);
  });
});
