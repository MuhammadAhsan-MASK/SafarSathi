import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'services/transport_service.dart';
import 'models/transport_model.dart';
import 'package:url_launcher/url_launcher.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TransportService _transportService = TransportService();

  String _selectedCategory = 'all'; // 'all', 'flight', 'bus', 'train'
  String _departure = 'All Cities';
  String _destination = 'All Cities';

  final List<String> _cities = [
    'All Cities',
    'Islamabad',
    'Karachi',
    'Lahore',
    'Peshawar',
    'Quetta',
    'Multan',
    'Skardu',
    'Hunza',
    'Swat',
  ];

  void _resetFilter() {
    setState(() {
      _selectedCategory = 'all';
      _departure = 'All Cities';
      _destination = 'All Cities';
    });
  }

  void _swapCities() {
    if (_departure == 'All Cities' && _destination == 'All Cities') return;
    setState(() {
      final temp = _departure;
      _departure = _destination;
      _destination = temp;
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open $urlString')));
      }
    }
  }

  void _showCityPicker({required bool isDeparture}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    isDeparture ? Icons.flight_takeoff : Icons.location_on,
                    color: AppTheme.primaryPurple,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isDeparture ? 'Select Departure City' : 'Select Destination City',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _cities.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final current = isDeparture ? _departure : _destination;
                    final isSelected = current == city;

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Icon(
                        city == 'All Cities' ? Icons.public : Icons.location_city,
                        color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade600,
                        size: 20,
                      ),
                      title: Text(
                        city,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppTheme.primaryPurple : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: AppTheme.primaryPurple, size: 20)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isDeparture) {
                            _departure = city;
                          } else {
                            _destination = city;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _selectedCategory != 'all' ||
        _departure != 'All Cities' ||
        _destination != 'All Cities';

    final effectiveSource = _departure == 'All Cities' ? null : _departure;
    final effectiveDest = _destination == 'All Cities' ? null : _destination;
    final effectiveCat = _selectedCategory == 'all' ? null : _selectedCategory;

    final warning = (effectiveSource != null && effectiveDest != null)
        ? _transportService.getSeasonalWarning(effectiveSource, effectiveDest)
        : null;

    final isMountainRail = effectiveCat == 'train' &&
        effectiveDest != null &&
        (effectiveDest.toLowerCase().contains('hunza') ||
            effectiveDest.toLowerCase().contains('skardu') ||
            effectiveDest.toLowerCase().contains('swat'));

    return Scaffold(
      backgroundColor: AppTheme.transportBg,
      appBar: AppBar(
        title: const Text(
          'Transport & Routes',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (hasFilter)
            TextButton.icon(
              onPressed: _resetFilter,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
              label: const Text('Reset', style: TextStyle(color: Colors.white, fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          _buildCurrencySelector(context),
        ],
      ),
      body: Column(
        children: [
          // ── Category Selector Tabs ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('all', 'All Options', Icons.dashboard_outlined),
                  const SizedBox(width: 8),
                  _buildCategoryChip('flight', '✈️ Flights', Icons.flight),
                  const SizedBox(width: 8),
                  _buildCategoryChip('bus', '🚌 Buses', Icons.directions_bus),
                  const SizedBox(width: 8),
                  _buildCategoryChip('train', '🚆 Trains', Icons.train),
                ],
              ),
            ),
          ),

          // ── Interactive Departure & Destination Selector Bar ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Departure Button
                Expanded(
                  child: InkWell(
                    onTap: () => _showCityPicker(isDeparture: true),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.flight_takeoff, size: 13, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'FROM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _departure,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _departure == 'All Cities'
                                  ? Colors.black87
                                  : AppTheme.primaryPurple,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Swap Button
                IconButton(
                  onPressed: _swapCities,
                  icon: const Icon(Icons.swap_horiz_rounded, color: AppTheme.primaryPurple, size: 22),
                  tooltip: 'Swap route',
                  splashRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  constraints: const BoxConstraints(),
                ),

                // Destination Button
                Expanded(
                  child: InkWell(
                    onTap: () => _showCityPicker(isDeparture: false),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 13, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'TO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _destination,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _destination == 'All Cities'
                                  ? Colors.black87
                                  : AppTheme.primaryPurple,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Seasonal Warning (if applicable) ──
          if (warning != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Mountain Railway Advisory (if applicable) ──
          if (isMountainRail)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                border: Border.all(color: Colors.teal.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.teal.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Direct tracks do not reach $_destination. Combined train + luxury road/flight transfer shown below.',
                      style: TextStyle(color: Colors.teal.shade900, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 6),

          // ── Live Results Stream ──
          Expanded(
            child: StreamBuilder<List<TransportOption>>(
              stream: _transportService.getTransportOptions(
                source: effectiveSource,
                destination: effectiveDest,
                category: effectiveCat,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final options = snapshot.data ?? [];

                if (options.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_typeIcon(_selectedCategory), size: 52, color: Colors.grey.shade400),
                          const SizedBox(height: 14),
                          Text(
                            'No transport options found for\n$_departure → $_destination',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _resetFilter,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Show All Routes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: options.length,
                  itemBuilder: (context, index) => _buildTransportCard(context, options[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String catKey, String label, IconData icon) {
    final isSelected = _selectedCategory == catKey;
    final color = _colorForCategory(catKey);

    return InkWell(
      onTap: () => setState(() => _selectedCategory = catKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportCard(BuildContext context, TransportOption option) {
    final color = _colorForCategory(option.category);
    final seats = option.availableSeats;
    final seatsColor = seats <= 5 ? Colors.red : (seats <= 15 ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon, Service info, Fare & Seats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.type,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (option.operator.isNotEmpty)
                      Text(
                        option.operator,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.directions, size: 12, color: color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            option.route,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Departs ${option.departureTime}  •  ${option.time}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                    Provider.of<CurrencyProvider>(context).formatPrice(option.fare),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: seatsColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$seats seats left',
                      style: TextStyle(
                        fontSize: 10,
                        color: seatsColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Tier tags (if provided)
          if (option.typePrices.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: option.typePrices.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${e.key}: ${Provider.of<CurrencyProvider>(context, listen: false).formatPrice(e.value)}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ],

          // Official website book button
          if (option.websiteUrl != null && option.websiteUrl!.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl(option.websiteUrl!),
                icon: Icon(Icons.open_in_browser, size: 16, color: color),
                label: Text(
                  'Book via Official Website',
                  style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _typeIcon(String category) {
    switch (category) {
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
        return Icons.directions_bus;
      default:
        return Icons.commute;
    }
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
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

  Widget _buildCurrencySelector(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currencyProvider.selectedCurrency,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.currency_exchange, size: 20, color: Colors.black54),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          items: currencyProvider.currencies.map((String cur) {
            return DropdownMenuItem<String>(value: cur, child: Text(cur));
          }).toList(),
          onChanged: (String? newVal) {
            if (newVal != null) currencyProvider.setCurrency(newVal);
          },
        ),
      ),
    );
  }
}
