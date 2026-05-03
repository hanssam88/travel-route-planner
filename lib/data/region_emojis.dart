const Map<String, String> regionEmojis = {
  '강릉': '🌊',
  '제주': '🍊',
  '부산': '🐟',
  '경주': '🏯',
  '여수': '🌃',
  '전주': '🍚',
  '속초': '⛰️',
  '춘천': '🚣',
  '양양': '🏄',
  '통영': '⛵',
  '대구': '🍜',
  '광주': '🎨',
};

String emojiForRegion(String region) => regionEmojis[region] ?? '📍';
