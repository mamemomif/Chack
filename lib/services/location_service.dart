// services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:io';

class LocationServiceStatus {
  final bool success;
  final String message;

  LocationServiceStatus(this.success, this.message);
}

class LocationService {
  // 싱글톤 패턴 구현
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // 멤버 변수
  final Logger _logger = Logger();
  Position? _lastPosition;
  DateTime? _lastUpdateTime;
  final _positionController = StreamController<Position>.broadcast();
  bool _isInitialized = false;
  StreamSubscription<Position>? _positionSubscription;
  bool _isUpdating = false;
  
  // 상수 정의
  static const Duration _cacheValidDuration = Duration(minutes: 10);
  static const Duration _locationTimeout = Duration(seconds: 5);
  static const Duration _retryDelay = Duration(seconds: 2);
  static const int _maxRetries = 3;
  static const double _distanceThreshold = 10.0; // meters
  static const double _defaultLatitude = 37.5662952;  // 서울시청
  static const double _defaultLongitude = 126.9779692;

  // Getters
  Stream<Position> get positionStream => _positionController.stream;
  Position? get lastPosition => _lastPosition;
  bool get hasValidCache => _lastPosition != null && 
      _lastUpdateTime != null &&
      DateTime.now().difference(_lastUpdateTime!) < _cacheValidDuration;

  Future<Position> getCurrentLocation({bool forceUpdate = false}) async {
    if (!forceUpdate && hasValidCache) {
      _logger.d('LocationService: 캐시된 위치 정보 사용 - (${_lastPosition!.latitude}, ${_lastPosition!.longitude})');
      _startBackgroundLocationUpdate();
      return _lastPosition!;
    }

    _logger.d('LocationService: 현재 위치 가져오기 시도');

    try {
      final serviceStatus = await _checkLocationServices();
      if (!serviceStatus.success) {
        throw Exception(serviceStatus.message);
      }

      return await _retryFetchPosition();
    } catch (e) {
      _logger.e('LocationService: 위치 정보 가져오기 실패', e);
      return await _handleLocationError(e);
    }
  }

  Future<LocationServiceStatus> _checkLocationServices() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _logger.d('LocationService: 위치 서비스 상태 - $serviceEnabled');

      if (!serviceEnabled) {
        _logger.w('LocationService: 위치 서비스가 비활성화되어 있음');
        if (Platform.isIOS) {
          return LocationServiceStatus(
            false,
            '위치 서비스를 활성화해주세요. 설정 > 개인정보 보호 및 보안 > 위치 서비스에서 설정할 수 있습니다.'
          );
        }
        
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          return LocationServiceStatus(false, '위치 서비스를 활성화해주세요.');
        }
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Future.delayed(const Duration(milliseconds: 500));
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationServiceStatus(
            false,
            '위치 권한이 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.'
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationServiceStatus(
          false,
          '위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.'
        );
      }

