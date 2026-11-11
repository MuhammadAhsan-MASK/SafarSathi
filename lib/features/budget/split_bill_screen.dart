import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'models/group_expense_model.dart';
import 'models/saved_trip_model.dart';
import 'services/saved_trips_service.dart';
import 'smart_packing_screen.dart';

class SplitBillScreen extends StatefulWidget {
  final SavedTrip? initialTrip;

  const SplitBillScreen({super.key, this.initialTrip});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final SavedTripsService _tripsService = SavedTripsService();
  final GroupSplitService _splitService = GroupSplitService();

  List<SavedTrip> _savedTrips = [];
  SavedTrip? _activeTrip;

  final List<Person> _people = [];
  final List<GroupExpense> _expenses = [];
  final Set<String> _settledKeys = {};
  bool _isLoading = true;

  final Map<String, (IconData, Color)> _categoryMeta = {
    'Fuel & Transport': (Icons.local_gas_station_rounded, const Color(0xFF0284C7)),
    'Food & Dining': (Icons.restaurant_rounded, const Color(0xFFEA580C)),
    'Hotel & Stay': (Icons.hotel_rounded, const Color(0xFF7C3AED)),
    'Tolls & Tickets': (Icons.confirmation_number_rounded, const Color(0xFF0D9488)),
    'Shopping & Misc': (Icons.shopping_bag_rounded, const Color(0xFFDB2777)),
    'General': (Icons.receipt_long_rounded, const Color(0xFF6A1B9A)),
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    final trips = await _tripsService.getSavedTrips();
    _savedTrips = trips;

    if (widget.initialTrip != null) {
      _activeTrip = trips.firstWhere(
        (t) => t.id == widget.initialTrip!.id,
        orElse: () => widget.initialTrip!,
      );
    } else if (trips.isNotEmpty) {
      _activeTrip = trips.firstWhere((t) => t.isCurrent, orElse: () => trips.first);
    } else {
      _activeTrip = null;
    }

    if (_activeTrip != null) {
      await _loadTripKhata(_activeTrip!);
    } else {
      _people.clear();
      _expenses.clear();
      _settledKeys.clear();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTripKhata(SavedTrip trip) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final peopleKey = 'safar_split_people_${trip.id}';
      final expensesKey = 'safar_split_expenses_${trip.id}';
      final settledKey = 'safar_split_settled_${trip.id}';

      final peopleJson = prefs.getString(peopleKey);
      final expensesJson = prefs.getString(expensesKey);
      final settledList = prefs.getStringList(settledKey);

      _people.clear();
      _expenses.clear();
      _settledKeys.clear();

      if (peopleJson != null) {
        final List<dynamic> pList = jsonDecode(peopleJson);
        _people.addAll(pList.map((m) => Person.fromMap(Map<String, dynamic>.from(m))));
      } else {
        for (final name in trip.companions) {
          if (name.trim().isNotEmpty) {
            _people.add(Person(
              id: 'p_${name.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}_${DateTime.now().microsecondsSinceEpoch}',
              name: name.trim(),
            ));
          }
        }
      }

      if (expensesJson != null) {
        final List<dynamic> eList = jsonDecode(expensesJson);
        _expenses.addAll(eList.map((m) => GroupExpense.fromMap(Map<String, dynamic>.from(m))));
      }

      if (settledList != null) {
        _settledKeys.addAll(settledList);
      }
    } catch (e) {
      debugPrint('Error loading trip khata: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCurrentTripKhata() async {
    if (_activeTrip == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final peopleKey = 'safar_split_people_${_activeTrip!.id}';
      final expensesKey = 'safar_split_expenses_${_activeTrip!.id}';
      final settledKey = 'safar_split_settled_${_activeTrip!.id}';

      await prefs.setString(peopleKey, jsonEncode(_people.map((p) => p.toMap()).toList()));
      await prefs.setString(expensesKey, jsonEncode(_expenses.map((e) => e.toMap()).toList()));
      await prefs.setStringList(settledKey, _settledKeys.toList());
    } catch (e) {
      debugPrint('Error saving trip khata: $e');
    }
  }

  Future<void> _switchTrip(SavedTrip trip) async {
    if (_activeTrip?.id == trip.id) return;
    await _saveCurrentTripKhata();
    setState(() {
      _isLoading = true;
      _activeTrip = trip;
    });
    await _tripsService.setCurrentTrip(trip.id);
    final updatedTrips = await _tripsService.getSavedTrips();
    if (mounted) {
      setState(() => _savedTrips = updatedTrips);
    }
    await _loadTripKhata(trip);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched Safar Khata to "${trip.title}"'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _deleteCurrentTrip() async {
    if (_activeTrip == null) return;
    final tripTitle = _activeTrip!.title;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Trip Khata?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Text('Remove "$tripTitle" and all its recorded expenses?', style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _tripsService.deleteTrip(_activeTrip!.id);
      await _initializeData();
    }
  }

  void _addPerson() {
    if (_activeTrip == null) {
      _showCreateTripDialog();
      return;
    }
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add_rounded, color: AppTheme.primaryPurple, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Add Trip Member', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Companion Name',
            hintText: 'Enter member name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _people.add(Person(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                  ));
                });
                _saveCurrentTripKhata();
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Add Member'),
          ),
        ],
      ),
    );
  }

  void _addExpense() {
    if (_activeTrip == null) {
      _showCreateTripDialog();
      return;
    }
    if (_people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one trip companion first.')),
      );
      return;
    }

    Person selectedPayer = _people.first;
    String selectedCategory = _categoryMeta.keys.first;
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final Set<Person> splitParticipants = Set.from(_people);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryOrange, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Add Trip Expense', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: descCtrl,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'e.g. Fuel, Hotel Stay, Dinner',
                          prefixIcon: const Icon(Icons.edit_note_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount (PKR)',
                          hintText: 'e.g. 5000',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(_categoryMeta[selectedCategory]?.$1 ?? Icons.receipt_long_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _categoryMeta.keys.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Person>(
                        value: selectedPayer,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Paid By',
                          prefixIcon: const Icon(Icons.person_rounded),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _people.map((p) {
                          return DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedPayer = val);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      Text('Split Equally Among:', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _people.map((p) {
                          final isIncluded = splitParticipants.contains(p);
                          return FilterChip(
                            label: Text(p.name, style: TextStyle(color: isIncluded ? AppTheme.primaryPurple : Colors.black87)),
                            selected: isIncluded,
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  splitParticipants.add(p);
                                } else {
                                  if (splitParticipants.length > 1) {
                                    splitParticipants.remove(p);
                                  }
                                }
                              });
                            },
                            selectedColor: AppTheme.primaryPurple.withValues(alpha: 0.2),
                            checkmarkColor: AppTheme.primaryPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    final double? amount = double.tryParse(amountCtrl.text.trim());
                    final desc = descCtrl.text.trim();
                    if (amount != null && amount > 0 && desc.isNotEmpty) {
                      setState(() {
                        _expenses.add(GroupExpense(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          description: desc,
                          amount: amount,
                          paidBy: selectedPayer,
                          splitAmong: splitParticipants.toList(),
                          category: selectedCategory,
                          date: DateTime.now(),
                        ));
                      });
                      _saveCurrentTripKhata();
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Expense'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateTripDialog() {
    final titleCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final originCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final companionsCtrl = TextEditingController();
    int days = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_location_alt_rounded, color: AppTheme.primaryPurple, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Create Trip Khata', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Trip Title',
                        hintText: 'e.g. Weekend Trip to Naran',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: originCtrl,
                            decoration: InputDecoration(
                              labelText: 'From',
                              hintText: 'e.g. Lahore',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: destCtrl,
                            decoration: InputDecoration(
                              labelText: 'Destination',
                              hintText: 'e.g. Hunza',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: budgetCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Est. Budget',
                              hintText: 'e.g. 50000',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: days,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: [1, 2, 3, 4, 5, 7, 10, 14].map((d) {
                              return DropdownMenuItem(value: d, child: Text('$d Days'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setDlgState(() => days = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: companionsCtrl,
                      decoration: InputDecoration(
                        labelText: 'Members (comma separated)',
                        hintText: 'e.g. Ahmed, Bilal, Me',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  final dest = destCtrl.text.trim();
                  final rawTitle = titleCtrl.text.trim();
                  if (dest.isEmpty && rawTitle.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a Trip Title or Destination.')),
                    );
                    return;
                  }

                  final title = rawTitle.isNotEmpty ? rawTitle : '$dest Trip';
                  final finalDest = dest.isNotEmpty ? dest : rawTitle;
                  final origin = originCtrl.text.trim().isNotEmpty ? originCtrl.text.trim() : 'Home';
                  final budget = double.tryParse(budgetCtrl.text.trim()) ?? 0.0;
                  final rawComps = companionsCtrl.text.split(',');
                  final comps = rawComps.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

                  final newTrip = SavedTrip(
                    id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    destination: finalDest,
                    origin: origin,
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(Duration(days: days > 1 ? days - 1 : 0)),
                    budget: budget,
                    travelers: comps.isNotEmpty ? comps.length : 1,
                    companions: comps,
                    isCurrent: true,
                  );

                  await _tripsService.saveTrip(newTrip);
                  if (ctx.mounted) Navigator.pop(ctx);
                  await _initializeData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save & Open Khata'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _shareKhataSummary(BuildContext context) {
    if (_expenses.isEmpty) return;

    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final settlements = _splitService.calculateSettlements(_people, _expenses);
    final double totalSpent = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    final double avgPerPerson = _people.isNotEmpty ? totalSpent / _people.length : 0.0;

    final buffer = StringBuffer();
    buffer.writeln('🏔️ SafarSathi - Safar Khata Summary');
    if (_activeTrip != null) {
      buffer.writeln('📍 Trip: ${_activeTrip!.title} (${_activeTrip!.origin} ➔ ${_activeTrip!.destination})');
      buffer.writeln('⏱️ Duration: ${_activeTrip!.durationDays} Days');
      if (_activeTrip!.budget > 0) {
        buffer.writeln('💵 Est Budget: ${currency.formatPrice(_activeTrip!.budget)}');
      }
    }
    buffer.writeln('👥 Trip Members: ${_people.map((p) => p.name).join(', ')}');
    buffer.writeln('💰 Total Spent: ${currency.formatPrice(totalSpent)}');
    buffer.writeln('📊 Average / Person: ${currency.formatPrice(avgPerPerson)}');
    buffer.writeln('----------------------------------------');
    buffer.writeln('🤝 Balances & Settlements:');

    if (settlements.isEmpty) {
      buffer.writeln('✅ All settled up! No outstanding balances.');
    } else {
      for (final s in settlements) {
        final key = '${s.fromPerson.id}_${s.toPerson.id}';
        final isDone = _settledKeys.contains(key);
        buffer.writeln('${isDone ? '✅ [PAID]' : '👉'} ${s.fromPerson.name} owes ${s.toPerson.name}: ${currency.formatPrice(s.amount)}');
      }
    }
    buffer.writeln('----------------------------------------');
    buffer.writeln('Generated via SafarSathi App 🇵🇰');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Trip settlement summary copied! Ready to paste on WhatsApp.')),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<CurrencyProvider>(context);
    final double totalSpent = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    final double avgPerPerson = _people.isNotEmpty ? totalSpent / _people.length : 0.0;

    final Map<String, double> payerTotals = {};
    for (var e in _expenses) {
      payerTotals[e.paidBy.name] = (payerTotals[e.paidBy.name] ?? 0.0) + e.amount;
    }
    String topPayerName = 'None';
    double topPayerAmount = 0.0;
    payerTotals.forEach((name, amt) {
      if (amt > topPayerAmount) {
        topPayerAmount = amt;
        topPayerName = name;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Safar Khata • Group Split', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_expenses.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share_rounded, size: 20),
              tooltip: 'Share via WhatsApp / Clipboard',
              onPressed: () => _shareKhataSummary(context),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'new_trip') {
                _showCreateTripDialog();
              } else if (val == 'packing') {
                if (_activeTrip != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SmartPackingScreen(
                        destination: _activeTrip!.destination,
                        duration: '${_activeTrip!.durationDays} Days',
                      ),
                    ),
                  );
                }
              } else if (val == 'delete_trip') {
                _deleteCurrentTrip();
              } else if (val == 'clear') {
                setState(() {
                  _people.clear();
                  _expenses.clear();
                  _settledKeys.clear();
                });
                _saveCurrentTripKhata();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'new_trip', child: Text('🗺️ Create New Trip Khata')),
              if (_activeTrip != null) ...[
                const PopupMenuItem(value: 'packing', child: Text('🎒 AI Packing Checklist')),
                const PopupMenuItem(value: 'clear', child: Text('🧹 Clear Trip Expenses')),
                const PopupMenuItem(value: 'delete_trip', child: Text('🗑️ Delete This Trip', style: TextStyle(color: Colors.red))),
              ],
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedTrips.isEmpty
              ? _buildNoSavedTripsEmptyState()
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // 1. Saved Trips Horizontal Selector
                      _buildSavedTripsBar(context, currency),

                      // 2. Executive KPI Header Card
                      _buildExecutiveKpiHeader(currency, totalSpent, avgPerPerson, topPayerName, topPayerAmount),

                      // 3. Tab Bar
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: TabBar(
                          labelColor: AppTheme.primaryPurple,
                          unselectedLabelColor: const Color(0xFF64748B),
                          indicatorColor: AppTheme.primaryPurple,
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                          tabs: [
                            Tab(text: "Expenses (${_expenses.length})"),
                            const Tab(text: "Settlements & Debts"),
                          ],
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildExpensesTab(currency),
                            _buildSettlementsTab(currency),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_activeTrip == null) {
            _showCreateTripDialog();
            return;
          }
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            builder: (ctx) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Wrap(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primaryPurple.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primaryPurple),
                    ),
                    title: Text('Add New Expense', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    subtitle: Text('Record in ${_activeTrip?.title ?? 'Trip'}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _addExpense();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.person_add_rounded, color: Colors.blue),
                    ),
                    title: Text('Add Trip Member', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Add a companion to the group split'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _addPerson();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppTheme.primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.add_location_alt_rounded, color: AppTheme.primaryOrange),
                    ),
                    title: Text('Save Another Trip', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Create a new trip khata for a different route'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showCreateTripDialog();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          _activeTrip == null ? 'New Trip Khata' : 'Record Khata',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildNoSavedTripsEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.luggage_rounded, size: 54, color: AppTheme.primaryPurple),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Trips Yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a trip khata or save an itinerary from the Trip Planner to add your travel companions and track shared group expenses.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showCreateTripDialog,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text('Create First Trip Khata', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedTripsBar(BuildContext context, CurrencyProvider currency) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.luggage_rounded, size: 16, color: AppTheme.primaryPurple),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'YOUR SAVED TRIPS (${_savedTrips.length})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _showCreateTripDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 15, color: AppTheme.primaryPurple),
                        const SizedBox(width: 2),
                        Text(
                          'New Trip',
                          style: GoogleFonts.poppins(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 98,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _savedTrips.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == _savedTrips.length) {
                  return InkWell(
                    onTap: _showCreateTripDialog,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_rounded, color: AppTheme.primaryPurple, size: 20),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+ Add Trip',
                            style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final trip = _savedTrips[index];
                final isSelected = _activeTrip?.id == trip.id;

                return InkWell(
                  onTap: () => _switchTrip(trip),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryPurple : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryPurple.withValues(alpha: 0.12)
                                    : Colors.grey.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isSelected ? '● ACTIVE TRIP' : 'SWITCH TRIP',
                                style: GoogleFonts.poppins(
                                  color: isSelected ? AppTheme.primaryPurple : const Color(0xFF64748B),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              size: 16,
                              color: isSelected ? AppTheme.primaryPurple : const Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        Text(
                          trip.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF475569),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.route_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${trip.origin} ➔ ${trip.destination}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                              ),
                            ),
                            Text(
                              '${trip.durationDays}d',
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryOrange),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveKpiHeader(
      CurrencyProvider currency, double total, double avg, String topName, double topAmt) {
    final trip = _activeTrip;
    final budget = trip?.budget ?? 0.0;
    final hasBudget = budget > 0;
    final isOverBudget = hasBudget && total > budget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B108E), Color(0xFF7E22CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 15, color: Colors.amberAccent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        trip != null ? trip.title : 'Current Trip Khata',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (trip != null)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SmartPackingScreen(
                          destination: trip.destination,
                          duration: '${trip.durationDays} Days',
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.backpack_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          'Packing List',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL KHATA SPENT',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        currency.formatPrice(total),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBudget)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isOverBudget ? Colors.red.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Trip Budget', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9.5)),
                      Text(
                        currency.formatPrice(budget),
                        style: GoogleFonts.poppins(
                          color: isOverBudget ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avg / Person (${_people.length})', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9.5)),
                      Text(currency.formatPrice(avg),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Payer', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9.5)),
                      Text(
                        topName == 'None' ? '--' : '$topName (${currency.formatPrice(topAmt)})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: Colors.amberAccent, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(CurrencyProvider currency) {
    if (_people.isEmpty && _expenses.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.primaryPurple.withValues(alpha: 0.08), shape: BoxShape.circle),
                child: const Icon(Icons.people_alt_rounded, size: 48, color: AppTheme.primaryPurple),
              ),
              const SizedBox(height: 16),
              Text(
                'Start "${_activeTrip?.title ?? 'Trip'}" Khata',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Add your companions and record shared fuel, hotel, and dining bills to track who owes whom.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _addPerson,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add First Companion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trip Members (${_people.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5)),
            InkWell(
              onTap: _addPerson,
              child: Text('+ Add Member',
                  style: GoogleFonts.poppins(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _people.map((p) {
            return Chip(
              avatar: CircleAvatar(
                backgroundColor: AppTheme.primaryPurple,
                child: Text(p.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              label: Text(p.name, style: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w500)),
              backgroundColor: Colors.white,
              elevation: 1,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE2E8F0))),
              deleteIcon: const Icon(Icons.close_rounded, size: 14),
              onDeleted: () {
                setState(() {
                  _people.remove(p);
                  _expenses.removeWhere((e) => e.paidBy == p || e.splitAmong.contains(p));
                });
                _saveCurrentTripKhata();
              },
            );
          }).toList(),
        ),

        const Divider(height: 24),

        Text('Shared Expenses (${_expenses.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5)),
        const SizedBox(height: 8),

        if (_expenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text('No expenses recorded for this trip yet. Tap "+ Record Khata" below.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            ),
          )
        else
          ..._expenses.reversed.map((e) {
            final meta = _categoryMeta[e.category] ?? _categoryMeta['General']!;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                ],
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: meta.$2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(meta.$1, color: meta.$2, size: 19),
                ),
                title: Text(e.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text(
                  'Paid by ${e.paidBy.name} • Split: ${e.splitAmong.length} people',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.formatPrice(e.amount),
                      style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () {
                        setState(() => _expenses.remove(e));
                        _saveCurrentTripKhata();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSettlementsTab(CurrencyProvider currency) {
    if (_expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.handshake_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('No Settlements to Calculate', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Add your expenses in the first tab to view optimized settlements.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final settlements = _splitService.calculateSettlements(_people, _expenses);

    if (settlements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, size: 54, color: Color(0xFF10B981)),
              const SizedBox(height: 12),
              Text('All Clear & Settled!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('Everyone has paid their exact share. Zero debt remaining.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Optimized Cash Transfers', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold)),
            ),
            Text('${settlements.length} transfers needed',
                style: GoogleFonts.poppins(fontSize: 11.5, color: AppTheme.primaryPurple, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        ...settlements.map((s) {
          final key = '${s.fromPerson.id}_${s.toPerson.id}';
          final isDone = _settledKeys.contains(key);

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFF1FDF5) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDone ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isDone ? Colors.green.shade100 : Colors.red.shade100,
                  child: Text(
                    s.fromPerson.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: isDone ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
                          children: [
                            TextSpan(text: s.fromPerson.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' owes '),
                            TextSpan(text: s.toPerson.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currency.formatPrice(s.amount),
                        style: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDone ? const Color(0xFF059669) : const Color(0xFFE11D48),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (isDone) {
                        _settledKeys.remove(key);
                      } else {
                        _settledKeys.add(key);
                      }
                    });
                    _saveCurrentTripKhata();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDone ? const Color(0xFF10B981) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: 14,
                          color: isDone ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDone ? 'Paid' : 'Mark Paid',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDone ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
