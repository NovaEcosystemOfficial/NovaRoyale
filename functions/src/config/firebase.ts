import {getApps, initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

/**
 * Lazily initializes Firebase Admin SDK.
 * Safe to call multiple times.
 */
export function getAdminFirestore() {
  if (getApps().length === 0) {
    initializeApp();
  }
  return getFirestore();
}
