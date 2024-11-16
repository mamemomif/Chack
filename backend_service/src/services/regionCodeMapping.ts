// regionCodeMapping.ts

// 도서관 정보나루 지역 코드 타입
export interface LibraryRegionCode {
  region: string;
  dtlRegion: string;
  sido: string;
  sigungu: string;
}

// VWorld API 응답 타입
export interface VWorldRegionCode {
  sig_cd: string;
  sig_kor_nm: string;
  full_nm: string;
}

export default class RegionCodeMapper {
  // 광역시도 매핑
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

  // VWorld 8자리 코드를 도서관 정보나루 5자리 코드로 변환
  private static convertToLibraryDtlRegion(vworldCode: string): string {
    // VWorld 코드: 41115(시군구) + 000(읍면동) -> 도서관 정보나루: 41115
    return vworldCode.substring(0, 5);
  }

  // VWorld API 응답을 도서관 정보나루 코드로 변환
  static convertToLibraryRegionCode(vworldResponse: any): LibraryRegionCode {
    if (!vworldResponse?.response?.result?.featureCollection?.features?.[0]) {
      throw new Error("유효하지 않은 VWorld API 응답");
    }

    const properties = vworldResponse.response.result.featureCollection.features[0].properties;
    const vworldSido = properties.full_nm.toString().split(" ")[0];
    const region = this.REGION_MAPPING[vworldSido];

    if (!region) {
      throw new Error(`알 수 없는 광역시도: ${vworldSido}`);
    }

    return {
      region,
      dtlRegion: this.convertToLibraryDtlRegion(properties.sig_cd),
      sido: vworldSido,
      sigungu: properties.sig_kor_nm,
    };
  }

  // 코드 유효성 검증
  static validateRegionCode(code: LibraryRegionCode): boolean {
    const validRegion = /^\d{2}$/.test(code.region);
    const validDtlRegion = /^\d{5}$/.test(code.dtlRegion);
    const regionMatch = code.dtlRegion.startsWith(code.region);

    return validRegion && validDtlRegion && regionMatch;
  }
}
