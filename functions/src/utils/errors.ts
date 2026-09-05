import {HttpsError} from "firebase-functions/v2/https";

import {ClashRoyaleApiError} from "../clashRoyale/errors.js";
import {resolveEmulatorFallbackUid} from "./emulator.js";

/** Maps domain errors to Firebase callable HttpsError instances. */
export function toHttpsError(error: unknown): HttpsError {
  if (error instanceof HttpsError) {
    return error;
  }

  if (error instanceof ClashRoyaleApiError) {
    if (error.statusCode === 404) {
      return new HttpsError("not-found", error.message);
    }
    if (error.statusCode === 403) {
      return new HttpsError(
        "permission-denied",
        "Clash Royale API access denied.",
      );
    }
    if (error.statusCode === 429) {
      return new HttpsError(
        "resource-exhausted",
        "Clash Royale API rate limit exceeded.",
      );
    }
    if (error.statusCode >= 500) {
      return new HttpsError(
        "unavailable",
        "Clash Royale API is temporarily unavailable.",
      );
    }
    return new HttpsError("internal", error.message);
  }

  if (error instanceof Error) {
    if (error.message.includes("Invalid player tag")) {
      return new HttpsError("invalid-argument", error.message);
    }
    if (error.message.includes("should not be an empty string")) {
      return new HttpsError(
        "invalid-argument",
        "Firestore rejected a document with an empty map key or path segment.",
      );
    }
    return new HttpsError("internal", error.message);
  }

  return new HttpsError("internal", "An unexpected error occurred.");
}

/**
 * Resolves the caller UID.
 *
 * Priority:
 * 1. Firebase Auth identity on the request (production + Auth Emulator)
 * 2. Explicit EMULATOR_AUTH_UID only when FUNCTIONS_EMULATOR=true
 *    (opt-in local fallback — never used in production)
 */
export function requireAuth(uid: string | undefined): string {
  if (uid) {
    return uid;
  }

  const emulatorUid = resolveEmulatorFallbackUid();
  if (emulatorUid) {
    return emulatorUid;
  }

  throw new HttpsError("unauthenticated", "Authentication required.");
}
