import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'models/guide_model.dart';
import 'guide_detail_screen.dart';

class GuidesScreen extends StatefulWidget {
  const GuidesScreen({super.key});

  @override
  State<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends State<GuidesScreen> {
  final List<LocalGuide> _allGuides = GuideMockService.fetchMockGuides();
  late List<LocalGuide> _filteredGuides;
  String _selectedRegion = 'All';
  String _searchQuery = '';
  bool _onlySafeForFemales = false;

  final List<String> _regions = [
    'All',
    'Hunza Valley',
    'Skardu & Deosai',
    'Swat Valley & Kalam',
    'Naran, Kaghan & Babusar',
    'Kumrat Valley & Dir',
    'Fairy Meadows & Nanga Parbat',
    'Neelum Valley (Azad Kashmir)',
    'Lahore',
    'Islamabad & Margalla Hills',
    'Peshawar & Khyber Pass',
    'Quetta & Ziarat',
    'Cholistan & Bahawalpur',
    'Karachi & Coastal Sindh',
  ];

  @override
  void initState() {
    super.initState();
    _filteredGuides = _allGuides;
  }

  void _filterGuides() {
    setState(() {
      _filteredGuides = _allGuides.where((g) {
        final matchesRegion = _selectedRegion == 'All' || g.region == _selectedRegion;
        final matchesSafety = !_onlySafeForFemales || g.isFemaleFriendly;
        final q = _searchQuery.trim().toLowerCase();
        final matchesSearch = q.isEmpty ||
            g.name.toLowerCase().contains(q) ||
            g.region.toLowerCase().contains(q) ||
            g.car.toLowerCase().contains(q) ||
            g.role.toLowerCase().contains(q);

        return matchesRegion && matchesSafety && matchesSearch;
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(' ', '');
    final Uri uri = Uri(scheme: 'tel', path: cleanPhone);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open dialer for $phoneNumber')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String waNumber, String guideName) async {
    final cleanNumber = waNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final message = Uri.encodeComponent(
      'Hello $guideName! I found your profile on SastaSafar. I want to inquire about booking your guide and vehicle services.',
    );
    final Uri uri = Uri.parse('https://wa.me/$cleanNumber?text=$message');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open WhatsApp for $waNumber')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text(
          'Local Guides & 4x4 Drivers',
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        actions: [
          _buildCurrencySelector(context),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter Controls ──
          _buildFilters(),

          // ── Guides Count & Region Header ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredGuides.length} ${_filteredGuides.length == 1 ? "Expert" : "Experts"} in ${_selectedRegion == "All" ? "Pakistan" : _selectedRegion}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                if (_selectedRegion != 'All' || _onlySafeForFemales || _searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRegion = 'All';
                        _onlySafeForFemales = false;
                        _searchQuery = '';
                      });
                      _filterGuides();
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                    ),
                  ),
              ],
            ),
          ),

          // ── Guides List ──
          Expanded(
            child: _filteredGuides.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No guides found matching your criteria.',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try clearing filters or selecting another region.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: _filteredGuides.length,
                    itemBuilder: (ctx, index) {
                      return _buildGuideCard(_filteredGuides[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          // Search TextField
          TextField(
            onChanged: (val) {
              _searchQuery = val;
              _filterGuides();
            },
            decoration: InputDecoration(
              hintText: 'Search guide by name, car, or region...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Regions Scroll
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final r = _regions[index];
                final isSelected = _selectedRegion == r;

                return InkWell(
                  onTap: () {
                    setState(() => _selectedRegion = r);
                    _filterGuides();
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      r,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Safe for Female / Solo Travelers switch
          SwitchListTile(
            title: Text(
              "Solo Female & Family Verified Safe",
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text("Show top-rated verified guides with female-safe protocol", style: TextStyle(fontSize: 10)),
            secondary: const Icon(Icons.security, color: Colors.pinkAccent, size: 20),
            value: _onlySafeForFemales,
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: Colors.pinkAccent,
            onChanged: (val) {
              setState(() {
                _onlySafeForFemales = val;
                _filterGuides();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(LocalGuide guide) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: guide)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar, Name, Verified, and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: guide.imageUrl != null && guide.imageUrl!.isNotEmpty
                          ? Image.network(
                              guide.imageUrl!,
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultCardAvatar(guide),
                            )
                          : _defaultCardAvatar(guide),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  guide.name,
                                  style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (guide.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified, color: Colors.blue, size: 16),
                              ],
                              if (guide.isFemaleFriendly) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.security, color: Colors.pinkAccent, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            guide.role,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryPurple,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  guide.region,
                                  style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyProvider.formatPrice(guide.dailyRatePkr),
                          style: const TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const Text('/ day', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Middle Badges: Experience, Vehicle / Car, Rating & Trips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Rating & Trips
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            '${guide.rating} (${guide.tripCount} trips)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),

                    // Experience
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_filled, color: Colors.blue.shade700, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            guide.experience,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                          ),
                        ],
                      ),
                    ),

                    // Car details badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car, color: Colors.deepOrange.shade700, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            guide.car,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Actions Row: Phone Number, Call & WhatsApp shortcuts + View Details
                Row(
                  children: [
                    // Phone Number display
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              guide.contactNumber,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // WhatsApp Icon Button
                    InkWell(
                      onTap: () => _openWhatsApp(guide.whatsappNumber, guide.name),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat, color: Color(0xFF25D366), size: 16),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Call Icon Button
                    InkWell(
                      onTap: () => _makePhoneCall(guide.contactNumber),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.call, color: AppTheme.primaryPurple, size: 16),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // View Details & Hire CTA
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GuideDetailScreen(guide: guide)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View & Hire', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultCardAvatar(LocalGuide guide) {
    return Container(
      width: 58,
      height: 58,
      color: AppTheme.primaryPurple.withValues(alpha: 0.1),
      child: Center(
        child: Icon(
          guide.role.contains('Jeep') ? Icons.directions_car : Icons.person,
          color: AppTheme.primaryPurple,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currencyProvider.selectedCurrency,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.currency_exchange, size: 20, color: Colors.white),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          items: currencyProvider.currencies.map((String cur) {
            return DropdownMenuItem<String>(
              value: cur,
              child: Text(cur, style: const TextStyle(color: Colors.black)),
            );
          }).toList(),
          onChanged: (String? newVal) {
            if (newVal != null) currencyProvider.setCurrency(newVal);
          },
        ),
      ),
    );
  }
}
