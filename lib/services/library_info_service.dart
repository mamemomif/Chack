import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/recommended_books_service.dart';

class LibraryInfoProvider {
  final LocationService _locationService = LocationService();
  final RecommendedBooksService recommendedBooksService;

  LibraryInfoProvider({required this.recommendedBooksService});

  Position? _lastPosition;
  StreamSubscription<Position>? _locationSubscription;

  // 위치 정보 스트림 설정
  Future<void> setupLocationSubscription({
    required String isbn,
    required Function(String) onLibraryNameUpdate,
    required Function(String) onDistanceUpdate,
    required Function(String) onLoanStatusUpdate,
    required Function(String) onError,
  }) async {
    try {
      // 초기 위치 정보 가져오기
      _lastPosition = await _locationService.getCurrentLocation();
      if (_lastPosition != null) {
        await _fetchLibraryInfo(
          isbn: isbn,
          position: _lastPosition!,
          onLibraryNameUpdate: onLibraryNameUpdate,
          onDistanceUpdate: onDistanceUpdate,
          onLoanStatusUpdate: onLoanStatusUpdate,
          onError: onError,
        );
      }

      // 위치 변경 스트림 구독
      _locationSubscription =
          _locationService.positionStream.listen((position) {
        if (_shouldUpdateLocation(position)) {
          _lastPosition = position;
          _fetchLibraryInfo(
            isbn: isbn,
            position: position,
            onLibraryNameUpdate: onLibraryNameUpdate,
            onDistanceUpdate: onDistanceUpdate,
            onLoanStatusUpdate: onLoanStatusUpdate,
            onError: onError,
          );
        }
      });
    } catch (e) {
      onError('위치 정보를 가져오는 데 실패했습니다.');
    }
  }

  // 위치 업데이트 판단 로직
  bool _shouldUpdateLocation(Position newPosition) {
    if (_lastPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    return distance > 100; // 100m 이상 이동한 경우에만 업데이트
  }

  // 도서관 정보 가져오기
  Future<void> _fetchLibraryInfo({
    required String isbn,
    required Position position,
    required Function(String) onLibraryNameUpdate,
    required Function(String) onDistanceUpdate,
    required Function(String) onLoanStatusUpdate,
    required Function(String) onError,
  }) async {
    try {
      final libraryInfo = await recommendedBooksService.fetchLibrary(
        isbn,
        position,
      );

      if (libraryInfo == null || libraryInfo.isEmpty) {
        onLibraryNameUpdate('주변 도서관 정보가 없습니다.');
        onDistanceUpdate('');
        onLoanStatusUpdate('');
        return;
      }

      final name = libraryInfo['name'] ?? '도서관 정보 없음';
      final distance =
          '${((libraryInfo['distance'] as num).toDouble() / 1000).toStringAsFixed(1)}km';
      final loanStatus =
          libraryInfo['loanAvailable'] == 'Y' ? '대출 가능' : '대출 불가';

      onLibraryNameUpdate(name);
      onDistanceUpdate(distance);
      onLoanStatusUpdate(loanStatus);
    } catch (e) {
      onError('도서관 정보를 가져오는 데 실패했습니다.');
    }
  }

  // 위치 구독 해제
  void dispose() {
    _locationSubscription?.cancel();
  }
}
