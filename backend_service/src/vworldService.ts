// vworldService.ts
import axios from "axios";
import { logger } from "firebase-functions/v2";
import { Location, RegionCodes } from "./types";
import { calculateDistance } from "./utils";

export class VworldService {
  private static readonly VWORLD_BASE_URL = "https://api.vworld.kr/req/data";
  private static readonly CACHE_DURATION = 30 * 60 * 1000; // 30분
  private static readonly CACHE_DISTANCE = 100; // 100m

  private static readonly REGION_MAPPING: Record<string, string> = {
    "서울특별시": "11",
    "부산광역시": "21",
    "대구광역시": "22",
    "인천광역시": "23",
    "광주광역시": "24",
    "대전광역시": "25",
    "울산광역시": "26",
    "세종특별자치시": "29",
    "경기도": "31",
    "강원특별자치도": "32",
    "충청북도": "33",
    "충청남도": "34",
    "전라북도": "35",
    "전라남도": "36",
    "경상북도": "37",
    "경상남도": "38",
    "제주특별자치도": "39",
  };

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
      const regionCodes = this.parseVworldResponse(response.data);
      this.cacheRegionCodes(location, regionCodes);

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

  private parseVworldResponse(responseData: any): RegionCodes {
    if (responseData.response.status !== "OK" ||
        !responseData.response.result?.featureCollection?.features?.[0]) {
      throw new Error("행정구역 정보를 찾을 수 없습니다");
    }

    const properties = responseData.response.result.featureCollection.features[0].properties;
    const vworldSido = properties.full_nm.toString().split(" ")[0];
    const region = VworldService.REGION_MAPPING[vworldSido];

    if (!region) {
      throw new Error(`지역 코드 매핑 없음: ${vworldSido}`);
    }

    return {
      region,
      dtlRegion: properties.sig_cd,
      sido: vworldSido,
      sigungu: properties.sig_kor_nm,
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
}
