/**
 * Firestore rejects map keys that are empty strings (error code 600):
 * "Element at index 0 should not be an empty string."
 *
 * Clash Royale API payloads (especially badges[].iconUrls) can include "".
 */

export interface EmptyMapKeyHit {
  path: string;
}

function isPlainObject(value: unknown): value is Record<string, unknown> {
  return (
    typeof value === "object" &&
    value !== null &&
    !Array.isArray(value) &&
    Object.getPrototypeOf(value) === Object.prototype
  );
}

/**
 * Recursively finds empty-string map keys in a JSON-like value.
 * Paths use JSON Pointer-ish notation for diagnostics (no secrets).
 */
export function findEmptyMapKeys(
  value: unknown,
  path = "$",
  hits: EmptyMapKeyHit[] = [],
): EmptyMapKeyHit[] {
  if (Array.isArray(value)) {
    value.forEach((item, index) => {
      findEmptyMapKeys(item, `${path}[${index}]`, hits);
    });
    return hits;
  }

  if (!isPlainObject(value)) {
    return hits;
  }

  for (const [key, child] of Object.entries(value)) {
    const childPath = `${path}[${JSON.stringify(key)}]`;
    if (key === "") {
      hits.push({path: childPath});
    }
    findEmptyMapKeys(child, childPath, hits);
  }

  return hits;
}

/**
 * Returns a deep copy with empty-string map keys removed.
 * Arrays and non-plain objects are preserved structurally.
 */
export function stripEmptyMapKeys<T>(value: T): T {
  return stripEmptyMapKeysInternal(value) as T;
}

function stripEmptyMapKeysInternal(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map((item) => stripEmptyMapKeysInternal(item));
  }

  if (!isPlainObject(value)) {
    return value;
  }

  const result: Record<string, unknown> = {};
  for (const [key, child] of Object.entries(value)) {
    if (key === "") {
      continue;
    }
    result[key] = stripEmptyMapKeysInternal(child);
  }
  return result;
}

/**
 * Sanitizes external JSON for Firestore writes.
 * Returns sanitized value and the empty-key paths that were removed.
 */
export function sanitizeForFirestore<T>(value: T): {
  value: T;
  removedEmptyKeys: EmptyMapKeyHit[];
} {
  const removedEmptyKeys = findEmptyMapKeys(value);
  if (removedEmptyKeys.length === 0) {
    return {value, removedEmptyKeys};
  }
  return {
    value: stripEmptyMapKeys(value),
    removedEmptyKeys,
  };
}
