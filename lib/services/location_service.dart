// services/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final Logger _logger = Logger();
  Position? _lastPosition;
  DateTime? _lastUpdateTime;
  final _positionController = StreamController<Position>.broadcast();
  bool _isInitialized = false;
  StreamSubscription<Position>? _positionSubscription;

  // 위치 정보 캐시 유효 시간 (10분)
  static const Duration _cacheValidDuration = Duration(minutes: 10);

  Stream<Position> get positionStream => _positionController.stream;
  Position? get lastPosition => _lastPosition;
  bool get hasValidCache => _lastPosition != null && 
      _lastUpdateTime != null &&
      DateTime.now().difference(_lastUpdateTime!) < _cacheValidDuration;

  Future<Position> getCurrentLocation({bool forceUpdate = false}) async {
    // 캐시된 위치가 유효하고 강제 업데이트가 아닌 경우
    if (!forceUpdate && hasValidCache) {
      _logger.d('LocationService: 캐시된 위치 정보 사용 - (${_lastPosition!.latitude}, ${_lastPosition!.longitude})');
      return _lastPosition!;
    }

    _logger.d('LocationService: 현재 위치 가져오기 시도');

    try {
      await _checkLocationServices();
      return await _fetchPosition();
    } catch (e) {
      return await _handleLocationError(e);
    }
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    _logger.d('LocationService: 위치 서비스 상태 - $serviceEnabled');

    if (!serviceEnabled) {
      _logger.w('LocationService: 위치 서비스가 비활성화되어 있음');
      if (Platform.isIOS) {
        throw Exception('위치 서비스를 활성화해주세요. 설정 > 개인정보 보호 및 보안 > 위치 서비스에서 설정할 수 있습니다.');
      }
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        throw Exception('위치 서비스를 활성화해주세요.');
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.');
    }
  }

  Future<Position> _fetchPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));

      await _updatePosition(position);
      return position;
    } on TimeoutException {
      final lastKnownPosition = await Geolocator.getLastKnownPosition();
      if (lastKnownPosition != null) {
        await _updatePosition(lastKnownPosition);
        return lastKnownPosition;
      }
      return _getDefaultPosition();
    }
  }

  Future<void> _updatePosition(Position position) async {
    _lastPosition = position;
    _lastUpdateTime = DateTime.now();
    _positionController.add(position);

    if (!_isInitialized) {
      await _initializePositionStream();
      _isInitialized = true;
    }

    _logger.i('LocationService: 위치 정보 업데이트 - (${position.latitude}, ${position.longitude})');
  }

  Future<Position> _handleLocationError(dynamic error) async {
    _logger.e('LocationService: 위치 정보 가져오기 실패 - $error');
    
    if (_lastPosition != null) {
      return _lastPosition!;
    }
    
    final lastKnownPosition = await Geolocator.getLastKnownPosition();
    if (lastKnownPosition != null) {
      await _updatePosition(lastKnownPosition);
      return lastKnownPosition;
    }
    
    return _getDefaultPosition();
  }

  Position _getDefaultPosition() {
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

  Future<void> _initializePositionStream() async {
    _logger.d('LocationService: 위치 스트림 초기화');
    
    await _positionSubscription?.cancel();
    
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) async {
        if (_shouldUpdatePosition(position)) {
          await _updatePosition(position);
        }
      },
      onError: (error) {
        _logger.e('LocationService: 위치 스트림 에러 - $error');
      },
      cancelOnError: false,
    );
  }

  bool _shouldUpdatePosition(Position newPosition) {
    if (_lastPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    
    final timeSinceLastUpdate = DateTime.now().difference(_lastUpdateTime!);
    
    // 100m 이상 이동했거나 마지막 업데이트로부터 10분이 지났을 때
    return distance >= 100 || timeSinceLastUpdate >= _cacheValidDuration;
  }

  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _positionController.close();
  }
}