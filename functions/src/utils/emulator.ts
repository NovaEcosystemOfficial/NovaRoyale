/**
 * True only when running inside the Firebase Functions emulator.
 * Never true in production Cloud Functions.
 */
export function isFunctionsEmulator(): boolean {
  return process.env.FUNCTIONS_EMULATOR === "true";
}

const EMULATOR_UID_PATTERN = /^[a-zA-Z0-9_-]{6,128}$/;

/**
 * Optional emulator-only fallback UID.
 *
 * Enabled ONLY when:
 * - FUNCTIONS_EMULATOR=true
 * - EMULATOR_AUTH_UID is explicitly set
 *
 * Prefer Auth Emulator tokens for local testing.
 * Never active in production.
 */
export function resolveEmulatorFallbackUid(): string | null {
  if (!isFunctionsEmulator()) {
    return null;
  }

  const configured = process.env.EMULATOR_AUTH_UID?.trim();
  if (!configured) {
    return null;
  }

  if (!EMULATOR_UID_PATTERN.test(configured)) {
    return null;
  }

  return configured;
}
