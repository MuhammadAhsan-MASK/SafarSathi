import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'itinerary_screen.dart';
import 'split_bill_screen.dart';
import 'services/budget_matcher_service.dart';
import '../hotels/models/hotel_model.dart';
import '../restaurants/models/restaurant_model.dart';
import '../transport/models/transport_model.dart';
import '../hotels/hotel_detail_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';

class BudgetAnalysisScreen extends StatefulWidget {
  final String destination;
  final double budget;
  final DateTime startDate;
  final DateTime endDate;
  final int travelers;

  const BudgetAnalysisScreen({
    super.key,
    required this.destination,
    required this.budget,
    required this.startDate,
    required this.endDate,
    required this.travelers,
  });

  @override
  State<BudgetAnalysisScreen> createState() => _BudgetAnalysisScreenState();
}

class _BudgetAnalysisScreenState extends State<BudgetAnalysisScreen> {
  final BudgetMatcherService _matcherService = BudgetMatcherService();

  late Future<List<TransportOption>> _transportFuture;
  late Future<List<Hotel>> _hotelFuture;
  late Future<List<Restaurant>> _restaurantFuture;

  late double _maxNightlyHotelBudget;
  late double _maxMealBudget;
  late double _maxTransportBudget;

  @override
  void initState() {
    super.initState();
    final days = widget.endDate.difference(widget.startDate).inDays.abs() + 1;
    final dayCount = days > 0 ? days : 1;

    // Budget math
    _maxNightlyHotelBudget = (widget.budget * 0.40) / dayCount;
    _maxMealBudget = (widget.budget * 0.30) / (dayCount * 3 * widget.travelers);
    _maxTransportBudget = (widget.budget * 0.20) / widget.travelers;

    _transportFuture = _matcherService.getAffordableTransport(widget.destination, _maxTransportBudget);
    _hotelFuture = _matcherService.getAffordableHotels(widget.destination, _maxNightlyHotelBudget);
    _restaurantFuture = _matcherService.getAffordableRestaurants(widget.destination, _maxMealBudget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildHealthScoreCard(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildCostSummary(),
            ),
            const SizedBox(height: 30),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Bookings matching your budget:', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            _buildSectionHeader('Transport Options (< ${Provider.of<CurrencyProvider>(context).formatPrice(_maxTransportBudget)} /person)'),
            _buildFutureBuilder<List<TransportOption>>(_transportFuture, (transports) => _buildTransportList(transports)),
            
            const SizedBox(height: 20),
            
            _buildSectionHeader('Hotels (< ${Provider.of<CurrencyProvider>(context).formatPrice(_maxNightlyHotelBudget)} /night)'),
            _buildFutureBuilder<List<Hotel>>(_hotelFuture, (hotels) => _buildHotelList(hotels)),

            const SizedBox(height: 20),

            _buildSectionHeader('Restaurants (< ${Provider.of<CurrencyProvider>(context).formatPrice(_maxMealBudget)} /meal)'),
            _buildFutureBuilder<List<Restaurant>>(_restaurantFuture, (restaurants) => _buildRestaurantList(restaurants)),

            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ItineraryScreen(
                      destination: widget.destination,
                      startDate: widget.startDate,
                      endDate: widget.endDate,
                      budget: widget.budget,
                      travelers: widget.travelers,
                    )),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('View Detailed Itinerary'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplitBillScreen()),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Split Bill / Group Tracker'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primaryPurple)),
    );
  }

  Widget _buildFutureBuilder<T>(Future<T> future, Widget Function(T) builder) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.hasData || (snapshot.data is List && (snapshot.data as List).isEmpty)) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            child: Text("No affordable options available in database for this limit. Try increasing budget."),
          );
        }
        return builder(snapshot.data as T);
      }
    );
  }

  Widget _buildTransportList(List<TransportOption> options) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final t = options[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.icon, color: AppTheme.primaryPurple, size: 30),
                  const SizedBox(height: 8),
                  Text(t.type, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(t.route, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const Spacer(),
                  Text(Provider.of<CurrencyProvider>(context, listen: false).formatPrice(t.fare), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildHotelList(List<Hotel> hotels) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final h = hotels[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: h))),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (h.imageUrl != null && h.imageUrl!.isNotEmpty)
                      Image.network(h.imageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover)
                    else
                      Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.image)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(Provider.of<CurrencyProvider>(context, listen: false).formatPrice(h.price), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildRestaurantList(List<Restaurant> rests) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: rests.length,
        itemBuilder: (context, index) {
          final r = rests[index];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantDetailScreen(restaurant: r))),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.imageUrl != null && r.imageUrl!.isNotEmpty)
                      Image.network(r.imageUrl!, height: 100, width: double.infinity, fit: BoxFit.cover)
                    else
                      Container(height: 100, color: Colors.grey[300], child: const Icon(Icons.restaurant)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(Provider.of<CurrencyProvider>(context, listen: false).formatPrice(r.price), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10)),
      ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
              Column(
                children: [
                  Text(
                    '85',
                    style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    'Healthy',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Budget Ready',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 8),
          Text(
            'Your budget for ${widget.destination} is well-planned for ${widget.travelers} traveler${widget.travelers > 1 ? 's' : ''}.',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCostSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated Total Cost', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  Provider.of<CurrencyProvider>(context).formatPrice(widget.budget),
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.receipt_long_outlined, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
