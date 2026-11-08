import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../core/weather_service.dart';
import 'budget_analysis_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _originController = TextEditingController(text: 'Karachi');
  final _destinationController = TextEditingController(text: 'Islamabad');
  final _budgetController = TextEditingController(text: '50000');
  final _travelersController = TextEditingController(text: '1');
  DateTime? _startDate;
  DateTime? _endDate;
  int _travelers = 1;
  bool _isLoading = false;

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _travelersController.dispose();
    super.dispose();
  }

  final List<String> _popularOrigins = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Rawalpindi',
    'Peshawar',
    'Multan',
    'Faisalabad',
  ];

  final List<String> _popularDestinations = [
    'Islamabad',
    'Hunza',
    'Skardu',
    'Swat',
    'Murree',
    'Lahore',
    'Karachi',
  ];

  DestinationWeather? _destinationWeather;
  bool _isLoadingWeather = false;

  @override
  void initState() {
    super.initState();
    _loadWeatherForDestination(_destinationController.text);
  }

  Future<void> _loadWeatherForDestination(String destination) async {
    final city = destination.trim();
    if (city.isEmpty) return;
    setState(() => _isLoadingWeather = true);
    final weather = await WeatherService.getDestinationWeatherDetails(city);
    if (mounted) {
      setState(() {
        _destinationWeather = weather;
        _isLoadingWeather = false;
      });
    }
  }

  void _swapRoute() {
    setState(() {
      final temp = _originController.text;
      _originController.text = _destinationController.text;
      _destinationController.text = temp;
    });
    _loadWeatherForDestination(_destinationController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildGradientHeader(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Route Section (From & To) ─────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputField(
                              'From (Departure)',
                              Icons.flight_takeoff_rounded,
                              'e.g., Karachi, Lahore',
                              _originController,
                            ),
                            const SizedBox(height: 8),
                            _buildQuickChips(_popularOrigins, (city) {
                              setState(() => _originController.text = city);
                            }, _originController.text),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'To (Destination)',
                              Icons.location_on_outlined,
                              'e.g., Islamabad, Hunza, Skardu',
                              _destinationController,
                              onSubmitted: (val) => _loadWeatherForDestination(val),
                            ),
                            const SizedBox(height: 8),
                            _buildQuickChips(_popularDestinations, (city) {
                              setState(() => _destinationController.text = city);
                              _loadWeatherForDestination(city);
                            }, _destinationController.text),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: InkWell(
                          onTap: _swapRoute,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.swap_vert_rounded, color: AppTheme.primaryPurple, size: 26),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Live Destination Weather Badge ──────────────────────
                  _buildLiveWeatherBadge(),
                  const SizedBox(height: 18),

                  // ── Dates ────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker('Start Date', _startDate, (date) => setState(() => _startDate = date))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDatePicker('End Date', _endDate, (date) => setState(() => _endDate = date))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Travelers ─────────────────────────────────────────────
                  _buildTravelersInput(),
                  const SizedBox(height: 20),

                  // ── Budget ────────────────────────────────────────────────
                  _buildInputField(
                    'Total Budget (PKR)',
                    Icons.account_balance_wallet_outlined,
                    'e.g., 50000',
                    _budgetController,
                    isNumber: true,
                  ),
                  const SizedBox(height: 30),

                  // ── Preview ───────────────────────────────────────────────
                  _buildBudgetBreakdownPreview(),
                  const SizedBox(height: 40),

                  // ── Continue Button ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        final origin = _originController.text.trim();
                        final destination = _destinationController.text.trim();

                        if (origin.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a departure city (From)')),
                          );
                          return;
                        }

                        if (destination.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a destination city (To)')),
                          );
                          return;
                        }

                        if (origin.toLowerCase() == destination.toLowerCase()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Departure and destination city must be different')),
                          );
                          return;
                        }

                        // Sync travelers from controller
                        final parsedTravelers = int.tryParse(_travelersController.text.replaceAll(RegExp(r'[^0-9]'), ''));
                        if (parsedTravelers != null && parsedTravelers > 0) {
                          _travelers = parsedTravelers.clamp(1, 100);
                        } else {
                          _travelers = 1;
                          _travelersController.text = '1';
                        }

                        double parsedBudget = 0;
                        try {
                          if (_budgetController.text.isEmpty) {
                            throw const FormatException("Budget cannot be empty.");
                          }
                          final parsedText = _budgetController.text.replaceAll(RegExp(r'[^0-9.]'), '');
                          final tempBudget = double.tryParse(parsedText);
                          
                          if (tempBudget == null) {
                            throw const FormatException("Please enter a valid numeric budget.");
                          }
                          if (tempBudget.isInfinite || tempBudget.isNaN) {
                            throw const FormatException("Calculated budget is invalid.");
                          }
                          if (tempBudget > 1000000000) {
                            throw const FormatException("Budget entered is too large to process realistically.");
                          }
                          if (tempBudget < 1000) {
                            throw const FormatException("Budget cannot be lower than PKR 1000.");
                          }
                          parsedBudget = tempBudget;
                        } on FormatException catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.message)),
                          );
                          return;
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("An unexpected error occurred processing your budget.")),
                          );
                          return;
                        }
                        
                        try {
                          final startDate = _startDate ?? DateTime.now();
                          final endDate = _endDate ?? DateTime.now().add(const Duration(days: 3));
                          int days = endDate.difference(startDate).inDays.abs() + 1;
                          if (days < 1) days = 1;
                          final minBudget = days * 1500 * _travelers;
                          
                          if (parsedBudget < minBudget) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Budget too low for $days day(s) and $_travelers traveler(s). Minimum realistic budget is PKR $minBudget.')),
                            );
                            return;
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error calculating minimum budget constraints.")),
                          );
                          return;
                        }

                        setState(() => _isLoading = true);
                        try {
                          final warning = await WeatherService.checkWeatherWarning(destination);
                          if (warning != null) {
                            if (!context.mounted) return;
                            final proceed = await showDialog<bool>(
                              context: context,
                              builder: (dialogCtx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                backgroundColor: Colors.red.shade50,
                                title: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Text(
                                        'Disaster / Travel Alert',
                                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  warning.message,
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx, false),
                                    child: const Text('Cancel Trip'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogCtx, true),
                                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Proceed Anyway'),
                                  ),
                                ],
                              ),
                            );
                            if (proceed != true) return;
                          }

                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetAnalysisScreen(
                                origin: origin,
                                destination: destination,
                                budget: parsedBudget,
                                startDate: _startDate ?? DateTime.now(),
                                endDate: _endDate ?? DateTime.now().add(const Duration(days: 3)),
                                travelers: _travelers,
                              ),
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Continue to Budget Analysis'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveWeatherBadge() {
    if (_isLoadingWeather) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text('Fetching live satellite weather...', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
          ],
        ),
      );
    }

    if (_destinationWeather == null) {
      return const SizedBox.shrink();
    }

    final w = _destinationWeather!;
    final isAlert = w.isSevere;
    final cardBg = isAlert ? Colors.red.shade50 : const Color(0xFFF0F7FF);
    final borderColor = isAlert ? Colors.red.shade200 : const Color(0xFFBAE6FD);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(w.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          '${w.destination}: ${w.temperature.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isAlert ? Colors.red.shade900 : const Color(0xFF0369A1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isAlert ? Colors.red.shade100 : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            w.condition,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAlert ? Colors.red.shade800 : Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Wind: ${w.windSpeed.toStringAsFixed(0)} km/h • Open-Meteo Live',
                      style: TextStyle(fontSize: 10, color: Colors.blueGrey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 18, color: Colors.blueGrey),
                tooltip: 'Refresh Weather',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () => _loadWeatherForDestination(_destinationController.text),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isAlert ? Icons.warning_amber_rounded : Icons.backpack_outlined,
                  size: 15,
                  color: isAlert ? Colors.red : Colors.teal.shade700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    w.advice,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isAlert ? Colors.red.shade800 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips(List<String> cities, Function(String) onSelect, String currentVal) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cities.map((city) {
          final isSelected = currentVal.toLowerCase() == city.toLowerCase();
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ActionChip(
              label: Text(city),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: isSelected ? AppTheme.primaryPurple : Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              onPressed: () => onSelect(city),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route-Based Travel Planning',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Find authentic flights, buses & trains for your exact route, plus top-rated stays & dining.',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, String hint, TextEditingController controller, {bool isNumber = false, Function(String)? onSubmitted}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          onChanged: (_) => setState(() {}),
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.primaryPurple),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) onSelect(date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20, color: AppTheme.primaryPurple),
                const SizedBox(width: 8),
                Text(
                  selectedDate == null ? 'mm/dd/yy' : '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                  style: TextStyle(color: selectedDate == null ? Colors.grey : Colors.black),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTravelersInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Amount of Members / Travelers',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_travelers ${_travelers == 1 ? 'Member' : 'Members'}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPurple,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Decrease',
                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppTheme.primaryPurple),
                onPressed: _travelers > 1
                    ? () {
                        setState(() {
                          _travelers--;
                          _travelersController.text = _travelers.toString();
                        });
                      }
                    : null,
              ),
              Expanded(
                child: TextField(
                  controller: _travelersController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter amount of members',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                    setState(() {
                      if (parsed != null && parsed > 0) {
                        _travelers = parsed.clamp(1, 100);
                      } else {
                        _travelers = 1;
                      }
                    });
                  },
                ),
              ),
              IconButton(
                tooltip: 'Increase',
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryPurple),
                onPressed: () {
                  setState(() {
                    _travelers++;
                    _travelersController.text = _travelers.toString();
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMemberChip(1, 'Solo (1)'),
              _buildMemberChip(2, 'Couple (2)'),
              _buildMemberChip(4, 'Family (4)'),
              _buildMemberChip(6, 'Group of 6'),
              _buildMemberChip(10, 'Group of 10'),
              _buildMemberChip(15, '15 Members'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberChip(int count, String label) {
    final isSelected = _travelers == count;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _travelers = count;
              _travelersController.text = count.toString();
            });
          }
        },
        labelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
        selectedColor: AppTheme.primaryPurple,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryPurple : Colors.grey.shade300,
          ),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
    );
  }

  Widget _buildBudgetBreakdownPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Budget Breakdown Preview', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildBreakdownItem('Accommodation', '40%', Colors.blue)),
            Expanded(child: _buildBreakdownItem('Food & Dining', '30%', Colors.orange)),
            Expanded(child: _buildBreakdownItem('Transportation', '20%', Colors.green)),
            Expanded(child: _buildBreakdownItem('Activities', '10%', Colors.purple)),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, String percent, Color color) {
    return Column(
      children: [
        Text(percent, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
