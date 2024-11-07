// lib/services/library_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import './vworld_service.dart';
import '../models/api_exception.dart';

// To print log
import 'dart:developer' as developer;

class LibraryService {
  final String baseUrl = "http://data4library.kr/api";
  final String authKey = dotenv.env['LIBRARY_DATANARU_API_KEY']!;
  final VWorldService _vworldService = VWorldService();

  Future<List<Map<String, dynamic>>> fetchLibrariesWithBook(
    String isbn, 
    Position userLocation
  ) async {
    try {
      developer.log('도서관 검색 시작: ISBN=$isbn');
      
      // 1. 현재 위치의 광역시/도 지역 코드만 가져옴
      final regionCodes = await _vworldService.getRegionCodes(userLocation);
      final regionCode = regionCodes['region']; // 광역시/도 코드만 사용
      
      developer.log('지역 코드 조회 완료: region=$regionCode');
      
      // 2. 해당 지역의 도서관 중 이 책을 소장한 도서관 검색
      final url = Uri.parse(
        "$baseUrl/libSrchByBook?"
        "authKey=$authKey"
        "&isbn=$isbn"
        "&region=$regionCode"
        "&format=json"
      );
      
      developer.log('도서관 API 요청: $url');
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw ApiException('도서관 검색 시간 초과'),
      );
      
      if (response.statusCode != 200) {
        throw ApiException('도서관 정보 조회 실패', statusCode: response.statusCode);
      }

      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> librariesData = jsonData['response']['libs'] ?? [];
      
      if (librariesData.isEmpty) {
        developer.log('검색된 도서관 없음');
        return [];
      }

      // 3. 각 도서관의 위치 정보로 거리 계산 및 정렬
      final libraries = librariesData.map((library) {
        try {
          final double lat = double.parse(library['lib']['latitude'] ?? '0');
          final double lng = double.parse(library['lib']['longitude'] ?? '0');
          
          final double distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            lat,
            lng,
          );

          return {
            'libCode': library['lib']['libCode'],
            'name': library['lib']['libName'],
            'address': library['lib']['address'],
            'tel': library['lib']['tel'],
            'latitude': lat.toString(),
            'longitude': lng.toString(),
            'distance': distance,
          };
        } catch (e) {
          developer.log('도서관 정보 처리 오류 (${library['lib']['libName']})', error: e);
          return null;
        }
      })
      .where((lib) => lib != null)
      .cast<Map<String, dynamic>>()
      .toList()
      ..sort((a, b) => a['distance'].compareTo(b['distance']));

      // 4. 가까운 순서대로 대출 가능 여부 확인
      final availabilityFutures = libraries.map((lib) async {
        try {
          final availabilityUrl = Uri.parse(
            "$baseUrl/bookExist?"
            "authKey=$authKey"
            "&libCode=${lib['libCode']}"
            "&isbn13=$isbn"
            "&format=json"
          );

          final availResponse = await http.get(availabilityUrl).timeout(
            const Duration(seconds: 3),
          );
          
          if (availResponse.statusCode != 200) return null;
          
          final availData = json.decode(availResponse.body);
          final hasBook = availData['response']?['result']?['hasBook'] ?? "N";
          final loanAvailable = availData['response']?['result']?['loanAvailable'] ?? "N";
          
          // hasBook이 "Y"이고 실제 있는 도서관만 반환
          if (hasBook == "Y") {
            return {...lib, 'loanAvailable': loanAvailable};
          }
          return null;
          
        } catch (e) {
          developer.log('대출 가능 여부 확인 오류 (${lib['name']})', error: e);
          return null;
        }
      });

      final results = (await Future.wait(availabilityFutures))
          .where((lib) => lib != null)
          .cast<Map<String, dynamic>>()
          .toList();

      developer.log('검색된 도서관 수: ${results.length}');
      developer.log('대출 가능한 도서관 수: ${results.where((lib) => lib['loanAvailable'] == "Y").length}');

      return results;

    } catch (e) {
      developer.log('도서관 검색 오류', error: e);
      if (e is ApiException) rethrow;
      throw ApiException('도서관 정보 조회 중 오류 발생: $e');
    }
  }
}