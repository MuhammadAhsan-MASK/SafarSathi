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
  final bool isBroadcast;

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
    this.isBroadcast = false,
  });

  factory TravelNewsItem.fromFirestore(Map<String, dynamic> data, String docId) {
    // Parse safety status
    TravelSafetyStatus status = TravelSafetyStatus.safe;
    final statusStr = (data['safetyStatus'] ?? 'safe').toString().toLowerCase();
    if (statusStr == 'warning' || statusStr == 'danger' || statusStr == 'critical') {
      status = TravelSafetyStatus.warning;
    } else if (statusStr == 'caution' || statusStr == 'alert') {
      status = TravelSafetyStatus.caution;
    }

    // Parse timestamp
    DateTime parsedDate = DateTime.now();
    final createdAt = data['createdAt'];
    if (createdAt != null) {
      if (createdAt is DateTime) {
        parsedDate = createdAt;
      } else if (createdAt.runtimeType.toString().contains('Timestamp')) {
        try {
          parsedDate = (createdAt as dynamic).toDate();
        } catch (_) {}
      } else if (createdAt is String) {
        parsedDate = DateTime.tryParse(createdAt) ?? DateTime.now();
      }
    }

    // Weather icon selection based on text
    IconData weatherIcon = Icons.wb_sunny_rounded;
    final wCond = (data['weatherCondition'] ?? '').toString().toLowerCase();
    if (wCond.contains('snow') || wCond.contains('freeze') || wCond.contains('blizzard')) {
      weatherIcon = Icons.ac_unit_rounded;
    } else if (wCond.contains('rain') || wCond.contains('shower') || wCond.contains('storm')) {
      weatherIcon = Icons.grain_rounded;
    } else if (wCond.contains('cloud') || wCond.contains('fog') || wCond.contains('mist') || wCond.contains('overcast')) {
      weatherIcon = Icons.cloud_outlined;
    }

    int temp = 14;
    final rawTemp = data['currentTemp'];
    if (rawTemp is num) {
      temp = rawTemp.toInt();
    } else if (rawTemp != null) {
      temp = int.tryParse(rawTemp.toString()) ?? 14;
    }

    int feelsLike = temp - 2;
    final rawFeels = data['feelsLike'];
    if (rawFeels is num) {
      feelsLike = rawFeels.toInt();
    } else if (rawFeels != null) {
      feelsLike = int.tryParse(rawFeels.toString()) ?? (temp - 2);
    }

    return TravelNewsItem(
      id: docId,
      placeName: (data['placeName'] ?? 'Pakistan Region').toString(),
      region: (data['region'] ?? 'National Advisory').toString(),
      safetyStatus: status,
      statusTitle: (data['statusTitle'] != null && data['statusTitle'].toString().isNotEmpty)
          ? data['statusTitle'].toString()
          : (status == TravelSafetyStatus.warning
              ? 'Critical Road Advisory'
              : (status == TravelSafetyStatus.caution
                  ? 'Travel with Caution'
                  : 'Safe to Travel • All Clear')),
      headline: (data['headline'] ?? 'Travel advisory update from Admin Command Center').toString(),
      fullNewsReport: (data['fullNewsReport'] ?? data['message'] ?? 'Official advisory published for tourist safety.').toString(),
      currentTemp: temp,
      tempUnit: (data['tempUnit'] ?? '°C').toString(),
      weatherCondition: (data['weatherCondition'] ?? 'Seasonal Weather').toString(),
      weatherIcon: weatherIcon,
      feelsLike: feelsLike,
      precipitationChance: (data['precipitationChance'] ?? '15%').toString(),
      windSpeed: (data['windSpeed'] ?? '12 km/h').toString(),
      humidity: (data['humidity'] ?? '50%').toString(),
      disasterAlert: (data['disasterAlert'] ?? (status == TravelSafetyStatus.warning ? 'Active emergency travel notice in effect.' : 'Zero active disaster threats reported.')).toString(),
      roadCondition: (data['roadCondition'] ?? 'Check highway authorities before departure.').toString(),
      vehicleRecommendation: (data['vehicleRecommendation'] ?? 'Standard vehicles permitted').toString(),
      emergencyHelpline: (data['emergencyHelpline'] ?? '1122').toString(),
      helplineName: (data['helplineName'] ?? 'Rescue 1122 & Police Helpline').toString(),
      officialSource: (data['officialSource'] ?? 'SafarSathi Admin Broadcast').toString(),
      updatedAt: parsedDate,
      forecast: const [
        ForecastDay(dayName: 'Today', temp: 15, condition: 'Current', icon: Icons.wb_sunny_rounded),
        ForecastDay(dayName: 'Tomorrow', temp: 14, condition: 'Clear', icon: Icons.wb_sunny_outlined),
        ForecastDay(dayName: 'Next Day', temp: 13, condition: 'Mild', icon: Icons.cloud_outlined),
      ],
      imageUrl: (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
          ? data['imageUrl'].toString()
          : 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=600&auto=format&fit=crop&q=80',
      isBroadcast: true,
    );
  }

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
