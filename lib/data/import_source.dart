import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ImportSource {
  instagram,
  tiktok,
  naverBlog,
  kakaoMap,
  gallery,
  manual,
}

extension ImportSourceX on ImportSource {
  String get label => switch (this) {
        ImportSource.instagram => 'Instagram',
        ImportSource.tiktok => 'TikTok',
        ImportSource.naverBlog => '네이버 블로그',
        ImportSource.kakaoMap => '카카오맵 공유',
        ImportSource.gallery => '내 사진 갤러리',
        ImportSource.manual => '직접 검색·핀',
      };

  String get hint => switch (this) {
        ImportSource.instagram => '인스타그램 게시물 링크에서 장소를 추출해요',
        ImportSource.tiktok => '틱톡 영상 링크에서 장소를 추출해요',
        ImportSource.naverBlog => '리뷰가 풍부한 한국 블로그에서 추출',
        ImportSource.kakaoMap => '카카오맵 공유 링크 즉시 임포트',
        ImportSource.gallery => '갤러리 EXIF GPS로 자동 추출',
        ImportSource.manual => '지도에서 핀을 찍거나 검색해요',
      };

  IconData get icon => switch (this) {
        ImportSource.instagram => Icons.camera_alt_outlined,
        ImportSource.tiktok => Icons.music_video_outlined,
        ImportSource.naverBlog => Icons.article_outlined,
        ImportSource.kakaoMap => Icons.map_outlined,
        ImportSource.gallery => Icons.photo_library_outlined,
        ImportSource.manual => Icons.search,
      };

  Color get brandColor => switch (this) {
        ImportSource.instagram => AppColors.srcInstagram,
        ImportSource.tiktok => AppColors.srcTiktok,
        ImportSource.naverBlog => AppColors.srcNaver,
        ImportSource.kakaoMap => AppColors.srcKakao,
        ImportSource.gallery => AppColors.srcGallery,
        ImportSource.manual => AppColors.srcManual,
      };

  String get badgeLabel => switch (this) {
        ImportSource.instagram => 'IG',
        ImportSource.tiktok => 'TT',
        ImportSource.naverBlog => 'BLOG',
        ImportSource.kakaoMap => 'MAP',
        ImportSource.gallery => 'PHOTO',
        ImportSource.manual => 'PIN',
      };
}
