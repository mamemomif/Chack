// utils.ts
import { Location } from "./types";

export function calculateDistance(coord1: Location, coord2: Location): number {
  const toRad = (value: number) => (value * Math.PI) / 180;
  const EARTH_RADIUS = 6371e3; // 지구의 반지름 (미터)

  const φ1 = toRad(coord1.latitude);
  const φ2 = toRad(coord2.latitude);
  const Δφ = toRad(coord2.latitude - coord1.latitude);
  const Δλ = toRad(coord2.longitude - coord1.longitude);

  const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
           Math.cos(φ1) * Math.cos(φ2) *
           Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  return EARTH_RADIUS * c;
}
