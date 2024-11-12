// libraryService.ts
import axios from "axios";
import {
  Location,
  LibraryInfo,
  LibraryApiResponse,
  BookAvailabilityResponse,
} from "./types";
import { VworldService } from "./vworldService";
import { calculateDistance } from "./utils";

export class LibraryService {
  private static readonly LIBRARY_BASE_URL = "http://data4library.kr/api";
  private readonly vworldService: VworldService;

  constructor(
    private readonly libraryApiKey: string,
    vworldApiKey: string
  ) {
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

    const response = await axios.get<LibraryApiResponse>(url.toString(), { timeout: 5000 });
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

  private async checkBookAvailability(libraries: LibraryInfo[], isbn: string): Promise<LibraryInfo[]> {
    const availabilityChecks = libraries.map(async (lib) => {
      try {
        const url = new URL(`${LibraryService.LIBRARY_BASE_URL}/bookExist`);
        const params = {
          authKey: this.libraryApiKey,
          libCode: lib.libCode,
          isbn13: isbn,
          format: "json",
        };

        Object.entries(params).forEach(([key, value]) => {
          url.searchParams.append(key, value);
        });

        const response = await axios.get<BookAvailabilityResponse>(url.toString(), {
          timeout: 3000,
        });

        const result = response.data.response?.result;

        if (result?.hasBook === "Y") {
          return {
            ...lib,
            loanAvailable: result.loanAvailable,
          } as LibraryInfo;
        }
        return null;
      } catch (error) {
        console.log(`[Library] 대출 가능 여부 확인 오류 (${lib.name})`, error);
        return null;
      }
    });

    const results = await Promise.all(availabilityChecks);
    return results.filter((lib): lib is LibraryInfo => lib !== null);
  }

  async findLibrariesWithBook(isbn: string, userLocation: Location): Promise<LibraryInfo[]> {
    try {
      console.log(`[Library] 도서관 검색 시작: ISBN=${isbn}`);

      const regionCodes = await this.vworldService.getRegionCodes(userLocation);
      const libraries = await this.searchLibraries(isbn, regionCodes.region);

      if (libraries.length === 0) {
        console.log("[Library] 검색된 도서관 없음");
        return [];
      }

      const librariesWithDistance = this.addDistanceToLibraries(libraries, userLocation);
      const availableLibraries = await this.checkBookAvailability(librariesWithDistance, isbn);

      console.log(`[Library] 검색된 도서관 수: ${availableLibraries.length}`);
      console.log(`[Library] 대출 가능한 도서관 수: ${availableLibraries.filter((lib) => lib.loanAvailable === "Y").length}`);

      return availableLibraries;
    } catch (error) {
      console.error("[Library] 도서관 검색 오류:", error);
      throw error;
    }
  }
}
