// libraryService.ts
import axios from "axios";
import { Location, LibraryInfo, LibraryApiResponse, BookAvailabilityResponse, RegionCodes } from "../utils/types";
import { VworldService } from "./vworldService";
import { calculateDistance } from "../utils/utils";
import { RegionCodeMapper } from "./regionCodeMapping";

export class LibraryService {
  private static readonly LIBRARY_BASE_URL = "http://data4library.kr/api";
  private readonly vworldService: VworldService;

  constructor(private readonly libraryApiKey: string, vworldApiKey: string) {
    if (!libraryApiKey) {
      throw new Error("LIBRARY_API_KEY가 설정되지 않았습니다.");
    }
    this.vworldService = new VworldService(vworldApiKey);
  }

  private async searchLibraries(isbn: string, regionCodes: RegionCodes): Promise<LibraryInfo[]> {
    const url = new URL(`${LibraryService.LIBRARY_BASE_URL}/libSrchByBook`);

    // 지역 코드 유효성 검증
    if (!RegionCodeMapper.validateRegionCode(regionCodes)) {
      console.error(`[Library] 유효하지 않은 지역 코드: ${RegionCodeMapper.debugRegionCode(regionCodes)}`);
      throw new Error("유효하지 않은 지역 코드");
    }

    const params = {
      authKey: this.libraryApiKey,
      isbn: isbn,
      region: regionCodes.region,
      dtl_region: regionCodes.dtlRegion,
      format: "json",
    };

    Object.entries(params).forEach(([key, value]) => {
      url.searchParams.append(key, value);
    });

    try {
      console.log(`[Library] 도서관 검색 요청: ${RegionCodeMapper.debugRegionCode(regionCodes)}`);
      const response = await axios.get<LibraryApiResponse>(url.toString(), { timeout: 50000 });
      const libraries = response.data.response?.libs || [];

      if (libraries.length === 0) {
        console.log(`[Library] ${regionCodes.sigungu}에서 도서관을 찾을 수 없음. ${regionCodes.sido} 전체 검색`);
        return this.searchLibrariesByRegion(isbn, regionCodes.region);
      }

      return libraries.map(({ lib }) => this.mapLibraryResponse(lib));
    } catch (error) {
      console.error(`[Library] ${regionCodes.sigungu} 도서관 검색 오류:`, error);
      return this.searchLibrariesByRegion(isbn, regionCodes.region);
    }
  }

  private async searchLibrariesByRegion(isbn: string, region: string): Promise<LibraryInfo[]> {
    const url = new URL(`${LibraryService.LIBRARY_BASE_URL}/libSrchByBook`);
    const params = {
      authKey: this.libraryApiKey,
      isbn: isbn,
      region: region,
      format: "json",
    };

    Object.entries(params).forEach(([key, value]) => {
      url.searchParams.append(key, value);
    });

    try {
      const response = await axios.get<LibraryApiResponse>(url.toString(), { timeout: 50000 });
      const libraries = response.data.response?.libs || [];
      return libraries.map(({ lib }) => this.mapLibraryResponse(lib));
    } catch (error) {
      console.error(`[Library] 광역시도(${region}) 도서관 검색 오류:`, error);
      return [];
    }
  }

  private mapLibraryResponse(lib: any): LibraryInfo {
    return {
      libCode: lib.libCode,
      name: lib.libName,
      address: lib.address,
      tel: lib.tel,
      latitude: lib.latitude,
      longitude: lib.longitude,
    };
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

      const regionCodes = await this.vworldService.getRegionCodes(userLocation);
      console.log(`[Library] 검색 위치: ${RegionCodeMapper.debugRegionCode(regionCodes)}`);

      const libraries = await this.searchLibraries(isbn, regionCodes);

      if (libraries.length === 0) {
        console.log(`[Library] ${regionCodes.sido}에서 검색된 도서관 없음`);
        return null;
      }

      const librariesWithDistance = this.addDistanceToLibraries(libraries, userLocation);
      const nearestLibrary = librariesWithDistance[0];

      const availableLibrary = await this.checkBookAvailability(nearestLibrary, isbn);

      if (availableLibrary) {
        console.log(`[Library] 대출 가능한 가장 가까운 도서관: ${availableLibrary.name} (${regionCodes.sigungu})`);
      } else {
        console.log(`[Library] 가장 가까운 도서관이 대출 가능하지 않음: ${nearestLibrary.name} (${regionCodes.sigungu})`);
      }

      return availableLibrary;
    } catch (error) {
      console.error("[Library] 도서관 검색 오류:", error);
      throw error;
    }
  }
}
