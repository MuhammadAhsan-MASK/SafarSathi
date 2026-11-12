import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_guide/core/currency_provider.dart';
import 'package:travel_guide/features/bargain/bargain_screen.dart';
import 'package:travel_guide/features/booking/booking_success_screen.dart';
import 'package:travel_guide/features/budget/cost_summary_screen.dart';
import 'package:travel_guide/features/budget/itinerary_screen.dart';
import 'package:travel_guide/features/eco_tracker/eco_tracker_screen.dart';
import 'package:travel_guide/features/guides/guide_detail_screen.dart';
import 'package:travel_guide/features/guides/models/guide_model.dart';
import 'package:travel_guide/features/profile/info_screens.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrapWithCurrency(Widget child, {CurrencyProvider? provider}) {
    final currency = provider ?? CurrencyProvider();
    return ChangeNotifierProvider<CurrencyProvider>.value(
      value: currency,
      child: MaterialApp(home: child),
    );
  }

  group('EcoTrackerScreen Widget Tests', () {
    testWidgets('renders cleanly on narrow mobile screen and updates mode Eco-Points', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 780));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(wrapWithCurrency(const EcoTrackerScreen()));
      await tester.pumpAndSettle();

      // Default Bus mode = 40 Eco-Points, 300 km * 0.05 = 15.0 kg CO2
      expect(find.text('40 Eco-Points earned'), findsOneWidget);
      expect(find.text('15.0 kg'), findsOneWidget);

      // Switch to Train = 50 Eco-Points, 300 * 0.04 = 12.0 kg CO2
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Train').last);
      await tester.pumpAndSettle();

      expect(find.text('50 Eco-Points earned'), findsOneWidget);
      expect(find.text('12.0 kg'), findsOneWidget);

      // Switch to Air = 5 Eco-Points, 300 * 0.25 = 75.0 kg CO2
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Air').last);
      await tester.pumpAndSettle();

      expect(find.text('5 Eco-Points earned'), findsOneWidget);
      expect(find.text('75.0 kg'), findsOneWidget);
    });
  });

  group('BargainScreen Widget & Currency Logic Tests', () {
    testWidgets('evaluates quotes in PKR and active USD currency consistently', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final currency = CurrencyProvider();
      await tester.pumpWidget(wrapWithCurrency(const BargainScreen(), provider: currency));
      await tester.pumpAndSettle();

      // Enter quote below min for first item (Jeep to Fairy Meadows min = 5000) -> Rs. 4000
      await tester.enterText(find.byType(TextField).first, '4000');
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      expect(find.text('Super Steal / Great Deal!'), findsOneWidget);
      // Should not display contradictory higher 6,000 rebuttal when quoted 4000
      expect(find.textContaining('6,000 theek hai'), findsNothing);

      // Switch to USD ($1 = Rs. 280): quote $25 (= PKR 7000, fair market 5000..8000)
      currency.setCurrency('USD');
      await tester.pumpAndSettle();

      expect(find.text('Quoted Price (USD)'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, '25');
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      expect(find.text('Fair Market Price'), findsOneWidget);
    });
  });

  group('ItineraryScreen Regression Widget Tests', () {
    testWidgets('handles 1-day trip and small wallet (<1000) Day Budget dialog without ArgumentError', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final day = DateTime(2026, 11, 20);
      await tester.pumpWidget(wrapWithCurrency(ItineraryScreen(
        origin: 'Karachi',
        destination: 'Lahore',
        startDate: day,
        endDate: day,
        budget: 5000,
        travelers: 2,
        transportCost: 2200,
        stayCost: 2000, // net daily wallet = 800 (< 1000!)
      )));
      await tester.pumpAndSettle();

      expect(find.textContaining('Day 1'), findsWidgets);

      // Open Set Day 1 Budget dialog and tap 25% & 50% quick presets
      final setBudgetBtn = find.byIcon(Icons.edit_outlined);
      if (setBudgetBtn.evaluate().isNotEmpty) {
        await tester.tap(setBudgetBtn.first);
        await tester.pumpAndSettle();

        await tester.tap(find.text('25%'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('50%'));
        await tester.pumpAndSettle();

        // Reject negative number gracefully
        await tester.enterText(find.byType(TextField).last, '-200');
        await tester.tap(find.text('Save Budget'));
        await tester.pumpAndSettle();
        expect(find.text('Budget cannot be negative.'), findsOneWidget);
      }
    });
  });

  group('GuideDetailScreen Hire Sheet Widget Test', () {
    testWidgets('hire sheet adjusts trip duration and recalculates total dynamically', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final guide = LocalGuide(
        id: 'g_test',
        name: 'Aslam Khan',
        role: '4x4 Mountain Guide',
        region: 'Hunza Valley',
        rating: 4.8,
        dailyRatePkr: 5000,
        tripCount: 12,
        experience: '6 Years',
        car: 'Toyota Prado',
        contactNumber: '+923001234567',
        whatsappNumber: '03001234567',
        bio: 'Experienced northern areas driver.',
      );

      await tester.pumpWidget(wrapWithCurrency(GuideDetailScreen(guide: guide)));
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Hire'));
      await tester.pumpAndSettle();

      // Default 3 days * 5000 = Rs. 15000
      expect(find.text('Trip Duration: 3 Days'), findsOneWidget);
      expect(find.text('Rs. 15000'), findsOneWidget);

      // Tap '+' twice -> 5 days * 5000 = Rs. 25000
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      expect(find.text('Trip Duration: 5 Days'), findsOneWidget);
      expect(find.text('Rs. 25000'), findsOneWidget);
    });
  });

  group('Summary, Info & Booking Confirmation Smoke Tests', () {
    testWidgets('CostSummaryScreen formats currency and renders without overflow', (tester) async {
      final currency = CurrencyProvider()..setCurrency('GBP');
      await tester.pumpWidget(wrapWithCurrency(
        const CostSummaryScreen(
          total: 35000,
          hotel: 14000,
          food: 8750,
          transport: 7000,
          attractions: 5250,
        ),
        provider: currency,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Trip Plan Saved!'), findsOneWidget);
      expect(find.text('£ 100'), findsOneWidget);
    });

    testWidgets('InfoScreen and BookingSuccessScreen render cleanly', (tester) async {
      await tester.pumpWidget(wrapWithCurrency(const InfoScreen(
        title: 'Privacy Policy',
        content: 'Your travel data is handled securely.',
      )));
      await tester.pumpAndSettle();
      expect(find.text('Privacy Policy'), findsOneWidget);

      await tester.pumpWidget(wrapWithCurrency(const BookingSuccessScreen(
        itemName: 'Serena Hotel',
        category: 'Hotel',
      )));
      await tester.pumpAndSettle();
      expect(find.textContaining('Serena Hotel'), findsWidgets);
    });
  });
}
