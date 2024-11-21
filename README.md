# 📚 Welcome to CHACK Github

[![GitHub Stars](https://img.shields.io/github/stars/CHACK-team/CHACK-project?style=social)](https://github.com/CHACK-team/CHACK-project)
[![Flutter](https://img.shields.io/badge/Flutter-3.19.3-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3.1-blue.svg)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-latest-orange.svg)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 1. CHACK 소개

### 개요
채크(CHACK)는 독서 습관 형성을 위한 모바일 애플리케이션입니다. 사용자가 자신의 서재에 책을 추가하고 읽은 내용을 기록하며, 목표 설정을 통해 독서 활동을 체계적으로 관리할 수 있게 합니다. 또한, 시간 관리 기능을 제공하여 독서 시간을 효율적으로 활용할 수 있도록 도와줍니다.

이를 통해 자연스럽게 독서가 사용자 개개인의 일상에 스며들고, 꾸준한 독서를 통해 지식의 확장과 개인의 성장을 도모할 수 있습니다.

### 주요 기능
- 📖 개인 서재 관리
- ⏱️ 독서 타이머
- 📊 독서 통계 및 분석
- 🎯 독서 목표 설정
- 📝 독서 기록 및 메모
- 📍 주변 도서관 찾기
- 📚 도서 추천 시스템

### 기술 스택
<table>
    <tr>
        <td>프레임워크</td>
        <td>
            <img src="https://storage.googleapis.com/cms-storage-bucket/ec64036b4eacc9f3fd73.svg" width="30" height="30"/>
            Flutter 3.19.3
        </td>
    </tr>
    <tr>
        <td>언어</td>
        <td>
            <img src="https://dart.dev/assets/img/shared/dart/logo+text/horizontal/white.svg" width="60" height="30"/>
            Dart 3.3.1
        </td>
    </tr>
    <tr>
        <td>백엔드</td>
        <td>
            <img src="https://www.vectorlogo.zone/logos/firebase/firebase-icon.svg" width="30" height="30"/>
            Firebase
        </td>
    </tr>
    <tr>
        <td>상태관리</td>
        <td>Provider</td>
    </tr>
    <tr>
        <td>데이터베이스</td>
        <td>Cloud Firestore</td>
    </tr>
    <tr>
        <td>인증</td>
        <td>Firebase Authentication</td>
    </tr>
    <tr>
        <td>외부 API</td>
        <td>도서관 정보나루, Naver 책 검색 API, VWorld API</td>
    </tr>
</table>

### 주요 Dependencies
| Package | Version | Description | Link |
|---------|---------|-------------|------|
| **상태 관리** |
| [provider](https://pub.dev/packages/provider) | ^6.1.1 | 상태 관리를 위한 패키지 | [![pub package](https://img.shields.io/pub/v/provider.svg)](https://pub.dev/packages/provider) |
| **Firebase** |
| [firebase_core](https://pub.dev/packages/firebase_core) | ^2.32.0 | Firebase 코어 기능 | [![pub package](https://img.shields.io/pub/v/firebase_core.svg)](https://pub.dev/packages/firebase_core) |
| [firebase_auth](https://pub.dev/packages/firebase_auth) | ^4.15.3 | Firebase 인증 | [![pub package](https://img.shields.io/pub/v/firebase_auth.svg)](https://pub.dev/packages/firebase_auth) |
| [cloud_firestore](https://pub.dev/packages/cloud_firestore) | ^4.17.5 | Cloud Firestore | [![pub package](https://img.shields.io/pub/v/cloud_firestore.svg)](https://pub.dev/packages/cloud_firestore) |
| [firebase_storage](https://pub.dev/packages/firebase_storage) | ^11.2.0 | Firebase Storage | [![pub package](https://img.shields.io/pub/v/firebase_storage.svg)](https://pub.dev/packages/firebase_storage) |
| **UI/UX** |
| [flutter_svg](https://pub.dev/packages/flutter_svg) | ^2.0.9 | SVG 렌더링 | [![pub package](https://img.shields.io/pub/v/flutter_svg.svg)](https://pub.dev/packages/flutter_svg) |
| [percent_indicator](https://pub.dev/packages/percent_indicator) | ^4.2.2 | 진행률 표시 위젯 | [![pub package](https://img.shields.io/pub/v/percent_indicator.svg)](https://pub.dev/packages/percent_indicator) |
| [fl_chart](https://pub.dev/packages/fl_chart) | ^0.65.0 | 차트 위젯 | [![pub package](https://img.shields.io/pub/v/fl_chart.svg)](https://pub.dev/packages/fl_chart) |
| [table_calendar](https://pub.dev/packages/table_calendar) | ^3.0.10 | 캘린더 위젯 | [![pub package](https://img.shields.io/pub/v/table_calendar.svg)](https://pub.dev/packages/table_calendar) |
| **데이터 저장** |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | ^2.2.0 | 로컬 데이터 저장 | [![pub package](https://img.shields.io/pub/v/shared_preferences.svg)](https://pub.dev/packages/shared_preferences) |
| [hive](https://pub.dev/packages/hive) | ^2.2.3 | NoSQL 데이터베이스 | [![pub package](https://img.shields.io/pub/v/hive.svg)](https://pub.dev/packages/hive) |
| [hive_flutter](https://pub.dev/packages/hive_flutter) | ^1.1.0 | Flutter용 Hive | [![pub package](https://img.shields.io/pub/v/hive_flutter.svg)](https://pub.dev/packages/hive_flutter) |
| **위치 서비스** |
| [geolocator](https://pub.dev/packages/geolocator) | ^8.0.0 | 위치 정보 | [![pub package](https://img.shields.io/pub/v/geolocator.svg)](https://pub.dev/packages/geolocator) |
| [geocoding](https://pub.dev/packages/geocoding) | ^2.1.0 | 위치 정보 변환 | [![pub package](https://img.shields.io/pub/v/geocoding.svg)](https://pub.dev/packages/geocoding) |
| **기타** |
| [permission_handler](https://pub.dev/packages/permission_handler) | ^10.2.0 | 권한 관리 | [![pub package](https://img.shields.io/pub/v/permission_handler.svg)](https://pub.dev/packages/permission_handler) |
| [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | ^5.2.1 | 환경 변수 관리 | [![pub package](https://img.shields.io/pub/v/flutter_dotenv.svg)](https://pub.dev/packages/flutter_dotenv) |
| [http](https://pub.dev/packages/http) | ^0.13.4 | HTTP 통신 | [![pub package](https://img.shields.io/pub/v/http.svg)](https://pub.dev/packages/http) |

## 2. 프로젝트 설정

### 요구사항
- Flutter SDK 3.19.3 이상
- Dart SDK 3.3.1 이상
- Android Studio / VS Code
- Firebase 프로젝트

### 설치 방법
1. 저장소 클론
```bash
git clone https://github.com/CHACK-team/CHACK-project.git
cd CHACK-project
```

2. 종속성 설치
```bash
flutter pub get
```

3. Firebase 설정
- `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 파일을 각각의 플랫폼 디렉토리에 추가
- Firebase 콘솔에서 필요한 서비스 활성화

4. 환경 변수 설정
`.env` 파일을 프로젝트 루트에 생성하고 필요한 API 키를 추가:
```
NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret
LIBRARY_DATANARU_API_KEY=your_library_datanaru_api_key
VWORLD_API_KEY=your_vworld_api_key
```

5. 실행
```bash
flutter run
```

## 3. Commit 규칙
- 하나의 커밋에 하나의 수정 사항을 포함하도록 진행
- 기능 단위 또는 모듈 단위 커밋을 지향
```
<type>(<scope>): <subject>

<body>

<footer>
```

* 주요 커밋 타입:
    * `feat`: 사용자에게 새로운 기능 추가
    * `fix`: 버그 수정
    * `docs`: 문서 변경
    * `style`: 코드 형식 변경
    * `refactor`: 코드 리팩토링
    * `test`: 테스트 추가 및 수정

## 4. 팀 소개
| Profile Image | Name | Role | Contacts |
|--------------|------|------|-----------|
| | 강연수 | Frontend Developer | Email: yskang009@gmail.com<br>GitHub: [@mamemomif](https://github.com/mamemomif) |
| | 문병진 | Frontend Developer | Email: qudwls5778@naver.com<br>GitHub: [@Moonbjin](https://github.com/Moonbjin) |
| | 조현주 | UI/UX 설계 / Frontend Developer | Email: butter0488@gmail.com<br>GitHub: [@hjuump](https://github.com/hjuump) |
| | 홍영준 | Backend Developer | Email: moejihong@gmail.com<br>GitHub: [@HONGMOEJI](https://github.com/HONGMOEJI) |

## 5. 기여하기
1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 6. 문의하기
프로젝트에 대한 문의사항이나 버그 리포트는 [Issues](https://github.com/CHACK-team/CHACK-project/issues)에 등록해주세요.

<p align="center">Made with ❤️ by CHACK Team</p>

---
⭐️ 이 프로젝트가 마음에 드셨다면 Star를 눌러주세요!