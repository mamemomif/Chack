import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import axios from "axios";
import { fetchAndStoreHotBooks } from "./fetchAndStoreHotBooks";
import { LibraryService } from "./libraryService";
import { initializeFirebase } from "./firebase";
import { setGlobalOptions, logger } from "firebase-functions/v2";
import { defineSecret } from "firebase-functions/params";
import { Location } from "./types";

// Secrets 정의
const SECRET_LIBRARY_DATANARU_API_KEY = defineSecret("LIBRARY_DATANARU_API_KEY");
const SECRET_VWORLD_API_KEY = defineSecret("VWORLD_API_KEY");

// Firebase 초기화
initializeFirebase();

// VPC 커넥터 설정
const vpcConnectorOptions = {
  vpcConnector: "chack-serless-connector",
  vpcConnectorEgressSettings: "ALL_TRAFFIC" as const,
};

// 전역 옵션 설정
setGlobalOptions({
  ...vpcConnectorOptions,
});

async function getExternalIP(): Promise<string> {
  try {
    const response = await axios.get("https://api.ipify.org?format=json");
    return response.data.ip;
  } catch (error) {
    logger.error("[Error] 외부 IP 확인 실패:", error);
    return "외부 IP를 확인할 수 없습니다.";
  }
}

export const scheduledFetchHotBooks = onSchedule(
  {
    region: "asia-northeast3",
    schedule: "every monday 01:00",
    timeZone: "Asia/Seoul",
    timeoutSeconds: 240,
    memory: "256MiB",
    secrets: [SECRET_LIBRARY_DATANARU_API_KEY],
  },
  async () => {
    logger.info("[Start] 주기적 인기 도서 데이터 수집 시작");
    const externalIp = await getExternalIP();
    logger.info("[Info] 외부 IP 주소:", externalIp);

    await fetchAndStoreHotBooks(SECRET_LIBRARY_DATANARU_API_KEY.value());
    logger.info("[Complete] 주기적 인기 도서 데이터 수집 완료");
  }
);

export const manualFetchHotBooks = onRequest(
  {
    region: "asia-northeast3",
    timeoutSeconds: 240,
    memory: "256MiB",
    secrets: [SECRET_LIBRARY_DATANARU_API_KEY],
  },
  async (req, res) => {
    try {
      const externalIp = await getExternalIP();
      logger.info("[Info] 외부 IP 주소:", externalIp);

      const collectedData = await fetchAndStoreHotBooks(SECRET_LIBRARY_DATANARU_API_KEY.value());
      res.status(200).json({
        success: true,
        message: "인기 도서 데이터가 성공적으로 저장되었습니다.",
        functionIP: externalIp,
        clientIP: req.ip,
        collectedData: collectedData,
      });
      logger.info(`[Success] Function IP - ${externalIp}, 클라이언트 IP - ${req.ip}`);
    } catch (error) {
      logger.error("[Error] 데이터 수집 및 저장 오류:", error);
      res.status(500).json({
        success: false,
        message: "인기 도서 데이터 수집에 실패했습니다.",
        error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
        functionIP: await getExternalIP(),
        clientIP: req.ip,
      });
    }
  }
);

interface RequestParams {
  isbn?: string | string[];
  latitude?: string | string[];
  longitude?: string | string[];
}

export const getLibrariesWithBook = onRequest(
  {
    region: "asia-northeast3",
    timeoutSeconds: 120,
    memory: "256MiB",
    secrets: [SECRET_LIBRARY_DATANARU_API_KEY, SECRET_VWORLD_API_KEY],
  },
  async (req, res) => {
    try {
      const params: RequestParams = { ...req.query, ...req.body };
      const { isbn, latitude, longitude } = params;

      logger.info("[Request] Received data:", { isbn, latitude, longitude });

      if (!isbn || !latitude || !longitude) {
        logger.error("[Error] Invalid parameters", { isbn, latitude, longitude });
        res.status(400).json({
          success: false,
          message: "유효하지 않은 파라미터입니다. 'isbn', 'latitude', 'longitude'는 필수입니다.",
          receivedParams: { isbn, latitude, longitude },
        });
        return;
      }

      const isbnStr = Array.isArray(isbn) ? isbn[0] : isbn.toString();
      const latNum = parseFloat(Array.isArray(latitude) ? latitude[0] : latitude.toString());
      const lonNum = parseFloat(Array.isArray(longitude) ? longitude[0] : longitude.toString());

      if (isNaN(latNum) || isNaN(lonNum)) {
        throw new Error("유효하지 않은 좌표입니다. 위도와 경도는 숫자여야 합니다.");
      }

      if (latNum < -90 || latNum > 90 || lonNum < -180 || lonNum > 180) {
        throw new Error(
          "좌표 범위를 벗어났습니다. 위도는 -90부터 90까지, 경도는 -180부터 180까지의 값이어야 합니다."
        );
      }

      const externalIp = await getExternalIP();
      logger.info("[Info] 외부 IP 주소:", externalIp);
      logger.info("[Processing] 도서관 정보를 조회합니다...");

      const userLocation: Location = {
        latitude: latNum,
        longitude: lonNum,
      };

      const libraryService = new LibraryService(
        SECRET_LIBRARY_DATANARU_API_KEY.value(),
        SECRET_VWORLD_API_KEY.value()
      );

      const libraries = await libraryService.findLibrariesWithBook(isbnStr, userLocation);

      logger.info("[Response] 발견된 도서관 수:", libraries.length);

      res.status(200).json({
        success: true,
        data: {
          libraries,
          query: {
            isbn: isbnStr,
            latitude: latNum,
            longitude: lonNum,
          },
        },
        externalIp,
      });
    } catch (error) {
      logger.error("[Error] 도서관 조회 실패:", error);
      res.status(500).json({
        success: false,
        message: "도서관 정보를 가져오는 중 오류가 발생했습니다.",
        error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
      });
    }
  }
);
