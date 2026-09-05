#!/usr/bin/env node
/**
 * Local emulator smoke test:
 *   Auth Emulator → syncPlayer(#29G9Q92RL) → getPlayer → Clash Royale API
 *
 * Prerequisites:
 *   1. Java JDK 21+ (required by Firestore Emulator)
 *   2. Terminal 1: npm run serve   (auth + functions + firestore)
 *   3. functions/.secret.local with CLASH_ROYALE_API_KEY
 *   4. npm run build
 *
 * Usage (from functions/):
 *   npm run test:emulator:getPlayer
 */

import {initializeApp} from "firebase/app";
import {connectAuthEmulator, getAuth, signInAnonymously} from "firebase/auth";
import {
  connectFunctionsEmulator,
  getFunctions,
  httpsCallable,
} from "firebase/functions";

const PROJECT_ID = "novaroyale-b5f5a";
const REGION = "europe-west1";
const PLAYER_TAG = "#29G9Q92RL";

const AUTH_HOST = process.env.FIREBASE_AUTH_EMULATOR_HOST ?? "127.0.0.1:9099";
const FUNCTIONS_HOST = process.env.FUNCTIONS_EMULATOR_HOST ?? "127.0.0.1";
const FUNCTIONS_PORT = Number(process.env.FUNCTIONS_EMULATOR_PORT ?? "5001");
const FIRESTORE_HOST =
  process.env.FIRESTORE_EMULATOR_HOST ?? "127.0.0.1:8080";

const START_HINT =
  "Start ALL emulators with: cd functions && npm run serve\n" +
  "Required: auth (9099) + functions (5001) + firestore (8080)\n" +
  "Do NOT use: firebase emulators:start --only functions";

async function assertPortOpen(label, hostPort, extraHint = "") {
  const url = hostPort.includes("://") ?
    hostPort :
    `http://${hostPort}/`;

  try {
    await fetch(url, {method: "GET"});
  } catch (error) {
    throw new Error(
      `${label} is not reachable at ${hostPort}.\n` +
      `${START_HINT}` +
      (extraHint ? `\n${extraHint}` : "") +
      `\nCause: ${error instanceof Error ? error.message : String(error)}`,
    );
  }
}

async function assertEmulatorsReady() {
  console.log("Checking emulators...");
  await assertPortOpen(
    "Auth Emulator",
    AUTH_HOST,
    "Without Auth, callables cannot receive a real request.auth identity.",
  );
  await assertPortOpen(
    "Functions Emulator",
    `${FUNCTIONS_HOST}:${FUNCTIONS_PORT}`,
  );
  await assertPortOpen(
    "Firestore Emulator",
    FIRESTORE_HOST,
    "Without Firestore Emulator, Admin SDK hits production and often returns 5 NOT_FOUND.\n" +
    "Firestore Emulator also requires Java (java -version).",
  );
  console.log("Auth / Functions / Firestore emulators are reachable.");
}

async function main() {
  console.log("NovaRoyale emulator smoke test");
  console.log(`Player tag: ${PLAYER_TAG}`);

  await assertEmulatorsReady();

  const app = initializeApp({
    projectId: PROJECT_ID,
    // Auth Emulator accepts any non-empty API key.
    apiKey: "novaroyale-emulator-fake-key",
    appId: "1:1234567890:web:emulator",
  });

  const auth = getAuth(app);
  connectAuthEmulator(auth, `http://${AUTH_HOST}`, {disableWarnings: true});

  const functions = getFunctions(app, REGION);
  connectFunctionsEmulator(functions, FUNCTIONS_HOST, FUNCTIONS_PORT);

  console.log("Signing in via Auth Emulator (anonymous)...");
  const credential = await signInAnonymously(auth);
  const uid = credential.user.uid;
  const idToken = await credential.user.getIdToken();

  if (!uid || !idToken) {
    throw new Error("Auth Emulator sign-in did not return uid/idToken.");
  }

  console.log(`Auth Emulator identity: ${uid}`);
  console.log(`ID token acquired (${idToken.slice(0, 16)}...)`);

  const syncPlayer = httpsCallable(functions, "syncPlayer");
  const getPlayer = httpsCallable(functions, "getPlayer");

  console.log("Calling syncPlayer...");
  const syncResponse = await syncPlayer({
    playerTag: PLAYER_TAG,
    forceRefresh: true,
  });
  const syncResult = syncResponse.data;

  if (syncResponse.data == null) {
    throw new Error("syncPlayer returned empty data.");
  }

  console.log(
    JSON.stringify(
      {
        synced: syncResult.synced,
        fromCache: syncResult.fromCache,
        tag: syncResult.player?.tag,
        name: syncResult.player?.name,
        trophies: syncResult.player?.trophies,
      },
      null,
      2,
    ),
  );

  console.log("Calling getPlayer...");
  const getResponse = await getPlayer({});
  const getResult = getResponse.data;
  console.log(
    JSON.stringify(
      {
        synced: getResult.synced,
        fromCache: getResult.fromCache,
        tag: getResult.player?.tag,
        name: getResult.player?.name,
        trophies: getResult.player?.trophies,
        arena: getResult.player?.arenaName,
      },
      null,
      2,
    ),
  );

  if (getResult.player?.tag !== PLAYER_TAG) {
    throw new Error(
      `Unexpected player tag: ${getResult.player?.tag} (expected ${PLAYER_TAG})`,
    );
  }

  if (!getResult.player?.name) {
    throw new Error(
      "getPlayer returned no player name — Clash Royale API sync likely failed.",
    );
  }

  console.log(
    "OK — Auth Emulator → syncPlayer → getPlayer → Clash Royale API.",
  );
}

main().catch((error) => {
  const message = error instanceof Error ? error.message : String(error);
  console.error(message);
  if (error && typeof error === "object" && "code" in error) {
    console.error(`code: ${error.code}`);
  }
  process.exitCode = 1;
});
