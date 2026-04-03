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
