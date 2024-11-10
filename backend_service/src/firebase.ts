// firebase.ts
import * as admin from "firebase-admin";

let db: FirebaseFirestore.Firestore | null = null;

export function initializeFirebase() {
  // Firebase가 이미 초기화되었는지 확인
  if (!admin.apps.length) {
    admin.initializeApp();
  }

  // Firestore가 초기화되지 않은 경우에만 설정 적용
  if (!db) {
    db = admin.firestore();
    db.settings({
      host: "asia-northeast3-firestore.googleapis.com",
      ssl: true,
    });
  }

  return { admin, db };
}
