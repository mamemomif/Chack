// firebase.ts
import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";

let db: FirebaseFirestore.Firestore;

export function initializeFirebase() {
  if (!admin.apps.length) {
    admin.initializeApp();
    logger.info("[Firebase] Firebase 초기화 완료");
  }

  if (!db) {
    db = admin.firestore();
    logger.info("[Firebase] Firestore 연결 완료");
  }

  return { admin, db };
}
