import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'services/transport_service.dart';
import 'models/transport_model.dart';
import 'package:url_launcher/url_launcher.dart';

enum TransportStep { selectType, selectDeparture, selectDestination, showResults }

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TransportService _transportService = TransportService();
  TransportStep _step = TransportStep.selectType;
  String? _selectedType; // 'bus', 'flight', 'train'
  String _departure = '';
  String _destination = '';

  final List<String> _cities = [
    'Islamabad', 'Karachi', 'Lahore', 'Peshawar',
    'Quetta', 'Multan', 'Skardu', 'Hunza', 'Swat',
  ];

  void _reset() {
    setState(() {
      _step = TransportStep.selectType;
      _selectedType = null;
      _departure = '';
      _destination = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.transportBg,
      appBar: AppBar(
        title: const Text('Transport & Routes'),
        backgroundColor: Colors.transparent,
        actions: [
          if (_step != TransportStep.selectType)
            TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
              label: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
          _buildCurrencySelector(context),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_step) {
      case TransportStep.selectType:
        return _buildSelectType();
      case TransportStep.selectDeparture:
        return _buildSelectCity(
          title: 'Where are you departing from?',
          icon: Icons.flight_takeoff,
          onSelect: (city) => setState(() {
            _departure = city;
            _step = TransportStep.selectDestination;
          }),
        );
      case TransportStep.selectDestination:
        return _buildSelectCity(
          title: 'Where are you going?',
          icon: Icons.location_on,
          exclude: _departure,
          onSelect: (city) => setState(() {
            _destination = city;
            _step = TransportStep.showResults;
          }),
        );
      case TransportStep.showResults:
        return _buildResults();
    }
  }

  // ── Step 1: Select Transport Type ──────────────────────────────────────────
  Widget _buildSelectType() {
    return Column(
      children: [
        _buildProgressBar(1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How would you like to travel?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Select your preferred mode of transport',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 32),
                _transportTypeCard(
                  icon: Icons.flight,
                  label: 'Flight',
                  subtitle: 'Fastest. All major airports.',
                  color: Colors.blue.shade700,
                  category: 'flight',
                ),
                const SizedBox(height: 16),
                _transportTypeCard(
                  icon: Icons.directions_bus,
                  label: 'Bus',
                  subtitle: 'Affordable. Daewoo, Faisal Movers, NATCO & more.',
                  color: Colors.deepOrange,
                  category: 'bus',
                ),
                const SizedBox(height: 16),
                _transportTypeCard(
                  icon: Icons.train,
                  label: 'Train',
                  subtitle: 'Scenic. Pakistan Railways network.',
                  color: Colors.teal,
                  category: 'train',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _transportTypeCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required String category,
  }) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedType = category;
        _step = TransportStep.selectDeparture;
      }),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Step 2 & 3: Select City ─────────────────────────────────────────────────
  Widget _buildSelectCity({
    required String title,
    required IconData icon,
    required Function(String) onSelect,
    String? exclude,
  }) {
    final availableCities = _cities.where((c) => c != exclude).toList();
    final stepNum = _step == TransportStep.selectDeparture ? 2 : 3;
    return Column(
      children: [
        _buildProgressBar(stepNum),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_step == TransportStep.selectDestination)
                  GestureDetector(
                    onTap: () => setState(() => _step = TransportStep.selectDeparture),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
                        Text('From: $_departure',
                            style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                if (_step == TransportStep.selectDestination) const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(icon, color: AppTheme.primaryPurple),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: availableCities.length,
                    itemBuilder: (context, index) {
                      final city = availableCities[index];
                      return GestureDetector(
                        onTap: () => onSelect(city),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            city,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 4: Results ─────────────────────────────────────────────────────────
  Widget _buildResults() {
    final warning = _transportService.getSeasonalWarning(_departure, _destination);
    return Column(
      children: [
        _buildProgressBar(4),
        if (warning != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(warning,
                      style: const TextStyle(
                          color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        // Route header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _typeBadge(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$_departure  →  $_destination',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _step = TransportStep.selectDeparture),
                child: Icon(Icons.edit, size: 18, color: AppTheme.primaryPurple),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<TransportOption>>(
            stream: _transportService.getTransportOptions(
              source: _departure,
              destination: _destination,
              category: _selectedType,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final options = snapshot.data ?? [];
              if (options.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_typeIcon(), size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 14),
                      Text(
                        'No ${_selectedType ?? ''} options found\nfor $_departure → $_destination',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _reset, child: const Text('Try another route')),
                    ],
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
    );
  }

  Widget _buildTransportCard(BuildContext context, TransportOption option) {
    final color = _colorForCategory(option.category);
    final seats = option.availableSeats;
    final seatsColor = seats <= 5 ? Colors.red : (seats <= 15 ? Colors.orange : Colors.green);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Type icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.type,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis),
                    if (option.operator.isNotEmpty)
                      Text(option.operator,
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 3),
                        Text('Departs ${option.departureTime}  •  ${option.time}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Provider.of<CurrencyProvider>(context).formatPrice(option.fare),
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold, color: color),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: seatsColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$seats seats left',
                      style: TextStyle(
                          fontSize: 10, color: seatsColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (option.typePrices.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: option.typePrices.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${e.key}: ${Provider.of<CurrencyProvider>(context, listen: false).formatPrice(e.value)}',
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
            ),
          ],
          if (option.websiteUrl != null && option.websiteUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchUrl(option.websiteUrl!),
                icon: Icon(Icons.open_in_browser, size: 16, color: color),
                label: Text('Book via Official Website', style: TextStyle(color: color, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  Widget _buildProgressBar(int step) {
    return Container(
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i < step ? AppTheme.primaryPurple : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _typeBadge() {
    final color = _colorForCategory(_selectedType ?? 'bus');
    final label = _selectedType == 'flight'
        ? '✈️ Flight'
        : _selectedType == 'train'
            ? '🚆 Train'
            : '🚌 Bus';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  IconData _typeIcon() {
    switch (_selectedType) {
      case 'flight':
        return Icons.flight;
      case 'train':
        return Icons.train;
      default:
        return Icons.directions_bus_outlined;
    }
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'flight':
        return Colors.blue.shade700;
      case 'train':
        return Colors.teal;
      default:
        return Colors.deepOrange;
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
