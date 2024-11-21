// regionCodeMapping.ts

export interface LibraryRegionCode {
  region: string; // 광역시도 코드 (2자리)
  dtlRegion: string; // 세부지역 코드 (5자리)
  sido: string; // 광역시도 이름
  sigungu: string; // 시군구 이름
}

export class RegionCodeMapper {
  // 광역시도 매핑 테이블
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

  // 세부지역 매핑 테이블 (전체)
  private static readonly DETAIL_REGION_MAPPING: Record<string, Record<string, string>> = {
    "11": { // 서울특별시
      "종로구": "11010",
      "중구": "11020",
      "용산구": "11030",
      "성동구": "11040",
      "광진구": "11050",
      "동대문구": "11060",
      "중랑구": "11070",
      "성북구": "11080",
      "강북구": "11090",
      "도봉구": "11100",
      "노원구": "11110",
      "은평구": "11120",
      "서대문구": "11130",
      "마포구": "11140",
      "양천구": "11150",
      "강서구": "11160",
      "구로구": "11170",
      "금천구": "11180",
      "영등포구": "11190",
      "동작구": "11200",
      "관악구": "11210",
      "서초구": "11220",
      "강남구": "11230",
      "송파구": "11240",
      "강동구": "11250",
    },
    "21": { // 부산광역시
      "중구": "21010",
      "서구": "21020",
      "동구": "21030",
      "영도구": "21040",
      "부산진구": "21050",
      "동래구": "21060",
      "남구": "21070",
      "북구": "21080",
      "해운대구": "21090",
      "사하구": "21100",
      "금정구": "21110",
      "강서구": "21120",
      "연제구": "21130",
      "수영구": "21140",
      "사상구": "21150",
      "기장군": "21310",
    },
    "22": { // 대구광역시
      "중구": "22010",
      "동구": "22020",
      "서구": "22030",
      "남구": "22040",
      "북구": "22050",
      "수성구": "22060",
      "달서구": "22070",
      "달성군": "22310",
    },
    "23": { // 인천광역시
      "중구": "23010",
      "동구": "23020",
      "남구": "23030",
      "연수구": "23040",
      "남동구": "23050",
      "부평구": "23060",
      "계양구": "23070",
      "서구": "23080",
      "강화군": "23310",
      "옹진군": "23320",
    },
    "24": { // 광주광역시
      "동구": "24010",
      "서구": "24020",
      "남구": "24030",
      "북구": "24040",
      "광산구": "24050",
    },
    "25": { // 대전광역시
      "동구": "25010",
      "중구": "25020",
      "서구": "25030",
      "유성구": "25040",
      "대덕구": "25050",
    },
    "26": { // 울산광역시
      "중구": "26010",
      "남구": "26020",
      "동구": "26030",
      "북구": "26040",
      "울주군": "26310",
    },
    "29": { // 세종특별자치시
      "세종시": "29010",
    },
    "31": { // 경기도
      "수원시 장안구": "31011",
      "수원시 권선구": "31012",
      "수원시 팔달구": "31013",
      "수원시 영통구": "31014",
      "성남시 수정구": "31021",
      "성남시 중원구": "31022",
      "성남시 분당구": "31023",
      "의정부시": "31030",
      "안양시 만안구": "31041",
      "안양시 동안구": "31042",
      "부천시": "31050",
      "광명시": "31060",
      "평택시": "31070",
      "동두천시": "31080",
      "안산시 상록구": "31091",
      "안산시 단원구": "31092",
      "고양시 덕양구": "31101",
      "고양시 일산동구": "31103",
      "고양시 일산서구": "31104",
      "과천시": "31110",
      "구리시": "31120",
      "남양주시": "31130",
      "오산시": "31140",
      "시흥시": "31150",
      "군포시": "31160",
      "의왕시": "31170",
      "하남시": "31180",
      "용인시 처인구": "31191",
      "용인시 기흥구": "31192",
      "용인시 수지구": "31193",
      "파주시": "31200",
      "이천시": "31210",
      "안성시": "31220",
      "김포시": "31230",
      "화성시": "31240",
      "광주시": "31250",
      "양주시": "31260",
      "포천시": "31270",
      "여주시": "31280",
      "연천군": "31350",
      "가평군": "31370",
      "양평군": "31380",
    },
    "32": { // 강원특별자치도
      "춘천시": "32010",
      "원주시": "32020",
      "강릉시": "32030",
      "동해시": "32040",
      "태백시": "32050",
      "속초시": "32060",
      "삼척시": "32070",
      "홍천군": "32310",
      "횡성군": "32320",
      "영월군": "32330",
      "평창군": "32340",
      "정선군": "32350",
      "철원군": "32360",
      "화천군": "32370",
      "양구군": "32380",
      "인제군": "32390",
      "고성군": "32400",
      "양양군": "32410",
    },
    "33": { // 충청북도
      "충주시": "33020",
      "제천시": "33030",
      "청주시 상당구": "33041",
      "청주시 서원구": "33042",
      "청주시 흥덕구": "33043",
      "청주시 청원구": "33044",
      "보은군": "33320",
      "옥천군": "33330",
      "영동군": "33340",
      "진천군": "33350",
      "괴산군": "33360",
      "음성군": "33370",
      "단양군": "33380",
      "증평군": "33390",
    },
    "34": { // 충청남도
      "천안시 동남구": "34011",
      "천안시 서북구": "34012",
      "공주시": "34020",
      "보령시": "34030",
      "아산시": "34040",
      "서산시": "34050",
      "논산시": "34060",
      "계룡시": "34070",
      "당진시": "34080",
      "금산군": "34310",
      "부여군": "34330",
      "서천군": "34340",
      "청양군": "34350",
      "홍성군": "34360",
      "예산군": "34370",
      "태안군": "34380",
    },
    "35": { // 전라북도
      "전주시 완산구": "35011",
      "전주시 덕진구": "35012",
      "군산시": "35020",
      "익산시": "35030",
      "정읍시": "35040",
      "남원시": "35050",
      "김제시": "35060",
      "완주군": "35310",
      "진안군": "35320",
      "무주군": "35330",
      "장수군": "35340",
      "임실군": "35350",
      "순창군": "35360",
      "고창군": "35370",
      "부안군": "35380",
    },
    "36": { // 전라남도
      "목포시": "36010",
      "여수시": "36020",
      "순천시": "36030",
      "나주시": "36040",
      "광양시": "36060",
      "담양군": "36310",
      "곡성군": "36320",
      "구례군": "36330",
      "고흥군": "36350",
      "보성군": "36360",
      "화순군": "36370",
      "장흥군": "36380",
      "강진군": "36390",
      "해남군": "36400",
      "영암군": "36410",
      "무안군": "36420",
      "함평군": "36430",
      "영광군": "36440",
      "장성군": "36450",
      "완도군": "36460",
      "진도군": "36470",
      "신안군": "36480",
    },
    "37": { // 경상북도
      "포항시 남구": "37011",
      "포항시 북구": "37012",
      "경주시": "37020",
      "김천시": "37030",
      "안동시": "37040",
      "구미시": "37050",
      "영주시": "37060",
      "영천시": "37070",
      "상주시": "37080",
      "문경시": "37090",
      "경산시": "37100",
      "군위군": "37310",
      "의성군": "37320",
      "청송군": "37330",
      "영양군": "37340",
      "영덕군": "37350",
      "청도군": "37360",
      "고령군": "37370",
      "성주군": "37380",
      "칠곡군": "37390",
      "예천군": "37400",
      "봉화군": "37410",
      "울진군": "37420",
      "울릉군": "37430",
    },
    "38": { // 경상남도
      "진주시": "38030",
      "통영시": "38050",
      "사천시": "38060",
      "김해시": "38070",
      "밀양시": "38080",
      "거제시": "38090",
      "양산시": "38100",
      "창원시 의창구": "38111",
      "창원시 성산구": "38112",
      "창원시 마산합포구": "38113",
      "창원시 마산회원구": "38114",
      "창원시 진해구": "38115",
      "의령군": "38310",
      "함안군": "38320",
      "창녕군": "38330",
      "고성군": "38340",
      "남해군": "38350",
      "하동군": "38360",
      "산청군": "38370",
      "함양군": "38380",
      "거창군": "38390",
      "합천군": "38400",
    },
    "39": { // 제주특별자치도
      "제주시": "39010",
      "서귀포시": "39020",
    },
  };

