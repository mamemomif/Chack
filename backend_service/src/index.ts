import * as functions from "firebase-functions/v2";
import { fetchAndStoreHotBooks } from "./hotBooks";
import { fetchAndStoreLibraries } from "./fetchAndStoreLibraries";
import { initializeFirebase } from "./firebase";

// Firebase 초기화
initializeFirebase();

export const scheduledFetchHotBooks = functions.scheduler.onSchedule(
  {
    schedule: "every monday 01:00",
    timeZone: "Asia/Seoul",
  },
  async () => {
    console.log("주기적 연령대별 인기 도서 데이터 수집 및 Firestore 저장 작업 시작");
    await fetchAndStoreHotBooks();
    console.log("작업이 완료되었습니다.");
  }
);

export const manualFetchHotBooks = functions.https.onRequest(
  async (req, res) => {
    try {
      await fetchAndStoreHotBooks();
      res.status(200).json({
        success: true,
        message: "연령대별 인기 도서 데이터가 성공적으로 Firestore에 저장되었습니다.",
      });
    } catch (error) {
      console.error("데이터 수집 및 저장 오류:", error);
      res.status(500).json({
        success: false,
        message: "도서 데이터 수집에 실패했습니다.",
        error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
      });
    }
  }
);

// 수동 호출을 통한 도서관 정보 저장
export const manualFetchLibraries = functions.https.onRequest(
  async (req, res) => {
    try {
      await fetchAndStoreLibraries();
      res.status(200).json({
        success: true,
        message: "도서관 정보가 성공적으로 Firestore에 저장되었습니다.",
      });
    } catch (error) {
      console.error("도서관 정보 저장 오류:", error);
      res.status(500).json({
        success: false,
        message: "도서관 정보 저장에 실패했습니다.",
        error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
      });
    }
  }
);
