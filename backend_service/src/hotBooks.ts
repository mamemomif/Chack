// hotBooks.ts
import * as dotenv from "dotenv";
import axios from "axios";
import { initializeFirebase } from "./firebase";
import * as admin from "firebase-admin"; // admin 추가

dotenv.config();
const API_KEY = process.env.LIBRARY_DATANARU_API_KEY;

console.log("Loaded API Key:", API_KEY); // API Key 로드 확인

if (!API_KEY) {
  throw new Error("API 키가 설정되지 않았습니다.");
}

// Firebase 초기화 및 Firestore 인스턴스 가져오기
const { db } = initializeFirebase();
console.log("Firebase initialized, Firestore instance:", db); // Firebase 초기화 확인

const API_URL = "http://data4library.kr/api/loanItemSrch";
const COLLECTION_NAME = "hotBooks";

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

export async function fetchAndStoreHotBooks() {
  const ageGroups = ["0", "6", "8", "14", "20", "30", "40", "50", "60"];
  const startDate = getLastWeekDate();
  const endDate = getYesterdayDate();

  console.log("Fetching hot books data from", startDate, "to", endDate); // 날짜 확인

  try {
    for (const age of ageGroups) {
      console.log(`Fetching data for age group: ${age}`); // 연령대별 요청 확인

      const response = await axios.get(API_URL, {
        params: {
          authKey: API_KEY,
          startDt: startDate,
          endDt: endDate,
          age: age,
          format: "json",
          pageSize: 100,
        },
      });

      console.log(`Response for age group ${age}:`, response.data); // API 응답 확인

      if (response.data?.response?.docs) {
        const books = response.data.response.docs.map(
          (doc: { doc: BookData }) => doc.doc
        );

        await db.collection(COLLECTION_NAME).doc(age).set({
          books,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(`Firestore 저장 성공 - 연령대 ${age}:`, books); // Firestore 저장 확인
      } else {
        console.log(`No data found for age group ${age}`); // 데이터가 없을 때
      }
    }
  } catch (error) {
    console.error("데이터 수집 및 Firestore 저장 오류:", error);
    throw error;
  }
}

function getLastWeekDate(): string {
  const date = new Date();
  date.setDate(date.getDate() - 7);
  console.log("Last week date:", date); // 날짜 계산 확인
  return date.toISOString().split("T")[0];
}

function getYesterdayDate(): string {
  const date = new Date();
  date.setDate(date.getDate() - 1);
  console.log("Yesterday date:", date); // 날짜 계산 확인
  return date.toISOString().split("T")[0];
}
