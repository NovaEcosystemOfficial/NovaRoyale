import {afterEach, describe, expect, it} from "@jest/globals";
import {HttpsError} from "firebase-functions/v2/https";

import {
  isFunctionsEmulator,
  resolveEmulatorFallbackUid,
} from "../utils/emulator.js";
import {requireAuth} from "../utils/errors.js";

describe("emulator auth helpers", () => {
  const originalEmulator = process.env.FUNCTIONS_EMULATOR;
  const originalUid = process.env.EMULATOR_AUTH_UID;

  afterEach(() => {
    if (originalEmulator === undefined) {
      delete process.env.FUNCTIONS_EMULATOR;
    } else {
      process.env.FUNCTIONS_EMULATOR = originalEmulator;
    }

    if (originalUid === undefined) {
      delete process.env.EMULATOR_AUTH_UID;
    } else {
      process.env.EMULATOR_AUTH_UID = originalUid;
    }
  });

  it("detects functions emulator from env", () => {
    delete process.env.FUNCTIONS_EMULATOR;
    expect(isFunctionsEmulator()).toBe(false);

    process.env.FUNCTIONS_EMULATOR = "true";
    expect(isFunctionsEmulator()).toBe(true);
  });

  it("returns no fallback outside the emulator", () => {
    delete process.env.FUNCTIONS_EMULATOR;
    process.env.EMULATOR_AUTH_UID = "custom-local-tester";
    expect(resolveEmulatorFallbackUid()).toBeNull();
  });

  it("returns no fallback in emulator without EMULATOR_AUTH_UID", () => {
    process.env.FUNCTIONS_EMULATOR = "true";
    delete process.env.EMULATOR_AUTH_UID;
    expect(resolveEmulatorFallbackUid()).toBeNull();
  });

  it("respects explicit EMULATOR_AUTH_UID in emulator", () => {
    process.env.FUNCTIONS_EMULATOR = "true";
    process.env.EMULATOR_AUTH_UID = "custom-local-tester";
    expect(resolveEmulatorFallbackUid()).toBe("custom-local-tester");
  });

  it("rejects invalid EMULATOR_AUTH_UID values", () => {
    process.env.FUNCTIONS_EMULATOR = "true";
    process.env.EMULATOR_AUTH_UID = "bad uid!";
    expect(resolveEmulatorFallbackUid()).toBeNull();
  });
});

describe("requireAuth", () => {
  const originalEmulator = process.env.FUNCTIONS_EMULATOR;
  const originalUid = process.env.EMULATOR_AUTH_UID;

  afterEach(() => {
    if (originalEmulator === undefined) {
      delete process.env.FUNCTIONS_EMULATOR;
    } else {
      process.env.FUNCTIONS_EMULATOR = originalEmulator;
    }

    if (originalUid === undefined) {
      delete process.env.EMULATOR_AUTH_UID;
    } else {
      process.env.EMULATOR_AUTH_UID = originalUid;
    }
  });

  it("prefers Firebase Auth UID when present", () => {
    process.env.FUNCTIONS_EMULATOR = "true";
    process.env.EMULATOR_AUTH_UID = "emulator-fallback";
    expect(requireAuth("real-user-123")).toBe("real-user-123");
  });

  it("rejects missing auth in production", () => {
    delete process.env.FUNCTIONS_EMULATOR;
    delete process.env.EMULATOR_AUTH_UID;

    try {
      requireAuth(undefined);
      throw new Error("expected requireAuth to throw");
    } catch (error) {
      expect(error).toBeInstanceOf(HttpsError);
      expect((error as HttpsError).code).toBe("unauthenticated");
    }
  });

  it("rejects missing auth in emulator without EMULATOR_AUTH_UID", () => {
    process.env.FUNCTIONS_EMULATOR = "true";
    delete process.env.EMULATOR_AUTH_UID;

    try {
      requireAuth(undefined);
      throw new Error("expected requireAuth to throw");
    } catch (error) {
      expect(error).toBeInstanceOf(HttpsError);
      expect((error as HttpsError).code).toBe("unauthenticated");
    }
  });

  it("allows explicit EMULATOR_AUTH_UID when auth is missing", () => {
    process.env.FUNCTIONS_EMULATOR = "true";
    process.env.EMULATOR_AUTH_UID = "novaroyale-emulator-user";
    expect(requireAuth(undefined)).toBe("novaroyale-emulator-user");
  });
});
