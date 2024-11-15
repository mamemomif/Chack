// services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class LocationService {
  final Logger _logger = Logger();
  Position? _lastPosition;
  final _positionController = StreamController<Position>.broadcast();
  bool _isInitialized = false;
  StreamSubscription<Position>? _positionSubscription;

  Stream<Position> get positionStream => _positionController.stream;

  Future<Position> getCurrentLocation() async {
    _logger.d('LocationService: 현재 위치 가져오기 시도');

    try {
      // 1. 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _logger.d('LocationService: 위치 서비스 상태 - $serviceEnabled');

      if (!serviceEnabled) {
        _logger.w('LocationService: 위치 서비스가 비활성화되어 있음');
        
        if (Platform.isIOS) {
          _logger.i('LocationService: iOS 위치 설정으로 이동 필요');
          throw Exception('위치 서비스를 활성화해주세요. 설정 > 개인정보 보호 및 보안 > 위치 서비스에서 설정할 수 있습니다.');
        } else {
          serviceEnabled = await Geolocator.openLocationSettings();
          if (!serviceEnabled) {
            throw Exception('위치 서비스를 활성화해주세요.');
          }
        }
      }

      // 2. 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      _logger.d('LocationService: 현재 위치 권한 상태 - $permission');

      // 3. 권한이 없는 경우 요청
      if (permission == LocationPermission.denied) {
        _logger.i('LocationService: 위치 권한 요청');
        permission = await Geolocator.requestPermission();
        _logger.d('LocationService: 위치 권한 요청 결과 - $permission');

        if (permission == LocationPermission.denied) {
          throw Exception('위치 권한이 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
        }
      }

      // 4. 영구적으로 거부된 경우
      if (permission == LocationPermission.deniedForever) {
        _logger.w('LocationService: 위치 권한이 영구적으로 거부됨');
        throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
      }

      // 5. 위치 정보 가져오기 시도
      try {
        _logger.i('LocationService: 위치 정보 가져오기 시작');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(
          const Duration(seconds: 5),
        );

        _logger.i('LocationService: 위치 정보 가져오기 성공 - (${position.latitude}, ${position.longitude})');
        _lastPosition = position;
        if (!_isInitialized) {
          _initializePositionStream();
          _isInitialized = true;
        }
        _positionController.add(position);

        return position;
      } on TimeoutException {
        _logger.w('LocationService: 위치 정보 가져오기 시간 초과, 기본 위치 사용');
        // 시간 초과시 서울시청 좌표 반환
        return Position(
          longitude: 126.9779692,
          latitude: 37.5662952,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }

    } catch (e) {
      _logger.e('LocationService: 위치 정보 가져오기 실패 - $e');
      
      // 에러 발생 시 마지막 알려진 위치 또는 기본 위치(서울시청) 반환
      final lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null) {
        _logger.i('LocationService: 마지막 알려진 위치 사용 - (${lastPosition.latitude}, ${lastPosition.longitude})');
        return lastPosition;
      }
      
      _logger.i('LocationService: 기본 위치(서울시청) 사용');
      return Position(
          longitude: 126.9779692,
          latitude: 37.5662952,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
      );
    }
  }

  void _initializePositionStream() {
    _logger.d('LocationService: 위치 스트림 초기화');
    
    _positionSubscription?.cancel();
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _logger.i('LocationService: 새로운 위치 업데이트 - (${position.latitude}, ${position.longitude})');
        _lastPosition = position;
        _positionController.add(position);
      },
      onError: (error) {
        _logger.e('LocationService: 위치 스트림 에러 - $error');
      },
      cancelOnError: false,
    );
  }

  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _positionController.close();
  }
}