class LocalGuide {
  final String id;
  final String name;
  final String role; // e.g., 'Tour Guide', 'Porter', 'Jeep Driver'
  final String region; // e.g., 'Hunza', 'Skardu', 'Swat'
  final double rating;
  final double dailyRatePkr;
  final int tripCount;
  final String? imageUrl;
  final bool isVerified;
  final bool isFemaleFriendly;

  LocalGuide({
    required this.id,
    required this.name,
    required this.role,
    required this.region,
    required this.rating,
    required this.dailyRatePkr,
    required this.tripCount,
    this.imageUrl,
    this.isVerified = false,
    this.isFemaleFriendly = false,
  });
}

class GuideMockService {
  static List<LocalGuide> fetchMockGuides() {
    return [
      LocalGuide(
        id: '1',
        name: 'Ali Raza',
        role: 'Tour Guide',
        region: 'Hunza Valley',
        rating: 4.9,
        dailyRatePkr: 5000,
        tripCount: 120,
        isVerified: true,
        isFemaleFriendly: true,
      ),
      LocalGuide(
        id: '2',
        name: 'sher Khan',
        role: 'Jeep Driver',
        region: 'Naran / Kaghan',
        rating: 4.7,
        dailyRatePkr: 8000,
        tripCount: 300,
        isVerified: true,
      ),
      LocalGuide(
        id: '3',
        name: 'Musa',
        role: 'Porter',
        region: 'Skardu (K2 Basecamp)',
        rating: 4.8,
        dailyRatePkr: 3500,
        tripCount: 85,
        isVerified: true,
      ),
      LocalGuide(
        id: '4',
        name: 'Bibi Zainab',
        role: 'Tour Guide',
        region: 'Lahore',
        rating: 4.9,
        dailyRatePkr: 3000,
        tripCount: 45,
        isVerified: true,
        isFemaleFriendly: true,
      ),
      LocalGuide(
        id: '5',
        name: 'Wali',
        role: 'Jeep Driver',
        region: 'Swat Valley (Kalam)',
        rating: 4.9,
        dailyRatePkr: 7500,
        tripCount: 220,
        isVerified: true,
        isFemaleFriendly: true,
      ),
    ];
  }
}
