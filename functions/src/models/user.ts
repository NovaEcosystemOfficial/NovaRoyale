import {Timestamp} from "firebase-admin/firestore";

/** Companion app user profile — links Firebase Auth to a CR player tag. */
export interface UserDocument {
  uid: string;
  playerTag: string | null;
  playerTagId: string | null;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}
