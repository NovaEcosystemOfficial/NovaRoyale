import {logger} from "firebase-functions";

import {COLLECTIONS} from "../config/constants.js";
import {getAdminFirestore} from "../config/firebase.js";
import {PlayerDocument} from "../models/player.js";
import {
  SyncMetadataDocument,
  SyncResourceType,
  SyncState,
} from "../models/sync.js";
import {sanitizeForFirestore} from "../utils/firestoreSanitize.js";
import {nowTimestamp} from "../utils/timestamps.js";

export class PlayerRepository {
  private readonly db = getAdminFirestore();

  private collection() {
    return this.db.collection(COLLECTIONS.players);
  }

  async getByTagId(tagId: string): Promise<PlayerDocument | null> {
    if (!tagId) {
      throw new Error("player tagId must not be empty.");
    }
    const snap = await this.collection().doc(tagId).get();
    if (!snap.exists) {
      return null;
    }
    return snap.data() as PlayerDocument;
  }

  async upsert(tagId: string, data: PlayerDocument): Promise<void> {
    if (!tagId) {
      throw new Error("player tagId must not be empty.");
    }

    const {value: safeData, removedEmptyKeys} = sanitizeForFirestore(data);
    if (removedEmptyKeys.length > 0) {
      logger.warn("PlayerRepository.upsert stripped empty Firestore map keys", {
        tagId,
        removedCount: removedEmptyKeys.length,
        paths: removedEmptyKeys.map((hit) => hit.path).slice(0, 20),
      });
    }

    await this.collection().doc(tagId).set(safeData, {merge: true});
  }
}

export class SyncMetadataRepository {
  private readonly db = getAdminFirestore();

  private collection() {
    return this.db.collection(COLLECTIONS.syncMetadata);
  }

  async get(tagId: string): Promise<SyncMetadataDocument | null> {
    if (!tagId) {
      throw new Error("player tagId must not be empty.");
    }
    const snap = await this.collection().doc(tagId).get();
    if (!snap.exists) {
      return null;
    }
    return snap.data() as SyncMetadataDocument;
  }

  async updateResource(
    tagId: string,
    playerTag: string,
    resource: SyncResourceType,
    state: SyncState,
  ): Promise<void> {
    if (!tagId) {
      throw new Error("player tagId must not be empty.");
    }

    const ref = this.collection().doc(tagId);
    const existing = await ref.get();
    const resources = existing.exists ?
      (existing.data() as SyncMetadataDocument).resources :
      {};

    await ref.set({
      playerTag,
      resources: {...resources, [resource]: state},
      updatedAt: nowTimestamp(),
    }, {merge: true});
  }
}
