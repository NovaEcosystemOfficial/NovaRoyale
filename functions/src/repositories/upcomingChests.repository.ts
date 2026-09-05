import {COLLECTIONS, DOC_IDS} from "../config/constants.js";
import {getAdminFirestore} from "../config/firebase.js";
import {CrApiChestItem} from "../models/api/clashRoyale.js";
import {SyncState} from "../models/sync.js";
import {UpcomingChestsDocument} from "../models/upcomingChests.js";
import {nowTimestamp} from "../utils/timestamps.js";

export class UpcomingChestsRepository {
  private readonly db = getAdminFirestore();

  private docRef(tagId: string) {
    return this.db
      .collection(COLLECTIONS.players)
      .doc(tagId)
      .collection(COLLECTIONS.upcomingChests)
      .doc(DOC_IDS.upcomingChestsCurrent);
  }

  async get(tagId: string): Promise<UpcomingChestsDocument | null> {
    const snap = await this.docRef(tagId).get();
    if (!snap.exists) {
      return null;
    }
    return snap.data() as UpcomingChestsDocument;
  }

  async upsert(
    tagId: string,
    playerTag: string,
    items: CrApiChestItem[],
    sync: SyncState,
  ): Promise<void> {
    const doc: UpcomingChestsDocument = {
      playerTag,
      items,
      sync,
      updatedAt: sync.lastSyncAt ?? nowTimestamp(),
    };
    await this.docRef(tagId).set(doc);
  }
}
