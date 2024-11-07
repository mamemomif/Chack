// lib/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import '../models/api_exception.dart';
import 'dart:developer' as developer;

class LocationService {
  Future<Position> getCurrentLocation() async {
    try {
      developer.log('위치 서비스 상태 확인 시작');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      developer.log('위치 서비스 상태: $serviceEnabled');

      if (!serviceEnabled) {
        throw ApiException('위치 서비스가 비활성화되어 있습니다. 위치 서비스를 활성화해주세요.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw ApiException('위치 권한이 거부되었습니다.');
        }
      }

      developer.log('위치 권한 상태: $permission');

      if (permission == LocationPermission.deniedForever) {
        throw ApiException('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      developer.log('현재 위치: lat=${position.latitude}, lng=${position.longitude}');
      return position;

    } catch (e) {
      developer.log('위치 정보 획득 실패', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('위치 정보를 가져오는데 실패했습니다: $e');
    }
  }

  double calculateDistance(Position position1, Position position2) {
    return Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
  }
}