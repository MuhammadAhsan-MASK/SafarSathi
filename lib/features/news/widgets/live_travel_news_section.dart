import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/travel_news_model.dart';
import '../services/travel_news_service.dart';
import 'travel_advisory_detail_sheet.dart';
import '../../../core/theme.dart';

class LiveTravelNewsSection extends StatefulWidget {
  const LiveTravelNewsSection({super.key});

  @override
  State<LiveTravelNewsSection> createState() => _LiveTravelNewsSectionState();
}

class _LiveTravelNewsSectionState extends State<LiveTravelNewsSection> {
  late List<TravelNewsItem> _advisories;
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _isRefreshing = false;
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();
  late DateTime _lastRefreshed;

  final List<String> _filters = [
    'All',
    'Safe to Travel',
    'Advisories & Alerts',
    'Gilgit-Baltistan',
    'Khyber Pakhtunkhwa',
    'Punjab',
    'Balochistan',
    'Azad Kashmir',
  ];

  @override
  void initState() {
    super.initState();
    _lastRefreshed = DateTime.now();
    _advisories = TravelNewsService.getLiveAdvisories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _isRefreshing = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _lastRefreshed = DateTime.now();
          _advisories = TravelNewsService.getLiveAdvisories();
          _isRefreshing = false;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Live travel news & weather updated from NDMA & PMD feeds',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  List<TravelNewsItem> get _filteredAdvisories {
    return _advisories.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.placeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.region.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.headline.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Safe to Travel') {
        return item.safetyStatus == TravelSafetyStatus.safe;
      }
      if (_selectedFilter == 'Advisories & Alerts') {
        return item.safetyStatus != TravelSafetyStatus.safe;
      }
      return item.region.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();
  }

  String _formatCurrentTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hour:$minute $amPm PKT';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAdvisories;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Live Refresh Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'LIVE',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Travel & Weather News',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Genuine disaster alerts, weather & safety status of all places',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search toggle button
                    InkWell(
                      onTap: () {
                        setState(() {
                          _showSearch = !_showSearch;
                          if (!_showSearch) {
                            _searchQuery = '';
                            _searchController.clear();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _showSearch
                              ? AppTheme.primaryPurple
                              : AppTheme.primaryPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
                        ),
                        child: Icon(
                          _showSearch ? Icons.close_rounded : Icons.search_rounded,
                          size: 15,
                          color: _showSearch ? Colors.white : AppTheme.primaryPurple,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Refresh Button with Live Indicator
                    InkWell(
                      onTap: _isRefreshing ? null : _refreshData,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _isRefreshing
                                ? const SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryPurple),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 15, color: AppTheme.primaryPurple),
                            const SizedBox(width: 4),
                            Text(
                              'Update',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (_showSearch) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) => setState(() => _searchQuery = val.trim()),
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search place (e.g. Hunza, Skardu, Murree, Swat)...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppTheme.primaryPurple),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8F9FE),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1.5),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Breaking Advisory Live Ticker Banner
          _buildLiveTickerBanner(),

          const SizedBox(height: 12),

          // Filter Pills
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedFilter = filter);
                  },
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  selectedColor: AppTheme.primaryPurple,
                  backgroundColor: const Color(0xFFF1F5F9),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primaryPurple : Colors.transparent,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal Destination Cards
          if (filtered.isEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Text(
                  'No advisories found for "$_selectedFilter"',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            )
          else
            SizedBox(
              height: 295,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  return _buildAdvisoryCard(context, filtered[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLiveTickerBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign_rounded, color: Colors.amberAccent, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'NDMA: Babusar Pass closed for winter • KKH clear • Murree fog alert • Skardu flights normal',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatCurrentTime(_lastRefreshed).split('•').last.trim(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.white60,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryCard(BuildContext context, TravelNewsItem item) {
    return InkWell(
      onTap: () => TravelAdvisoryDetailSheet.show(context, item),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: item.statusColor.withValues(alpha: 0.3),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: item.statusColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Region & Safety Pill
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.region.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryPurple,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: item.statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: item.statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.statusIcon, size: 12, color: item.statusColor),
                      const SizedBox(width: 4),
                      Text(
                        item.safetyStatus == TravelSafetyStatus.safe
                            ? 'Safe to Travel'
                            : (item.safetyStatus == TravelSafetyStatus.caution
                                ? 'Caution'
                                : 'High Alert'),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: item.statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Place Name
            Text(
              item.placeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 10),

            // Weather & Temperature Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(item.weatherIcon, size: 20, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '${item.currentTemp}${item.tempUnit}',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.weatherCondition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Wind: ${item.windSpeed}',
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Disaster & Road status snippet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: item.statusColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.disasterAlert,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.alt_route_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.roadCondition,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 16, color: Color(0xFFF1F5F9)),

            // Footer: Updated time + Action arrow
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.formattedDateTime,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Report',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 13, color: AppTheme.primaryPurple),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
