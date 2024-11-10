// index.ts
import * as functions from "firebase-functions/v2";
import { fetchAndStoreHotBooks } from "./fetchAndStoreHotBooks";
import { fetchAndStoreLibraries } from "./fetchAndStoreLibraries";
import { initializeFirebase } from "./firebase";
import { networkInterfaces } from "os";

initializeFirebase();

const vpcConnector = {
  vpcConnector: "chack-connector",
  vpcConnectorEgressSettings: "ALL_TRAFFIC" as const,
};

function getOutboundIP(): string {
  const nets = networkInterfaces();
  let ip = "";

  for (const name of Object.keys(nets)) {
    for (const net of nets[name] ?? []) {
      if (net.family === "IPv4" && !net.internal) {
        ip = net.address;
        break;
      }
    }
    if (ip) break;
  }
  return ip;
}

export const scheduledFetchHotBooks = functions.scheduler
  .onSchedule(
    {
      schedule: "every monday 01:00",
      timeZone: "Asia/Seoul",
      ...vpcConnector,
      timeoutSeconds: 240,
      memory: "256MiB",
    },
    async () => {
      console.log("[Start] 주기적 연령대별 인기 도서 데이터 수집 작업 시작");
      await fetchAndStoreHotBooks();
      console.log("[Complete] 작업이 완료되었습니다.");
    },
  );

export const manualFetchHotBooks = functions.https
  .onRequest(
    {
      ...vpcConnector,
      timeoutSeconds: 240,
      memory: "256MiB",
    },
    async (req, res) => {
      try {
        const outboundIP = getOutboundIP();
        const collectedData = await fetchAndStoreHotBooks();
        res.status(200).json({
          success: true,
          message: "연령대별 인기 도서 데이터가 성공적으로 저장되었습니다.",
          functionIP: outboundIP,
          clientIP: req.ip,
          collectedData: collectedData,
        });
        console.log(`[Success] Function IP - ${outboundIP}, 클라이언트 IP - ${req.ip}`);
      } catch (error) {
        console.error("[Error] 데이터 수집 및 저장 오류:", error);
        res.status(500).json({
          success: false,
          message: "도서 데이터 수집에 실패했습니다.",
          error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
          functionIP: getOutboundIP(),
          clientIP: req.ip,
        });
      }
    },
  );

export const manualFetchLibraries = functions.https
  .onRequest(
    {
      ...vpcConnector,
      timeoutSeconds: 240,
      memory: "256MiB",
    },
    async (req, res) => {
      try {
        const outboundIP = getOutboundIP();
        const collectedLibraries = await fetchAndStoreLibraries();
        res.status(200).json({
          success: true,
          message: "도서관 정보가 성공적으로 저장되었습니다.",
          functionIP: outboundIP,
          clientIP: req.ip,
          collectedLibraries: collectedLibraries,
        });
        console.log(`[Success] Function IP - ${outboundIP}, 클라이언트 IP - ${req.ip}`);
      } catch (error) {
        console.error("[Error] 도서관 정보 저장 오류:", error);
        res.status(500).json({
          success: false,
          message: "도서관 정보 저장에 실패했습니다.",
          error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
          functionIP: getOutboundIP(),
          clientIP: req.ip,
        });
      }
    },
  );
  