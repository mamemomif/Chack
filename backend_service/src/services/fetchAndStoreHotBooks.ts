import axios from "axios";
import { initializeFirebase } from "../config/firebase";
import * as admin from "firebase-admin";
import { logger } from "firebase-functions/v2";
import {
  ApiConfig,
  Book,
  HotBooksDocument,
  HotBooksApiResponse,
  AgeGroup,
} from "../utils/types";

const API_URL = "http://data4library.kr/api/loanItemSrch";
const COLLECTION_NAME = "hotBooks";
const TIMEOUT = 30000;

const AGE_GROUPS: AgeGroup[] = [
  { code: "0", name: "영유아" },
  { code: "6", name: "유아" },
  { code: "8", name: "초등" },
  { code: "14", name: "청소년" },
  { code: "20", name: "20대" },
  { code: "30", name: "30대" },
  { code: "40", name: "40대" },
  { code: "50", name: "50대" },
  { code: "60", name: "60세 이상" },
];

function getDateRange() {
  const end = new Date();
  end.setDate(end.getDate() - 1);

  const start = new Date(end);
  start.setDate(start.getDate() - 7);

  return {
    startDt: start.toISOString().split("T")[0],
    endDt: end.toISOString().split("T")[0],
  };
}

export async function fetchAndStoreHotBooks(apiKey: string) {
  const config: ApiConfig = {
    libraryApiKey: apiKey,
    vworldApiKey: "",
  };

  if (!config.libraryApiKey) {
    throw new Error("LIBRARY_API_KEY가 설정되지 않았습니다.");
  }

  const { startDt, endDt } = getDateRange();
  logger.info(`[HotBooks] ${startDt} ~ ${endDt} 기간의 인기 도서 데이터 수집 시작`);

  const collectedData: Record<string, HotBooksDocument> = {};

  let db: admin.firestore.Firestore;
  try {
    const firebase = initializeFirebase();
    if (!firebase?.db) {
      throw new Error("[HotBooks] Firebase 초기화 실패");
    }
    db = firebase.db;
    logger.info("[HotBooks] Firebase 초기화 성공");
  } catch (error) {
    logger.error("[HotBooks] Firebase 초기화 에러:", error);
    throw error;
  }

  try {
    for (const ageGroup of AGE_GROUPS) {
      logger.info(`[HotBooks] ${ageGroup.name}(${ageGroup.code}) 데이터 요청`);

      try {
        const params = {
          authKey: config.libraryApiKey,
          startDt,
          endDt,
          age: ageGroup.code,
          format: "json",
          pageSize: 100,
        };

        logger.info(`[HotBooks] API 요청: ${API_URL} ${JSON.stringify(params)}`);

        const response = await axios.get<HotBooksApiResponse>(API_URL, {
          params,
          timeout: TIMEOUT,
        });

        logger.info(`[HotBooks] response: ${JSON.stringify(response.data)}`);

        const books: Book[] = response.data?.response?.docs?.map(({ doc }) => ({
          addition_symbol: doc.addition_symbol,
          authors: doc.authors,
          bookDtlUrl: doc.bookDtlUrl,
          bookImageURL: doc.bookImageURL,
          bookname: doc.bookname,
          class_nm: doc.class_nm,
          class_no: doc.class_no,
          isbn13: doc.isbn13,
          loan_count: Number(doc.loan_count),
          publication_year: doc.publication_year,
          publisher: doc.publisher,
          ranking: Number(doc.ranking),
          vol: doc.vol,
        })) || [];

        const documentData: HotBooksDocument = {
          ageGroupName: ageGroup.name,
          books,
          period: { startDt, endDt },
          updatedAt: admin.firestore.Timestamp.now(),
        };

        // 데이터 저장
        await db.collection(COLLECTION_NAME).doc(ageGroup.code).set(documentData);
        logger.info(`[HotBooks] ${ageGroup.name}: ${books.length}건 저장 완료`);
      } catch (error) {
        logger.error(`[HotBooks] ${ageGroup.name} 데이터 수집 실패:`, error);
      }

      await new Promise((resolve) => setTimeout(resolve, 5000));
    }

    logger.info("[HotBooks] 모든 연령대의 인기 도서 데이터 저장 완료");
    return collectedData;
  } catch (error) {
    logger.error("[HotBooks] 전체 처리 실패:", error);
    throw error;
  }
}