  // VWorld 8자리 코드를 도서관 정보나루 5자리 코드로 변환
  private static convertToLibraryDtlRegion(vworldCode: string): string {
    return vworldCode.substring(0, 5);
  }

  // VWorld API 응답을 도서관 정보나루 코드로 변환
  static convertToLibraryRegionCode(vworldResponse: any): LibraryRegionCode {
    if (!vworldResponse?.response?.result?.featureCollection?.features?.[0]) {
      throw new Error("유효하지 않은 VWorld API 응답");
    }

    const properties = vworldResponse.response.result.featureCollection.features[0].properties;
    const vworldSido = properties.full_nm.split(" ")[0];
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

  // 광역시도 코드로 세부지역 목록 조회
  static getDetailRegions(regionCode: string): Record<string, string> {
    return this.DETAIL_REGION_MAPPING[regionCode] || {};
  }

  // 시군구 이름으로 세부지역 코드 조회
  static getDetailRegionCode(regionCode: string, sigunguName: string): string | undefined {
    const detailRegions = this.getDetailRegions(regionCode);
    return detailRegions[sigunguName];
  }

  // 세부지역 코드로 시군구 이름 조회
  static getSigunguName(regionCode: string, dtlRegionCode: string): string | undefined {
    const detailRegions = this.getDetailRegions(regionCode);
    return Object.entries(detailRegions).find(([_, code]) => code === dtlRegionCode)?.[0];
  }

  // 광역시도 이름으로 코드 조회
  static getRegionCode(sidoName: string): string | undefined {
    return this.REGION_MAPPING[sidoName];
  }

  // 광역시도 코드로 이름 조회
  static getRegionName(regionCode: string): string | undefined {
    return Object.entries(this.REGION_MAPPING).find(([_, code]) => code === regionCode)?.[0];
  }

  // 전체 지역 정보 조회
  static getAllRegions(): Array<{
  regionCode: string;
  regionName: string;
  details: Array<{
    code: string;
    name: string;
  }>;
}> {
    return Object.entries(this.REGION_MAPPING).map(([regionName, regionCode]) => {
      const details = Object.entries(this.DETAIL_REGION_MAPPING[regionCode] || {}).map(
        ([name, code]) => ({
          code,
          name,
        })
      );

      return {
        regionCode,
        regionName,
        details,
      };
    });
  }

  // VWorld 응답 데이터를 파싱하여 지역 정보 추출
  static parseVWorldResponse(vworldResponse: any): {
  sido: string;
  sigungu: string;
  fullAddress: string;
} {
    if (!vworldResponse?.response?.result?.featureCollection?.features?.[0]) {
      throw new Error("유효하지 않은 VWorld API 응답");
    }

    const properties = vworldResponse.response.result.featureCollection.features[0].properties;
    const fullAddress = properties.full_nm;
    const addressParts = fullAddress.split(" ");

    return {
      sido: addressParts[0],
      sigungu: properties.sig_kor_nm,
      fullAddress,
    };
  }

  // 전체 주소를 기반으로 도서관 정보나루 코드 생성
  static getCodeFromAddress(fullAddress: string): LibraryRegionCode | null {
    try {
      const addressParts = fullAddress.split(" ");
      const sido = addressParts[0];
      const sigungu = addressParts[1];

      const region = this.REGION_MAPPING[sido];
      if (!region) {
        return null;
      }

      const dtlRegion = this.getDetailRegionCode(region, sigungu);
      if (!dtlRegion) {
        return null;
      }

      return {
        region,
        dtlRegion,
        sido,
        sigungu,
      };
    } catch (error) {
      console.error("주소 파싱 오류:", error);
      return null;
    }
  }

  // 디버그용 코드 정보 출력
  static debugRegionCode(code: LibraryRegionCode): string {
    return `광역시도: ${code.sido} (${code.region}), 시군구: ${code.sigungu} (${code.dtlRegion})`;
  }
}
