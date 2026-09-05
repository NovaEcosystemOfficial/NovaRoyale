import {
  applicationDefault,
  getApps,
  initializeApp,
} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";

/**
 * Ensures the default Firebase Admin app exists.
 * Gen2 Cloud Run can miss auto-init; initialize explicitly with ADC + projectId.
 */
export function initAdminApp(): void {
  if (getApps().length > 0) {
    return;
  }

  const projectId =
    process.env.GCLOUD_PROJECT ||
    process.env.GCP_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    "novaroyale-b5f5a";

  initializeApp({
    credential: applicationDefault(),
    projectId,
  });
}

/** Lazily initializes Admin SDK and returns Firestore. */
export function getAdminFirestore() {
  initAdminApp();
  return getFirestore();
}

// Eager init when the module loads (Cloud Functions cold start).
initAdminApp();
