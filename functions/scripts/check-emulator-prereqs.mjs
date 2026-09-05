#!/usr/bin/env node
/**
 * Verifies local prerequisites before starting Firebase emulators.
 * Firestore Emulator requires a Java runtime on the host PATH.
 */

import {spawnSync} from "node:child_process";

function hasJava() {
  const result = spawnSync("java", ["-version"], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  return result.status === 0;
}

if (!hasJava()) {
  console.error(`
Firestore Emulator requires Java, but no Java runtime was found on PATH.

Install a JDK 21+ (example):
  brew install --cask temurin@21

Then verify:
  java -version

Finally start emulators with ALL three services:
  cd functions && npm run serve

Do NOT use: firebase emulators:start --only functions
(that skips Auth + Firestore and causes Auth fetch failed / 5 NOT_FOUND)
`);
  process.exit(1);
}

console.log("Java runtime detected — emulator prerequisites OK.");
