import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum UserLevel {
  member,
  athlete,
  pro,
  elite;

  String get displayNameFa {
    switch (this) {
      case UserLevel.member:
        return 'عضو (Member)';
      case UserLevel.athlete:
        return 'ورزشکار (Athlete)';
      case UserLevel.pro:
        return 'حرفه‌ای (Pro)';
      case UserLevel.elite:
        return 'نخبه طلایی (Elite)';
    }
  }

  String get displayNameEn {
    switch (this) {
      case UserLevel.member:
        return 'Member';
      case UserLevel.athlete:
        return 'Athlete';
      case UserLevel.pro:
        return 'Pro';
      case UserLevel.elite:
        return 'Elite';
    }
  }

  Color get badgeColor {
    switch (this) {
      case UserLevel.member:
        return const Color(0xFF78909C);
      case UserLevel.athlete:
        return AppColors.lime;
      case UserLevel.pro:
        return const Color(0xFFAB47BC);
      case UserLevel.elite:
        return AppColors.gold;
    }
  }

  static UserLevel fromString(String? val) {
    if (val == null) return UserLevel.member;
    switch (val.toLowerCase()) {
      case 'athlete':
        return UserLevel.athlete;
      case 'pro':
        return UserLevel.pro;
      case 'elite':
        return UserLevel.elite;
      default:
        return UserLevel.member;
    }
  }
}