      return LocationServiceStatus(true, '위치 서비스 준비 완료');
    } catch (e) {
      _logger.e('LocationService: 위치 서비스 상태 확인 중 에러 발생', e);
      return LocationServiceStatus(false, '위치 서비스 상태 확인 중 오류가 발생했습니다.');
    }
  }

  Future<Position> _retryFetchPosition() async {
    int retryCount = 0;
    Exception? lastError;

    // 먼저 마지막 알려진 위치 시도
    try {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        _logger.d('LocationService: 마지막 알려진 위치 사용');
        await _updatePosition(lastKnownPosition);
        
        // 백그라운드 업데이트 시작하고 마지막 알려진 위치 반환
        _startBackgroundLocationUpdate();
        return lastKnownPosition;
      }
    } catch (e) {
      _logger.w('LocationService: 마지막 알려진 위치 가져오기 실패', e);
    }

    // 현재 위치 가져오기 시도
    while (retryCount < _maxRetries) {
      try {
        if (retryCount > 0) {
          _logger.d('LocationService: 위치 정보 가져오기 재시도 ($retryCount/$_maxRetries)');
          await Future.delayed(_retryDelay);
        }

        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.reduced,
          timeLimit: _locationTimeout,
          forceAndroidLocationManager: true,
        );

        await _updatePosition(position);
        _logger.i('LocationService: 현재 위치 획득 성공');
        
        // 백그라운드 업데이트 시작
        _startBackgroundLocationUpdate();
        return position;

      } on TimeoutException catch (e) {
        lastError = e;
        _logger.w('LocationService: 위치 정보 가져오기 타임아웃 (시도 ${retryCount + 1}/$_maxRetries)');
        
        // 마지막 시도에서 타임아웃 발생 시 낮은 정확도로 재시도
        if (retryCount == _maxRetries - 1) {
          try {
            final lowAccuracyPosition = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.lowest,
              timeLimit: const Duration(seconds: 3),
              forceAndroidLocationManager: true,
            );
            
            await _updatePosition(lowAccuracyPosition);
            _startBackgroundLocationUpdate();
            return lowAccuracyPosition;
          } catch (e) {
            _logger.w('LocationService: 낮은 정확도 위치 획득 실패', e);
          }
        }
      } catch (e) {
        lastError = e as Exception;
        _logger.e('LocationService: 위치 정보 가져오기 실패 (시도 ${retryCount + 1}/$_maxRetries)', e);
      }

      retryCount++;
    }

    _logger.w('LocationService: 모든 위치 획득 시도 실패, 기본 위치 사용');
    return await _handleLocationError(lastError ?? Exception('위치 정보를 가져올 수 없습니다.'));
  }

  Future<void> _startBackgroundLocationUpdate() async {
    if (_isUpdating) return;
    _isUpdating = true;

    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.reduced,
      distanceFilter: _distanceThreshold.toInt(),
      // timeLimit 제거 - 스트림은 계속 유지되어야 함
    );

    try {
      _positionSubscription?.cancel();
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          try {
            await _updatePosition(position);
            _logger.i('LocationService: 스트림에서 위치 업데이트 - (${position.latitude}, ${position.longitude})');
          } catch (e) {
            _logger.e('LocationService: 위치 업데이트 중 에러', e);
          }
        },
        onError: (error) {
          _logger.e('LocationService: 위치 스트림 에러', error);
          // 에러 발생 시 스트림 재시작 시도
          _isUpdating = false;
          _restartBackgroundUpdate();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _logger.e('LocationService: 위치 스트림 시작 실패', e);
      _isUpdating = false;
    }
  }

  Future<void> _restartBackgroundUpdate() async {
    if (!_isUpdating) {
      _logger.d('LocationService: 위치 스트림 재시작 시도');
      await Future.delayed(const Duration(seconds: 1));
      _startBackgroundLocationUpdate();
    }
  }

  Future<Position> _handleLocationError(dynamic error) async {
    _logger.e('LocationService: 위치 정보 가져오기 실패 - $error');
    
    if (_lastPosition != null) {
      _logger.d('LocationService: 마지막 저장된 위치 사용');
      return _lastPosition!;
    }
    
    _logger.d('LocationService: 기본 위치 사용');
    final defaultPosition = _getDefaultPosition();
    await _updatePosition(defaultPosition);
    return defaultPosition;
  }

  Future<void> _updatePosition(Position position) async {
    final bool isSignificantChange = _lastPosition == null || 
      Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      ) > _distanceThreshold;

    if (isSignificantChange) {
      _lastPosition = position;
      _lastUpdateTime = DateTime.now();
      _positionController.add(position);
      _logger.i('LocationService: 위치 정보 업데이트 - (${position.latitude}, ${position.longitude})');
    }
  }

  Position _getDefaultPosition() {
    return Position(
      longitude: _defaultLongitude,
      latitude: _defaultLatitude,
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

  Future<void> forceRefresh() async {
    _logger.d('LocationService: 위치 정보 강제 새로고침');
    _isUpdating = false;
    await getCurrentLocation(forceUpdate: true);
  }
  
  void clearCache() {
    _logger.d('LocationService: 위치 정보 캐시 초기화');
    _lastPosition = null;
    _lastUpdateTime = null;
    _isUpdating = false;
  }

Future<void> dispose() async {
  _logger.d('LocationService: 리소스 정리');
  _isUpdating = false;
  if (_positionSubscription != null) {
    await _positionSubscription!.cancel();
    _positionSubscription = null;
  }
  await _positionController.close();
}
}