import {COLLECTIONS} from "../config/constants.js";
import {getAdminFirestore} from "../config/firebase.js";
import {UserDocument} from "../models/user.js";
import {nowTimestamp} from "../utils/timestamps.js";

export class UserRepository {
  private collection() {
    return getAdminFirestore().collection(COLLECTIONS.users);
  }

  async getByUid(uid: string): Promise<UserDocument | null> {
    const snap = await this.collection().doc(uid).get();
    if (!snap.exists) {
      return null;
    }
    return snap.data() as UserDocument;
  }

  async linkPlayerTag(
    uid: string,
    playerTag: string,
    playerTagId: string,
  ): Promise<UserDocument> {
    const ref = this.collection().doc(uid);
    const existing = await ref.get();
    const now = nowTimestamp();

    const doc: UserDocument = {
      uid,
      playerTag,
      playerTagId,
      createdAt: existing.exists ?
        (existing.data() as UserDocument).createdAt :
        now,
      updatedAt: now,
    };

    await ref.set(doc, {merge: true});
    return doc;
  }
}
