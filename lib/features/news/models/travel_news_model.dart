import 'package:flutter/material.dart';

enum TravelSafetyStatus {
  safe,
  caution,
  warning,
}

class ForecastDay {
  final String dayName;
  final int temp;
  final String condition;
  final IconData icon;

  const ForecastDay({
    required this.dayName,
    required this.temp,
    required this.condition,
    required this.icon,
  });
}

class TravelNewsItem {
  final String id;
  final String placeName;
  final String region;
  final TravelSafetyStatus safetyStatus;
  final String statusTitle;
  final String headline;
  final String fullNewsReport;
  final int currentTemp;
  final String tempUnit;
  final String weatherCondition;
  final IconData weatherIcon;
  final int feelsLike;
  final String precipitationChance;
  final String windSpeed;
  final String humidity;
  final String disasterAlert;
  final String roadCondition;
  final String vehicleRecommendation;
  final String emergencyHelpline;
  final String helplineName;
  final String officialSource;
  final DateTime updatedAt;
  final List<ForecastDay> forecast;
  final String imageUrl;

  const TravelNewsItem({
    required this.id,
    required this.placeName,
    required this.region,
    required this.safetyStatus,
    required this.statusTitle,
    required this.headline,
    required this.fullNewsReport,
    required this.currentTemp,
    this.tempUnit = '°C',
    required this.weatherCondition,
    required this.weatherIcon,
    required this.feelsLike,
    required this.precipitationChance,
    required this.windSpeed,
    required this.humidity,
    required this.disasterAlert,
    required this.roadCondition,
    required this.vehicleRecommendation,
    required this.emergencyHelpline,
    required this.helplineName,
    required this.officialSource,
    required this.updatedAt,
    required this.forecast,
    required this.imageUrl,
  });

  Color get statusColor {
    switch (safetyStatus) {
      case TravelSafetyStatus.safe:
        return const Color(0xFF10B981); // Emerald Green
      case TravelSafetyStatus.caution:
        return const Color(0xFFF59E0B); // Amber / Yellow
      case TravelSafetyStatus.warning:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get statusBgColor {
    switch (safetyStatus) {
      case TravelSafetyStatus.safe:
        return const Color(0xFFECFDF5);
      case TravelSafetyStatus.caution:
        return const Color(0xFFFFFBEB);
      case TravelSafetyStatus.warning:
        return const Color(0xFFFEF2F2);
    }
  }

  IconData get statusIcon {
    switch (safetyStatus) {
      case TravelSafetyStatus.safe:
        return Icons.verified_user_rounded;
      case TravelSafetyStatus.caution:
        return Icons.warning_amber_rounded;
      case TravelSafetyStatus.warning:
        return Icons.dangerous_rounded;
    }
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final difference = now.difference(updatedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[updatedAt.month - 1];
      final hour = updatedAt.hour.toString().padLeft(2, '0');
      final minute = updatedAt.minute.toString().padLeft(2, '0');
      return '${updatedAt.day} $month ${updatedAt.year}, $hour:$minute PKT';
    }
  }

  String get fullDateString {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[updatedAt.month - 1];
    final hour = updatedAt.hour % 12 == 0 ? 12 : updatedAt.hour % 12;
    final minute = updatedAt.minute.toString().padLeft(2, '0');
    final amPm = updatedAt.hour >= 12 ? 'PM' : 'AM';
    return '${updatedAt.day} $month ${updatedAt.year} • $hour:$minute $amPm PKT';
  }
}
