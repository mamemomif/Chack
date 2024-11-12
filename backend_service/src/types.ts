// types.ts
import * as admin from "firebase-admin";

export interface Location {
  latitude: number;
  longitude: number;
}

export interface RegionCodes {
  region: string;
  dtlRegion: string;
  sido: string;
  sigungu: string;
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

// 인기 도서 관련 인터페이스 추가
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

// Firebase Timestamp 타입 정의
export interface FirebaseTimestamp {
  seconds: number;
  nanoseconds: number;
}

// 연령 그룹 타입 정의
export interface AgeGroup {
  code: string;
  name: string;
}
