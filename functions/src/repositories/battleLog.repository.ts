import {CACHE_TTL_MS, COLLECTIONS} from "../config/constants.js";
import {getAdminFirestore} from "../config/firebase.js";
import {CrApiBattle} from "../models/api/clashRoyale.js";
import {BattleLogDocument, BattleLogSyncDocument} from "../models/battleLog.js";
import {SyncState} from "../models/sync.js";
import {sanitizeForFirestore} from "../utils/firestoreSanitize.js";
import {buildSyncState, nowTimestamp} from "../utils/timestamps.js";

export class BattleLogRepository {
  private readonly db = getAdminFirestore();

  private battlesCollection(tagId: string) {
    return this.db
      .collection(COLLECTIONS.players)
      .doc(tagId)
      .collection(COLLECTIONS.battleLogs);
  }

  private syncDocRef(tagId: string) {
    return this.db
      .collection(COLLECTIONS.players)
      .doc(tagId)
      .collection(COLLECTIONS.battleLogs)
      .doc("_sync");
  }

  async getSyncSummary(tagId: string): Promise<BattleLogSyncDocument | null> {
    const snap = await this.syncDocRef(tagId).get();
    if (!snap.exists) {
      return null;
    }
    return snap.data() as BattleLogSyncDocument;
  }

  async getBattles(tagId: string, limit = 25): Promise<BattleLogDocument[]> {
    const snap = await this.battlesCollection(tagId)
      .orderBy("battleTime", "desc")
      .limit(limit)
      .get();

    return snap.docs.map((doc) => doc.data() as BattleLogDocument);
  }

  async replaceBattles(
    tagId: string,
    playerTag: string,
    battles: CrApiBattle[],
  ): Promise<void> {
    const batch = this.db.batch();
    const collection = this.battlesCollection(tagId);

    const existing = await collection.get();
    for (const doc of existing.docs) {
      if (doc.id !== "_sync") {
        batch.delete(doc.ref);
      }
    }

    const syncedAt = nowTimestamp();
    for (const battle of battles) {
      const docId = battle.battleTime.replace(/\W/g, "");
      if (!docId) {
        throw new Error(
          `Invalid battleTime for Firestore document id: "${battle.battleTime}"`,
        );
      }
      const {value: safeBattle} = sanitizeForFirestore(battle);
      const doc: BattleLogDocument = {
        battleTime: battle.battleTime,
        type: battle.type,
        raw: safeBattle,
        syncedAt,
      };
      batch.set(collection.doc(docId), doc);
    }

    const sync: SyncState = buildSyncState("ok", CACHE_TTL_MS.battleLog);
    const syncDoc: BattleLogSyncDocument = {
      playerTag,
      count: battles.length,
      sync,
      updatedAt: syncedAt,
    };
    batch.set(this.syncDocRef(tagId), syncDoc);

    await batch.commit();
  }
}
