// vworldService.ts
import axios from "axios";
import { logger } from "firebase-functions/v2";
import { Location, RegionCodes } from "../utils/types";
import { calculateDistance } from "../utils/utils";
import { RegionCodeMapper } from "./regionCodeMapping";

export class VworldService {
  private static readonly VWORLD_BASE_URL = "https://api.vworld.kr/req/data";
  private static readonly CACHE_DURATION = 30 * 60 * 1000; // 30분
  private static readonly CACHE_DISTANCE = 100; // 100m

  private cache: {
    data?: RegionCodes;
    timestamp?: Date;
    location?: Location;
  } = {};

  constructor(private readonly apiKey: string) {
    if (!apiKey) {
      throw new Error("VWORLD_API_KEY가 설정되지 않았습니다.");
    }
  }

  async getRegionCodes(location: Location): Promise<RegionCodes> {
    try {
      console.log(`[VWorld] 지역 코드 조회: lat=${location.latitude}, lng=${location.longitude}`);

      const cachedData = this.getCachedRegionCodes(location);
      if (cachedData) {
        console.log("[VWorld] 캐시된 지역 코드 사용");
        return cachedData;
      }

      const response = await axios.get(VworldService.VWORLD_BASE_URL, {
        params: this.buildVworldParams(location),
        timeout: 10000,
      });

      logger.info(`[VWorld] response: ${JSON.stringify(response.data)}`);

      // 파싱된 지역 정보 가져오기
      const regionInfo = RegionCodeMapper.parseVWorldResponse(response.data);

      // 도서관 정보나루 코드로 변환
      const regionCodes = RegionCodeMapper.getCodeFromAddress(regionInfo.fullAddress);

      if (!regionCodes) {
        throw new Error(`지역 코드 변환 실패: ${regionInfo.fullAddress}`);
      }

      // 코드 유효성 검증
      if (!RegionCodeMapper.validateRegionCode(regionCodes)) {
        console.error(`[VWorld] 유효하지 않은 지역 코드: ${RegionCodeMapper.debugRegionCode(regionCodes)}`);
        throw new Error(`유효하지 않은 지역 코드: ${JSON.stringify(regionCodes)}`);
      }

      this.cacheRegionCodes(location, regionCodes);

      console.log(`[VWorld] 지역 코드 변환 완료: ${RegionCodeMapper.debugRegionCode(regionCodes)}`);
      return regionCodes;
    } catch (error) {
      console.error("[VWorld] API 호출 실패:", error);
      throw new Error(`지역 코드 조회 실패: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  private buildVworldParams(location: Location) {
    return {
      service: "data",
      request: "GetFeature",
      data: "LT_C_ADSIGG_INFO",
      key: this.apiKey,
      domain: "https://us-central1-chack-ace76.cloudfunctions.net/getLibrariesWithBook?",
      format: "json",
      crs: "EPSG:4326",
      geomFilter: `POINT(${location.longitude} ${location.latitude})`,
      geometry: "false",
      attribute: "true",
      size: "1",
    };
  }

  private getCachedRegionCodes(location: Location): RegionCodes | null {
    if (!this.isCacheValid(location)) {
      return null;
    }
    return this.cache.data!;
  }

  private isCacheValid(location: Location): boolean {
    if (!this.cache.data || !this.cache.timestamp || !this.cache.location) {
      return false;
    }

    const isTimeValid = (new Date().getTime() - this.cache.timestamp.getTime()) <= VworldService.CACHE_DURATION;
    const isLocationValid = calculateDistance(location, this.cache.location) <= VworldService.CACHE_DISTANCE;

    return isTimeValid && isLocationValid;
  }

  private cacheRegionCodes(location: Location, data: RegionCodes): void {
    this.cache = {
      data,
      timestamp: new Date(),
      location,
    };
  }

  // 디버그용 메서드
  async debugLocation(location: Location): Promise<void> {
    try {
      const response = await axios.get(VworldService.VWORLD_BASE_URL, {
        params: this.buildVworldParams(location),
      });

      const regionInfo = RegionCodeMapper.parseVWorldResponse(response.data);
      console.log("[VWorld] 위치 정보:", {
        coordinates: `${location.latitude}, ${location.longitude}`,
        address: regionInfo.fullAddress,
        sido: regionInfo.sido,
        sigungu: regionInfo.sigungu,
      });
    } catch (error) {
      console.error("[VWorld] 디버그 실패:", error);
    }
  }
}
