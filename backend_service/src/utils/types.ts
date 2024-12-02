// types.ts
import * as admin from "firebase-admin";

// data4library and VWorld Service interfaces
export interface Location {
  latitude: number;
  longitude: number;
}

export interface RegionCodes {
  region: string; // 광역시도 코드 (2자리)
  dtlRegion: string; // 세부지역 코드 (5자리)
  sido: string; // 광역시도 이름
  sigungu: string; // 시군구 이름
}

export interface LibraryInfo {
  libCode: string;
  name: string;
  address: string;
  tel: string;
  latitude: string;
  longitude: string;
  distance?: number;
  loanAvailable?: string;
}

export interface LibraryApiResponse {
  response: {
    libs?: Array<{
      lib: {
        libCode: string;
        libName: string;
        address: string;
        tel: string;
        latitude: string;
        longitude: string;
      };
    }>;
  };
}

export interface BookAvailabilityResponse {
  response: {
    result?: {
      hasBook: string;
      loanAvailable: string;
    };
  };
}

export interface ApiConfig {
  libraryApiKey: string;
  vworldApiKey: string;
}

// Interface for HotBooks data
export interface Book {
  addition_symbol: string;
  authors: string;
  bookDtlUrl: string;
  bookImageURL: string;
  bookname: string;
  class_nm: string;
  class_no: string;
  isbn13: string;
  loan_count: number;
  publication_year: string;
  publisher: string;
  ranking: number;
  vol: string;
  libCode?: string;
  loanAvailable?: string;
}

export interface HotBooksDocument {
  ageGroupName: string;
  books: Book[];
  period: {
    startDt: string;
    endDt: string;
  };
  updatedAt: admin.firestore.Timestamp;
  region?: string;
}

export interface HotBooksApiResponse {
  response: {
    request: {
      startDt: string;
      endDt: string;
      age: string;
      pageNo: number;
      pageSize: number;
    };
    resultNum: number;
    numFound: number;
    docs: Array<{
      doc: {
        bookname: string;
        authors: string;
        publisher: string;
        publication_year: string;
        isbn13: string;
        addition_symbol: string;
        vol: string;
        class_no: string;
        class_nm: string;
        loan_count: string; // loan_count와 ranking은 문자열로 전달되므로 string으로 변경
        ranking: string;
        bookImageURL: string;
        bookDtlUrl: string;
      };
    }>;
  };
}

// 연령 그룹 타입 정의
export interface AgeGroup {
  code: string;
  name: string;
}

// Firebase Timestamp 타입 정의
export interface FirebaseTimestamp {
  seconds: number;
  nanoseconds: number;
}
