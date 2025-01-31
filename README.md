# Aniwhere Flutter App

애니메이션 작품 판매 플랫폼 Aniwhere의 Flutter 모바일 애플리케이션입니다.

![aniwhere_detail](https://github.com/user-attachments/assets/5fa00aaf-a871-4f7c-93a2-a760073bd0b7)

## 주요 기능

- 작품 목록 조회 및 검색
- 연도별/카테고리별 작품 분류
- 장바구니 기능
- 주문 및 결제 시스템
- 회원 관리 (로그인/회원가입)
- 성인 인증 시스템
- 카카오 소셜 로그인

## 사용된 주요 라이브러리

### UI/UX

- `google_fonts: ^6.1.0`: 구글 폰트 적용
- `cached_network_image: ^3.3.1`: 이미지 캐싱 처리

### 상태 관리

- `provider: ^6.1.1`: 전역 상태 관리 (사용자 정보, 주문 정보 등)

### 네트워크 통신

- `http: ^1.2.0`: REST API 통신

### 데이터 처리

- `intl: ^0.18.0`: 날짜/숫자 포맷팅
- `shared_preferences: ^2.2.2`: 로컬 데이터 저장

### 소셜 로그인

- `kakao_flutter_sdk: ^1.9.6`: 카카오 로그인 연동
- `kakao_flutter_sdk_user: ^1.9.6`: 카카오 사용자 정보 관리

### 주요 페이지

- `home_page.dart`: 메인 화면
- `branch_page.dart`: 연도별 작품 목록
- `product_detail_page.dart`: 작품 상세 정보
- `cart_page.dart`: 장바구니
- `order_page.dart`: 주문/결제
- `login_page.dart`: 로그인
- `join_page.dart`: 회원가입
- `my_page.dart`: 마이페이지

## 설치 및 실행

1. Flutter 개발 환경 설정

   - Flutter SDK 설치 (https://flutter.dev/docs/get-started/install)
   - Android Studio 또는 VS Code 설치
   - Flutter 및 Dart 플러그인 설치

2. 프로젝트 클론 및 설정

   ```bash
   git clone https://github.com/your-username/aniwhere-flutter.git
   cd aniwhere-flutter
   flutter pub get
   ```

3. 환경 설정

   - `lib/config/` 디렉토리에서 환경변수 설정
   - 개발 환경: `--dart-define=ENVIRONMENT=dev`
   - 프로덕션 환경: `--dart-define=ENVIRONMENT=prod`

4. 실행

   ```bash
   # 개발 환경
   flutter run --dart-define=ENVIRONMENT=dev

   # 프로덕션 환경
   flutter run --dart-define=ENVIRONMENT=prod
   ```

5. 빌드

   ```bash
   # Android APK 빌드
   flutter build apk --release --dart-define=ENVIRONMENT=prod

   # iOS 빌드
   flutter build ios --release --dart-define=ENVIRONMENT=prod
   ```

## 프로젝트 구조

## 시현영상

https://www.youtube.com/watch?v=yDXctUkvOLI&t=97s
