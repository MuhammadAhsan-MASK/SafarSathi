import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/currency_provider.dart';
import '../../core/theme.dart';
import 'models/transport_model.dart';

class TransportDetailScreen extends StatefulWidget {
  final TransportOption option;

  const TransportDetailScreen({super.key, required this.option});

  @override
  State<TransportDetailScreen> createState() => _TransportDetailScreenState();
}

class _TransportDetailScreenState extends State<TransportDetailScreen> {
  String? _selectedTier;

  @override
  void initState() {
    super.initState();
    if (widget.option.typePrices.isNotEmpty) {
      _selectedTier = widget.option.typePrices.keys.first;
    }
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }

  Future<void> _callHelpline(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not dial $phone')),
        );
      }
    }
  }

  String _getOperatorHelpline(String operator) {
    final op = operator.toLowerCase();
    if (op.contains('pia') || op.contains('pakistan international')) return '111-786-786';
    if (op.contains('faisal movers')) return '111-22-44-88';
    if (op.contains('daewoo')) return '111-007-008';
    if (op.contains('railway')) return '117';
    if (op.contains('airsial')) return '021-111-247-742';
    if (op.contains('serene')) return '111-737-363';
    if (op.contains('natco')) return '051-9255208';
    if (op.contains('bilal')) return '042-111-287-287';
    return '111-007-008';
  }

  String _calculateArrivalTime(String depTime, String duration) {
    try {
      final parts = depTime.split(':');
      if (parts.length < 2) return '--:--';
      int depHours = int.parse(parts[0].trim());
      int depMinutes = int.parse(parts[1].trim());

      int durHours = 0;
      int durMinutes = 0;

      final hMatch = RegExp(r'(\d+)\s*h').firstMatch(duration);
      if (hMatch != null) {
        durHours = int.parse(hMatch.group(1)!);
      }
      final mMatch = RegExp(r'(\d+)\s*m').firstMatch(duration);
      if (mMatch != null) {
        durMinutes = int.parse(mMatch.group(1)!);
      }

      int totalMinutes = (depHours * 60 + depMinutes) + (durHours * 60 + durMinutes);
      int arrHours = (totalMinutes ~/ 60) % 24;
      int arrMinutes = totalMinutes % 60;

      final hStr = arrHours.toString().padLeft(2, '0');
      final mStr = arrMinutes.toString().padLeft(2, '0');
      return '$hStr:$mStr';
    } catch (_) {
      return 'Scheduled';
    }
  }

  Color _categoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'flight':
        return Colors.blue.shade700;
      case 'train':
        return Colors.teal;
      case 'bus':
        return Colors.deepOrange;
      default:
        return AppTheme.primaryPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final themeColor = _categoryColor(option.category);

    final routeParts = option.route.split(RegExp(r'->|to|-'));
    final originCity = routeParts.isNotEmpty ? routeParts[0].trim() : 'Departure';
    final destCity = routeParts.length > 1 ? routeParts[1].trim() : 'Destination';
    final arrivalTime = _calculateArrivalTime(option.departureTime, option.time);

    final currentFare = (_selectedTier != null && option.typePrices.containsKey(_selectedTier))
        ? option.typePrices[_selectedTier]!
        : option.fare;

    final helpline = _getOperatorHelpline(option.operator.isNotEmpty ? option.operator : option.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: Text(
          option.type,
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_in_talk, size: 22),
            tooltip: 'Call Operator Helpline',
            onPressed: () => _callHelpline(helpline),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 22),
            tooltip: 'Share Itinerary',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Route details copied: ${option.type} ($originCity to $destCity)'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ticket / Boarding Pass Style Card ──
            _buildBoardingPassCard(
              originCity: originCity,
              destCity: destCity,
              arrivalTime: arrivalTime,
              themeColor: themeColor,
            ),
            const SizedBox(height: 16),

            // ── Operator & Category Info Card ──
            _buildOperatorCard(themeColor, helpline),
            const SizedBox(height: 16),

            // ── Seat Classes & Fare Selection ──
            if (option.typePrices.isNotEmpty) ...[
              _buildSeatClassesCard(themeColor, currencyProvider),
              const SizedBox(height: 16),
            ],

            // ── Included Amenities & Onboard Facilities ──
            _buildAmenitiesCard(themeColor),
            const SizedBox(height: 16),

            // ── Baggage & Travel Policies ──
            _buildBaggagePolicyCard(themeColor),
            const SizedBox(height: 16),

            // ── Important Traveler Tips & Guidelines ──
            _buildTravelTipsCard(),
          ],
        ),
      ),
      bottomSheet: _buildBottomBookingBar(currentFare, themeColor, currencyProvider),
    );
  }

  // ── Ticket / Boarding Pass Card ─────────────────────────────────────────────
  Widget _buildBoardingPassCard({
    required String originCity,
    required String destCity,
    required String arrivalTime,
    required Color themeColor,
  }) {
    final option = widget.option;
    final seats = option.availableSeats;
    final seatsColor = seats <= 5 ? Colors.red : (seats <= 15 ? Colors.orange : Colors.green);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Upper section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Category badge & seat badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(option.icon, size: 14, color: themeColor),
                          const SizedBox(width: 6),
                          Text(
                            option.category.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: seatsColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_seat, size: 13, color: seatsColor),
                          const SizedBox(width: 4),
                          Text(
                            '$seats seats left',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: seatsColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Flight / Journey path
                Row(
                  children: [
                    // Departure City
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            originCity,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.departureTime,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: themeColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Departure Time',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    // Travel Duration & Line
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Text(
                            option.time,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: themeColor.withValues(alpha: 0.4),
                                ),
                              ),
                              Icon(option.icon, size: 18, color: themeColor),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: themeColor.withValues(alpha: 0.4),
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Direct Service',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),

                    // Destination City
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            destCity,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            arrivalTime,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Est. Arrival',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            textAlign: TextAlign.end,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dashed Divider
          Row(
            children: [
              SizedBox(
                width: 14,
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 6.0;
                    const dashSpace = 4.0;
                    final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                    return Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: List.generate(dashCount, (_) {
                        return const SizedBox(
                          width: dashWidth,
                          height: 1.5,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 14,
                height: 24,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FC),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Lower section (Route details & Service info)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SERVICE NAME', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(option.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('STATUS', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Text('On Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Operator Card ─────────────────────────────────────────────────────────
  Widget _buildOperatorCard(Color themeColor, String helpline) {
    final option = widget.option;
    final operatorName = option.operator.isNotEmpty ? option.operator : option.type;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(option.icon, color: themeColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operatorName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified Transport Partner of Pakistan',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _callHelpline(helpline),
            icon: Icon(Icons.call, color: themeColor),
            tooltip: 'Call $helpline',
          ),
        ],
      ),
    );
  }

  // ── Seat Classes & Pricing Card ─────────────────────────────────────────────
  Widget _buildSeatClassesCard(Color themeColor, CurrencyProvider currencyProvider) {
    final option = widget.option;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Seat Class / Tier',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Column(
            children: option.typePrices.entries.map((entry) {
              final isSelected = _selectedTier == entry.key;
              final priceFormatted = currencyProvider.formatPrice(entry.value);

              return GestureDetector(
                onTap: () => setState(() => _selectedTier = entry.key),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor.withValues(alpha: 0.07) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? themeColor : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? themeColor : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? themeColor : Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        priceFormatted,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? themeColor : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Included Amenities ──────────────────────────────────────────────────────
  Widget _buildAmenitiesCard(Color themeColor) {
    final cat = widget.option.category.toLowerCase();
    final isFlight = cat == 'flight';
    final isTrain = cat == 'train';

    final amenities = [
      {'icon': Icons.ac_unit, 'label': 'Climate AC'},
      {'icon': Icons.airline_seat_recline_extra, 'label': 'Comfort Seats'},
      {'icon': isFlight ? Icons.fastfood : Icons.local_drink, 'label': isFlight ? 'In-flight Snack' : 'Bottled Water'},
      {'icon': Icons.bolt, 'label': 'Power / USB'},
      if (isTrain) {'icon': Icons.wc, 'label': 'Clean Restroom'},
      if (isFlight) {'icon': Icons.luggage, 'label': 'Cabin Baggage'},
      {'icon': Icons.security, 'label': 'Insured Travel'},
      {'icon': Icons.support_agent, 'label': '24/7 Helpline'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Included Amenities & Comforts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: amenities.length,
            itemBuilder: (context, index) {
              final a = amenities[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(a['icon'] as IconData, size: 18, color: themeColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a['label'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Baggage Policy ──────────────────────────────────────────────────────────
  Widget _buildBaggagePolicyCard(Color themeColor) {
    final cat = widget.option.category.toLowerCase();
    final isFlight = cat == 'flight';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.luggage, color: themeColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Luggage & Baggage Allowance',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _policyRow(
            icon: Icons.backpack,
            title: isFlight ? 'Cabin Baggage' : 'Hand Bag',
            detail: isFlight ? '1 piece up to 7 kg per passenger' : 'Hand carry bag allowed on seat',
          ),
          const SizedBox(height: 8),
          _policyRow(
            icon: Icons.cases_outlined,
            title: isFlight ? 'Checked Baggage' : 'Cargo Luggage',
            detail: isFlight ? '20 kg included in Economy (30 kg in Business)' : 'Up to 30 kg cargo compartment allowance',
          ),
        ],
      ),
    );
  }

  Widget _policyRow({required IconData icon, required String title, required String detail}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(detail, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Traveler Tips ───────────────────────────────────────────────────────────
  Widget _buildTravelTipsCard() {
    final cat = widget.option.category.toLowerCase();
    final reportTime = cat == 'flight' ? '2 hours' : '30-45 minutes';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade800, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Traveler Guidelines',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• Please arrive at the terminal at least $reportTime prior to departure.\n'
                  '• Original computerized CNIC or Passport is strictly mandatory for boarding.\n'
                  '• E-tickets with booking reference SMS are accepted at check-in.',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade900, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Booking Bar ──────────────────────────────────────────────────────
  Widget _buildBottomBookingBar(
    double currentFare,
    Color themeColor,
    CurrencyProvider currencyProvider,
  ) {
    final option = widget.option;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedTier ?? 'Standard Fare',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                Text(
                  currencyProvider.formatPrice(currentFare),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: themeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (option.websiteUrl != null && option.websiteUrl!.isNotEmpty) {
                    _launchUrl(option.websiteUrl!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Contact ${option.operator} directly at ${_getOperatorHelpline(option.operator)}')),
                    );
                  }
                },
                icon: const Icon(Icons.open_in_browser, size: 18),
                label: const Text(
                  'Book via Official Portal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
