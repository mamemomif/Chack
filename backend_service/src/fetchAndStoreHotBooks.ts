// fetchAndStoreHotBooks.ts
import * as dotenv from "dotenv";
import { isAxiosError } from "axios";
import axios from "axios";
import { initializeFirebase } from "./firebase";
import * as admin from "firebase-admin";

dotenv.config();
const API_KEY = process.env.LIBRARY_DATANARU_API_KEY;
const API_URL = "http://data4library.kr/api/loanItemSrch";
const COLLECTION_NAME = "hotBooks";
const TIMEOUT = 240000;

// Firebase 초기화 및 Firestore 인스턴스 가져오기
const { db } = initializeFirebase();

if (!API_KEY) {
  throw new Error("API 키가 설정되지 않았습니다.");
}

interface BookData {
  bookname: string;
  authors: string;
  publisher: string;
  publication_year: string;
  isbn13: string;
  addition_symbol: string;
  vol: string;
  class_no: string;
  class_nm: string;
  loan_count: string;
  bookImageURL: string;
  bookDtlUrl: string;
}

interface BookDoc {
  doc: BookData;
}

interface ApiResponse {
  response: {
    docs: BookDoc[];
  };
}

function getLastWeekDate(): string {
  const date = new Date();
  date.setDate(date.getDate() - 7);
  console.log("[Date] Last week date:", date);
  return date.toISOString().split("T")[0];
}

function getYesterdayDate(): string {
  const date = new Date();
  date.setDate(date.getDate() - 1);
  console.log("[Date] Yesterday date:", date);
  return date.toISOString().split("T")[0];
}

export async function fetchAndStoreHotBooks() {
  const ageGroups = ["0", "6", "8", "14", "20", "30", "40", "50", "60"];
  const startDate = getLastWeekDate();
  const endDate = getYesterdayDate();

  console.log("[Start] Fetching hot books data from", startDate, "to", endDate);

  try {
    const collectedData: Record<string, BookData[]> = {};

    for (const age of ageGroups) {
      console.log(`[Request] 연령대 ${age} 데이터 요청 시작`);

      const response = await axios.get<ApiResponse>(API_URL, {
        params: {
          authKey: API_KEY,
          startDt: startDate,
          endDt: endDate,
          age: age,
          format: "json",
          pageSize: 100,
        },
        timeout: TIMEOUT,
      });

      console.log(`[Response] 연령대 ${age} 응답 상태:`, response.status);

      if (response.data?.response?.docs) {
        const books = response.data.response.docs.map((doc) => doc.doc);
        collectedData[age] = books;

        await db.collection(COLLECTION_NAME).doc(age).set({
          books,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`[Firestore] 연령대 ${age} 저장 완료 - ${books.length}건`);
      } else {
        console.log(`[Warning] 연령대 ${age}의 데이터가 없습니다.`);
      }
    }

    console.log("[Complete] 연령대별 인기 도서 데이터가 모두 저장되었습니다.");
    return collectedData;
  } catch (error) {
    if (isAxiosError(error)) {
      console.error("[Error] API 요청 실패:", {
        status: error.response?.status,
        statusText: error.response?.statusText,
        data: error.response?.data,
        config: {
          url: error.config?.url,
          method: error.config?.method,
          params: error.config?.params ? {
            ...error.config.params,
            authKey: "***",
          } : undefined,
        },
      });
    }
    throw error;
  }
}
