/** Supercell tag charset — excludes ambiguous characters. */
const TAG_CHARSET = "0289PYLQGRJCUV";

const TAG_PATTERN = new RegExp(`^#?[${TAG_CHARSET}]{3,15}$`);

export interface NormalizedPlayerTag {
  /** Display tag with leading #, e.g. #ABC123 */
  tag: string;
  /** Firestore document ID — tag without #, uppercase */
  tagId: string;
  /** URL-encoded tag for API requests, e.g. %23ABC123 */
  encodedTag: string;
}

/**
 * Normalizes and validates a Clash Royale player or clan tag.
 * @throws {Error} if the tag format is invalid
 */
export function normalizePlayerTag(input: string): NormalizedPlayerTag {
  const trimmed = input.trim().toUpperCase();
  const withHash = trimmed.startsWith("#") ? trimmed : `#${trimmed}`;

  if (!TAG_PATTERN.test(withHash)) {
    throw new Error(
      "Invalid player tag. Use 3–15 characters from 0289PYLQGRJCUV.",
    );
  }

  const tagId = withHash.slice(1);

  return {
    tag: withHash,
    tagId,
    encodedTag: encodeURIComponent(withHash),
  };
}

/** Returns true when the input is a valid Clash Royale tag. */
export function isValidPlayerTag(input: string): boolean {
  try {
    normalizePlayerTag(input);
    return true;
  } catch {
    return false;
  }
}
