import axios from "axios";
import {
  Location,
  LibraryInfo,
  LibraryApiResponse,
  BookAvailabilityResponse,
} from "../utils/types";
import { VworldService } from "./vworldService";
import { calculateDistance } from "../utils/utils";

export class LibraryService {
  private static readonly LIBRARY_BASE_URL = "http://data4library.kr/api";
  private readonly vworldService: VworldService;

  constructor(private readonly libraryApiKey: string, vworldApiKey: string) {
    if (!libraryApiKey) {
      throw new Error("LIBRARY_API_KEY가 설정되지 않았습니다.");
    }
    this.vworldService = new VworldService(vworldApiKey);
  }

  private async searchLibraries(isbn: string, regionCode: string): Promise<LibraryInfo[]> {
    const url = new URL(`${LibraryService.LIBRARY_BASE_URL}/libSrchByBook`);
    const params = {
      authKey: this.libraryApiKey,
      isbn: isbn,
      region: regionCode,
      format: "json",
    };

    Object.entries(params).forEach(([key, value]) => {
      url.searchParams.append(key, value);
    });

    const response = await axios.get<LibraryApiResponse>(url.toString(), { timeout: 50000 });
    const libraries = response.data.response?.libs || [];

    return libraries.map(({ lib }) => ({
      libCode: lib.libCode,
      name: lib.libName,
      address: lib.address,
      tel: lib.tel,
      latitude: lib.latitude,
      longitude: lib.longitude,
    }));
  }

  private addDistanceToLibraries(libraries: LibraryInfo[], userLocation: Location): LibraryInfo[] {
    return libraries
      .map((lib) => {
        try {
          const lat = parseFloat(lib.latitude || "0");
          const lng = parseFloat(lib.longitude || "0");

          if (isNaN(lat) || isNaN(lng)) {
            console.log(`[Library] 잘못된 좌표 데이터 (${lib.name}): ${lib.latitude}, ${lib.longitude}`);
            return lib;
          }

          const libLocation = { latitude: lat, longitude: lng };
          const distance = calculateDistance(userLocation, libLocation);

          return {
            ...lib,
            distance,
          };
        } catch (error) {
          console.log(`[Library] 거리 계산 오류 (${lib.name})`, error);
          return lib;
        }
      })
      .sort((a, b) => {
        const distA = a.distance ?? Infinity;
        const distB = b.distance ?? Infinity;
        return distA - distB;
      });
  }

  private async checkBookAvailability(library: LibraryInfo, isbn: string): Promise<LibraryInfo | null> {
    try {
      const url = new URL(`${LibraryService.LIBRARY_BASE_URL}/bookExist`);
      const params = {
        authKey: this.libraryApiKey,
        libCode: library.libCode,
        isbn13: isbn,
        format: "json",
      };

      Object.entries(params).forEach(([key, value]) => {
        url.searchParams.append(key, value);
      });

      const response = await axios.get<BookAvailabilityResponse>(url.toString(), { timeout: 3000 });
      const result = response.data.response?.result;

      if (result?.hasBook === "Y") {
        return {
          ...library,
          loanAvailable: result.loanAvailable,
        };
      }
      return null;
    } catch (error) {
      console.log(`[Library] 대출 가능 여부 확인 오류 (${library.name})`, error);
      return null;
    }
  }

  async findNearestLibraryWithBook(isbn: string, userLocation: Location): Promise<LibraryInfo | null> {
    try {
      console.log(`[Library] 도서관 검색 시작: ISBN=${isbn}`);

      // 지역 코드 가져오기
      const regionCodes = await this.vworldService.getRegionCodes(userLocation);
      const libraries = await this.searchLibraries(isbn, regionCodes.region);

      if (libraries.length === 0) {
        console.log("[Library] 검색된 도서관 없음");
        return null;
      }

      // 거리 계산 후 가장 가까운 도서관 선택
      const librariesWithDistance = this.addDistanceToLibraries(libraries, userLocation);
      const nearestLibrary = librariesWithDistance[0]; // 가장 가까운 도서관

      // 대출 가능 여부 확인
      const availableLibrary = await this.checkBookAvailability(nearestLibrary, isbn);

      if (availableLibrary) {
        console.log(`[Library] 대출 가능한 가장 가까운 도서관: ${availableLibrary.name}`);
      } else {
        console.log(`[Library] 가장 가까운 도서관이 대출 가능하지 않음: ${nearestLibrary.name}`);
      }

      return availableLibrary;
    } catch (error) {
      console.error("[Library] 도서관 검색 오류:", error);
      throw error;
    }
  }
}
