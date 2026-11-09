import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'models/group_expense_model.dart';

class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({super.key});

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  final List<Person> _people = [];
  final List<GroupExpense> _expenses = [];
  final Set<String> _settledKeys = {};
  final GroupSplitService _splitService = GroupSplitService();
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
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final peopleJson = prefs.getString('safar_split_people');
      final expensesJson = prefs.getString('safar_split_expenses');
      final settledJson = prefs.getStringList('safar_split_settled');

      if (peopleJson != null) {
        final List<dynamic> pList = jsonDecode(peopleJson);
        _people.clear();
        _people.addAll(pList.map((m) => Person.fromMap(Map<String, dynamic>.from(m))));
      }

      if (expensesJson != null) {
        final List<dynamic> eList = jsonDecode(expensesJson);
        _expenses.clear();
        _expenses.addAll(eList.map((m) => GroupExpense.fromMap(Map<String, dynamic>.from(m))));
      }

      if (settledJson != null) {
        _settledKeys.clear();
        _settledKeys.addAll(settledJson);
      }
    } catch (e) {
      debugPrint('Error loading split bill storage: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('safar_split_people', jsonEncode(_people.map((p) => p.toMap()).toList()));
      await prefs.setString('safar_split_expenses', jsonEncode(_expenses.map((e) => e.toMap()).toList()));
      await prefs.setStringList('safar_split_settled', _settledKeys.toList());
    } catch (e) {
      debugPrint('Error saving split bill storage: $e');
    }
  }

  void _loadSampleTrip() {
    setState(() {
      _people.clear();
      final ali = Person(id: 'p1', name: 'Ali');
      final hamza = Person(id: 'p2', name: 'Hamza');
      final ahsan = Person(id: 'p3', name: 'Ahsan');
      _people.addAll([ali, hamza, ahsan]);

      _expenses.clear();
      _expenses.addAll([
        GroupExpense(
          id: 'e1',
          description: 'Hiace Fuel (Islamabad to Naran)',
          amount: 14000,
          paidBy: ali,
          splitAmong: [ali, hamza, ahsan],
          category: 'Fuel & Transport',
          date: DateTime.now().subtract(const Duration(days: 1)),
        ),
        GroupExpense(
          id: 'e2',
          description: 'Pine Top Resort Hotel (2 Rooms)',
          amount: 28000,
          paidBy: ahsan,
          splitAmong: [ali, hamza, ahsan],
          category: 'Hotel & Stay',
          date: DateTime.now().subtract(const Duration(hours: 18)),
        ),
        GroupExpense(
          id: 'e3',
          description: 'Riverside Trout Dinner & Chai',
          amount: 6500,
          paidBy: hamza,
          splitAmong: [ali, hamza, ahsan],
          category: 'Food & Dining',
          date: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        GroupExpense(
          id: 'e4',
          description: 'Babusar Top Jeep Safari',
          amount: 7500,
          paidBy: ali,
          splitAmong: [ali, hamza, ahsan],
          category: 'Tolls & Tickets',
          date: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ]);
      _settledKeys.clear();
    });
    _saveToStorage();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Sample Murree/Naran group trip loaded!'),
          ],
        ),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addPerson() {
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
            Text('Add Trip Member', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Companion Name',
            hintText: 'e.g. Hamza, Meer, Sara',
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
                _saveToStorage();
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
                  Text('Add Trip Expense', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          hintText: 'e.g. Fuel, Hotel, Trout Fish, Jeep',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount (PKR)',
                          hintText: 'e.g. 8500',
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<Person>(
                        decoration: InputDecoration(
                          labelText: 'Paid By',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedPayer,
                        items: _people.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                        onChanged: (p) {
                          if (p != null) setDialogState(() => selectedPayer = p);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        value: selectedCategory,
                        items: _categoryMeta.keys.map((cat) {
                          final meta = _categoryMeta[cat]!;
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(meta.$1, size: 16, color: meta.$2),
                                const SizedBox(width: 8),
                                Text(cat, style: GoogleFonts.poppins(fontSize: 13)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (cat) {
                          if (cat != null) setDialogState(() => selectedCategory = cat);
                        },
                      ),
                      const SizedBox(height: 14),
                      Text('Split Among (${splitParticipants.length}/${_people.length})',
                          style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: _people.map((p) {
                          final isSelected = splitParticipants.contains(p);
                          return FilterChip(
                            label: Text(p.name),
                            selected: isSelected,
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
                      _saveToStorage();
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

  void _shareKhataSummary(BuildContext context) {
    if (_expenses.isEmpty) return;

    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final settlements = _splitService.calculateSettlements(_people, _expenses);
    final double totalSpent = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    final double avgPerPerson = _people.isNotEmpty ? totalSpent / _people.length : 0.0;

    final buffer = StringBuffer();
    buffer.writeln('🏔️ SafarSathi - Group Trip Khata Summary');
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
            Text('Trip settlement summary copied to clipboard! Ready to paste on WhatsApp.'),
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

    // Find top payer
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
              if (val == 'sample') {
                _loadSampleTrip();
              } else if (val == 'clear') {
                setState(() {
                  _people.clear();
                  _expenses.clear();
                  _settledKeys.clear();
                });
                _saveToStorage();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'sample', child: Text('⚡ Load Sample Trip')),
              const PopupMenuItem(value: 'clear', child: Text('🗑️ Clear All Data', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // KPI Header Card
                  _buildExecutiveKpiHeader(currency, totalSpent, avgPerPerson, topPayerName, topPayerAmount),

                  // Modern Tab Bar
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
                    subtitle: const Text('Record fuel, hotel, dining, or tickets'),
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
                ],
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Record Khata', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildExecutiveKpiHeader(
      CurrencyProvider currency, double total, double avg, String topName, double topAmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
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
              Text(
                'GROUP TRIP SPENDING',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_people.length} Companions',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            currency.formatPrice(total),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Avg / Person', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                      Text(currency.formatPrice(avg),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Top Payer', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                      Text(
                        topName == 'None' ? '--' : '$topName (${currency.formatPrice(topAmt)})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: Colors.amberAccent, fontSize: 12.5, fontWeight: FontWeight.bold),
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
        child: Padding(
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
              Text('Start Your Trip Khata', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                'Add your travel companions and record shared fuel, hotel, and dining bills to automatically calculate who owes whom.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _loadSampleTrip,
                icon: const Icon(Icons.bolt_rounded, color: AppTheme.primaryOrange),
                label: const Text('Load Sample Murree Weekend Trip'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryOrange,
                  side: const BorderSide(color: AppTheme.primaryOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      children: [
        // Trip Members Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trip Members (${_people.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
            InkWell(
              onTap: _addPerson,
              child: Text('+ Add Person',
                  style: GoogleFonts.poppins(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
              label: Text(p.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
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
                _saveToStorage();
              },
            );
          }).toList(),
        ),

        const Divider(height: 28),

        // Shared Expenses List
        Text('Shared Expenses (${_expenses.length})', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),

        if (_expenses.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Text('No expenses recorded yet. Tap "+ Record Khata" below.',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: meta.$2.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(meta.$1, color: meta.$2, size: 20),
                ),
                title: Text(e.description, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13.5)),
                subtitle: Text(
                  'Paid by ${e.paidBy.name} • Split: ${e.splitAmong.length} people',
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currency.formatPrice(e.amount),
                      style: GoogleFonts.poppins(color: const Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                      onPressed: () {
                        setState(() => _expenses.remove(e));
                        _saveToStorage();
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
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    final settlements = _splitService.calculateSettlements(_people, _expenses);

    if (settlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 54, color: Color(0xFF10B981)),
            const SizedBox(height: 12),
            Text('All Clear & Settled!', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Everyone has paid their exact share. Zero debt remaining.',
                style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontSize: 13)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Optimized Cash Transfers', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('${settlements.length} transfers needed',
                style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.primaryPurple, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 10),
        ...settlements.map((s) {
          final key = '${s.fromPerson.id}_${s.toPerson.id}';
          final isDone = _settledKeys.contains(key);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFF1FDF5) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDone ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Debtor Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isDone ? Colors.green.shade100 : Colors.red.shade100,
                  child: Text(
                    s.fromPerson.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: isDone ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(fontSize: 13.5, color: const Color(0xFF1E293B)),
                          children: [
                            TextSpan(text: s.fromPerson.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' owes '),
                            TextSpan(text: s.toPerson.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currency.formatPrice(s.amount),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
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
                    _saveToStorage();
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
                          size: 15,
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
