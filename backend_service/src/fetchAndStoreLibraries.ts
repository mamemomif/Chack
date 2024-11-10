// fetchAndStoreLibraries.ts
import * as dotenv from "dotenv";
import { isAxiosError } from "axios";
import axios from "axios";
import { initializeFirebase } from "./firebase";
import * as admin from "firebase-admin";

dotenv.config();
const API_KEY = process.env.LIBRARY_DATANARU_API_KEY;
const API_URL = "http://data4library.kr/api/libSrch";
const TIMEOUT = 240000;

const { db } = initializeFirebase();

if (!API_KEY) {
  throw new Error("API 키가 설정되지 않았습니다.");
}

interface Library {
  libCode: string;
  libName: string;
  address: string;
  tel: string;
  fax: string;
  latitude: string;
  longitude: string;
  homepage?: string;
  closed?: string;
  operatingTime?: string;
  BookCount: string;
}

interface LibraryItem {
  lib: Library;
}

interface ApiResponse {
  response: {
    numFound: number;
    resultNum: number;
    libs: LibraryItem[];
  };
}

export async function fetchAndStoreLibraries() {
  let pageNo = 1;
  let hasMoreData = true;
  const pageSize = 100;
  let collectedLibraries: Library[] = [];

  try {
    while (hasMoreData) {
      console.log(`[Request] 도서관 데이터 요청 - 페이지 ${pageNo}`);
      const response = await axios.get<ApiResponse>(API_URL, {
        params: {
          authKey: API_KEY,
          pageNo: pageNo,
          pageSize: pageSize,
          format: "json",
        },
        timeout: TIMEOUT,
      });

      console.log(`[Response] 페이지 ${pageNo} 응답 상태:`, response.status);
      console.log(`[Response] 총 도서관 수:`, response.data.response.numFound);
      console.log(`[Response] 현재 페이지 데이터 수:`, response.data.response.resultNum);

      const libraries = response.data.response.libs.map((item) => item.lib);
      console.log(`[Processing] 변환된 도서관 데이터 수:`, libraries.length);

      if (!libraries || libraries.length === 0) {
        console.log("[Info] 더 이상 가져올 도서관 데이터가 없습니다.");
        hasMoreData = false;
        break;
      }

      collectedLibraries = collectedLibraries.concat(libraries);

      const batch = db.batch();
      libraries.forEach((library: Library) => {
        const libRef = db.collection("libraries").doc(library.libCode);
        batch.set(libRef, {
          libName: library.libName,
          address: library.address,
          tel: library.tel,
          fax: library.fax,
          latitude: parseFloat(library.latitude),
          longitude: parseFloat(library.longitude),
          homepage: library.homepage || null,
          closed: library.closed || null,
          operatingTime: library.operatingTime || null,
          bookCount: parseInt(library.BookCount, 10),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();
      console.log(`[Firestore] 페이지 ${pageNo} 저장 완료 - ${libraries.length}건`);

      const totalCount = response.data.response.numFound;
      const currentCount = pageNo * pageSize;
      if (currentCount >= totalCount) {
        console.log("[Complete] 모든 도서관 데이터를 가져왔습니다.");
        hasMoreData = false;
      } else {
        pageNo++;
        await new Promise((resolve) => setTimeout(resolve, 1000));
      }
    }

    console.log(`[Complete] 총 ${collectedLibraries.length}개의 도서관 정보가 저장되었습니다.`);
    return collectedLibraries;
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
