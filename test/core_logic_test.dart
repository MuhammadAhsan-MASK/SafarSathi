import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_guide/core/cultural_calendar.dart';
import 'package:travel_guide/core/currency_provider.dart';
import 'package:travel_guide/core/favorites_provider.dart';
import 'package:travel_guide/core/pdf_service.dart';
import 'package:travel_guide/core/seed_data.dart';
import 'package:travel_guide/features/attractions/models/attraction_model.dart';
import 'package:travel_guide/features/budget/models/saved_trip_model.dart';
import 'package:travel_guide/features/budget/services/saved_trips_service.dart';
import 'package:travel_guide/features/news/services/travel_news_service.dart';
import 'package:travel_guide/features/transport/services/transport_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyProvider Tests', () {
    test('converts and formats across PKR, USD, GBP, EUR, and SAR accurately', () {
      final cp = CurrencyProvider();
      expect(cp.selectedCurrency, 'PKR');
      expect(cp.formatPrice(28000), 'Rs. 28000');

      cp.setCurrency('USD');
      expect(cp.convertFromPkr(28000), closeTo(100.0, 0.001));
      expect(cp.toPkr(100.0), closeTo(28000.0, 0.001));
      expect(cp.formatPrice(2800), '\$ 10.00');

      cp.setCurrency('GBP');
      expect(cp.formatPrice(3500), '£ 10.00');

      cp.setCurrency('INVALID');
      expect(cp.selectedCurrency, 'GBP');
    });
  });

  group('TransportService Route & Connecting Logic Tests', () {
    test('isRouteMatch handles aliases without substring false positives', () {
      // Attock must not match Swat (previously 'at' inside 'swat')
      expect(
        TransportService.isRouteMatch('Attock -> Islamabad', source: 'Swat', destination: 'Islamabad'),
        isFalse,
      );
      expect(
        TransportService.isRouteMatch('Karachi -> Lahore', source: 'KHI', destination: 'LHR'),
        isTrue,
      );
      expect(
        TransportService.isRouteMatch('Rawalpindi -> Hunza', source: 'Islamabad', destination: 'Hunza'),
        isTrue,
      );
      expect(
        TransportService.isRouteMatch('Dera-Ismail-Khan -> Islamabad', source: 'Dera-Ismail-Khan', destination: 'Islamabad'),
        isTrue,
      );
    });

    test('generateConnectingOptions blocks same-city and avoids ISB->Hunza via ISB', () {
      expect(TransportService.generateConnectingOptions('Hunza', 'Hunza'), isEmpty);
      expect(TransportService.generateConnectingOptions('Islamabad', 'Rawalpindi'), isEmpty);

      final isbToHunza = TransportService.generateConnectingOptions('Islamabad', 'Hunza');
      expect(isbToHunza, isNotEmpty);
      expect(isbToHunza.any((t) => t.route.contains('via Islamabad')), isFalse);

      final khiToHunza = TransportService.generateConnectingOptions('Karachi', 'Hunza');
      expect(khiToHunza.any((t) => t.route.contains('via Islamabad')), isTrue);
    });
  });

  group('PDFService Sanitization Tests', () {
    test('preserves ASCII codes for GBP, EUR, SAR while stripping emojis', () {
      expect(PDFService.sanitizeText('£ 100.00'), 'GBP 100.00');
      expect(PDFService.sanitizeText('€ 85.00'), 'EUR 85.00');
      expect(PDFService.sanitizeText('﷼ 200'), 'SAR 200');
      expect(PDFService.sanitizeText('Lahore ➔ Islamabad 🚗'), 'Lahore -> Islamabad');
    });
  });

  group('SavedTripsService & FavoriteProvider Tests', () {
    test('saves, updates current trip, and deletes trips cleanly', () async {
      final service = SavedTripsService();
      final t1 = SavedTrip(
        id: 't_1',
        title: 'Hunza Trip',
        destination: 'Hunza',
        origin: 'Lahore',
        startDate: DateTime(2026, 11, 20),
        endDate: DateTime(2026, 11, 23),
        budget: 60000,
        travelers: 2,
        isCurrent: true,
      );
      final t2 = SavedTrip(
        id: 't_2',
        title: 'Swat Trip',
        destination: 'Swat',
        origin: 'Islamabad',
        startDate: DateTime(2026, 12, 1),
        endDate: DateTime(2026, 12, 3),
        budget: 40000,
        travelers: 1,
        isCurrent: true,
      );

      await service.saveTrip(t1);
      await service.saveTrip(t2);
      var all = await service.getSavedTrips();
      expect(all.length, 2);
      expect((await service.getCurrentTrip())?.id, 't_2');

      await service.deleteTrip('t_2');
      all = await service.getSavedTrips();
      expect(all.length, 1);
      expect(all.first.id, 't_1');
      expect(all.first.isCurrent, isTrue);

      await service.deleteTrip('t_1');
    });

    test('toggles and removes favorites', () {
      final favs = FavoriteProvider();
      final seedHotelId = SeedData.initialHotels.first.id;

      favs.toggleFavorite(seedHotelId);
      expect(favs.isFavorite(seedHotelId), isTrue);
      expect(favs.getFavoriteHotels().length, 1);

      favs.removeFavorite(seedHotelId);
      expect(favs.isFavorite(seedHotelId), isFalse);
      expect(favs.getFavoriteHotels(), isEmpty);
    });
  });

  group('Model, Asset & Static Catalog Checks', () {
    test('Attraction.effectiveVideoUrl respects explicit URL or includes city context', () {
      final withVideo = Attraction(
        id: 'a1',
        name: 'Faisal Mosque',
        city: 'Islamabad',
        type: 'Landmark',
        fee: 0,
        vendorId: 'v1',
        videoUrl: 'https://youtu.be/abc123',
      );
      expect(withVideo.effectiveVideoUrl, 'https://youtu.be/abc123');

      final withoutVideo = Attraction(
        id: 'a2',
        name: 'Badshahi Mosque',
        city: 'Lahore',
        type: 'Heritage',
        fee: 50,
        vendorId: 'v1',
      );
      expect(withoutVideo.effectiveVideoUrl, contains('Lahore'));
      expect(withoutVideo.effectiveVideoUrl, contains('Pakistan'));
    });

    test('CulturalCalendar covers all 12 months and falls back safely', () {
      for (int m = 1; m <= 12; m++) {
        expect(CulturalCalendar.getEventsForMonth(m).trim(), isNotEmpty);
      }
      expect(CulturalCalendar.getEventsForMonth(99), contains('scenic beauty'));
    });

    test('TravelNewsService returns structured regional advisories', () {
      final advisories = TravelNewsService.getLiveAdvisories();
      expect(advisories, isNotEmpty);
      for (final item in advisories) {
        expect(item.placeName, isNotEmpty);
        expect(item.headline, isNotEmpty);
        expect(item.region, isNotEmpty);
      }
    });

    test('Hotels CSV dataset loads cleanly and has valid rating column (index 16)', () async {
      final raw = await rootBundle.loadString('assets/hotels/Pakistan_Tourism_Hotels.csv');
      final rows = const CsvToListConverter().convert(raw);
      expect(rows.length, greaterThan(5));
      final validRows = rows.skip(1).where((r) => r.length >= 17).toList();
      expect(validRows.length, greaterThan(5));
    });
  });
}
