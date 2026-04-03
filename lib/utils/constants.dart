// 백엔드 API 기본 URL
// 개발: http://localhost:3000
// 프로덕션: Vercel 배포 URL로 교체
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:3000',
);

// 음식 카테고리 목록
const List<String> foodCategories = [
  '한식',
  '일식',
  '중식',
  '양식',
  '분식',
  '해산물',
  '고기',
  '치킨',
  '피자',
  '베이커리',
  '디저트',
  '비건',
];

// 카카오 맵 설정
const double defaultMapLat = 37.5665; // 서울시청 위도
const double defaultMapLng = 126.9780; // 서울시청 경도
const int defaultMapZoomLevel = 12;

// 마커 색상
const int markerColorMeal = 0xFFFF5722; // 주황 (deepOrange)
const int markerColorCafe = 0xFF795548; // 갈색 (brown)
const int polylineColor = 0xFF888888; // 회색

// 인기 여행 지역
const List<String> popularRegions = [
  '강릉',
  '제주',
  '부산',
  '경주',
  '여수',
  '전주',
  '속초',
  '춘천',
  '양양',
  '통영',
  '대구',
  '광주',
];
