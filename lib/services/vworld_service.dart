import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_exception.dart';

// To print log
import 'dart:developer' as developer;

class VWorldService {
  final String apiKey = dotenv.env['VWORLD_API_KEY']!;
  final String baseUrl = 'https://api.vworld.kr/req/data';
  
  static const String _cacheKey = 'vworld_region_codes';
  static const Duration _cacheDuration = Duration(minutes: 30);

  static const Map<String, String> _data4LibraryRegionMapping = {
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

  // data4library API 지역 코드 반환 함수
  String? getData4LibraryRegionCode(String? vWorldSido) {
    return _data4LibraryRegionMapping[vWorldSido];
  }

  // getRegionCodes 메서드 내에서 매핑된 지역 코드를 반환
  Future<Map<String, String>> getRegionCodes(Position position) async {
    try {
      developer.log('지역 코드 조회 시작: lat=${position.latitude}, lng=${position.longitude}');

      // 캐시 확인
      final cachedData = await _getCachedRegionCodes(position);
      developer.log('캐시된 지역 코드 ${cachedData != null ? "찾음" : "없음"}');

      if (cachedData != null) {
        return cachedData;
      }

      final String point = 'POINT(${position.longitude} ${position.latitude})';
      final url = Uri.parse(
        '$baseUrl'
        '?service=data'
        '&request=GetFeature'
        '&data=LT_C_ADSIGG_INFO'
        '&key=$apiKey'
        '&format=json'
        '&geomFilter=$point'
        '&geometry=false'
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw ApiException('VWorld API 요청 시간 초과'),
      );
      developer.log('VWorld API 응답: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['response']['status'] == 'OK') {
          final feature = data['response']['result']['featureCollection']['features'][0];
          final properties = feature['properties'];
          
          final String sigCd = properties['sig_cd'].toString();
          final String vWorldSido = properties['full_nm'].toString().split(' ')[0];

          // data4library API에서 사용하는 region 코드로 변환
          final String? data4LibraryRegion = getData4LibraryRegionCode(vWorldSido);

          if (data4LibraryRegion == null) {
            throw ApiException("해당 지역의 data4library 지역 코드가 없습니다: $vWorldSido");
          }

          final result = {
            'region': data4LibraryRegion,  // data4library에서 사용할 지역 코드
            'dtl_region': sigCd,
            'sido': vWorldSido,
            'sigungu': properties['sig_kor_nm'].toString(),
          };

          // 결과 캐싱
          await _cacheRegionCodes(position, result);
          developer.log('조회된 지역 코드: $result');
          return result;
        } else {
          throw ApiException('해당 위치의 행정구역을 찾을 수 없습니다');
        }
      } else {
        throw ApiException('API 호출 실패', statusCode: response.statusCode);
      }
    } catch (e) {
      developer.log('지역 코드 조회 오류', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('지역 코드 조회 실패: $e');
    }
  }

  Future<Map<String, String>?> _getCachedRegionCodes(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cachedData = prefs.getString(_cacheKey);
    
    if (cachedData != null) {
      final cache = json.decode(cachedData);
      final timestamp = DateTime.parse(cache['timestamp']);
      
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        final double distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          (cache['latitude'] as num).toDouble(),
          (cache['longitude'] as num).toDouble(),
        );
        
        if (distance < 100) { // 100m 이내인 경우 캐시 사용
          final data = cache['data'] as Map<String, dynamic>;
          return data.map((key, value) => MapEntry(key, value.toString()));
        }
      }
    }
    return null;
  }

  Future<void> _cacheRegionCodes(Position position, Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'timestamp': DateTime.now().toIso8601String(),
      'latitude': position.latitude,
      'longitude': position.longitude,
      'data': data,
    };
    await prefs.setString(_cacheKey, json.encode(cacheData));
  }
}