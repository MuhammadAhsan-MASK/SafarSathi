import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  final GroupSplitService _splitService = GroupSplitService();

  void _addPerson() {
    String name = "";
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add Person"),
        content: TextField(
          decoration: const InputDecoration(hintText: "Enter name"),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (name.trim().isNotEmpty) {
                setState(() {
                  _people.add(Person(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name.trim()));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addExpense() {
    if (_people.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add people first")));
      return;
    }
    
    Person? selectedPayer = _people.first;
    String description = "";
    String amountStr = "";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Expense"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: "Description (e.g. Dinner, Taxi)"),
                      onChanged: (val) => description = val,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(hintText: "Amount"),
                      keyboardType: TextInputType.number,
                      onChanged: (val) => amountStr = val,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Person>(
                      decoration: const InputDecoration(labelText: "Paid By"),
                      value: selectedPayer,
                      items: _people.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                      onChanged: (p) => setDialogState(() => selectedPayer = p),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                ElevatedButton(
                  onPressed: () {
                    final double? amount = double.tryParse(amountStr);
                    if (amount != null && amount > 0 && description.isNotEmpty && selectedPayer != null) {
                      setState(() {
                        _expenses.add(GroupExpense(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          description: description,
                          amount: amount,
                          paidBy: selectedPayer!,
                          splitAmong: List.from(_people), // Splits equally by default
                        ));
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Split Bill'),
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppTheme.primaryPurple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.primaryPurple,
              tabs: [
                Tab(text: "Expenses"),
                Tab(text: "Settlements"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildExpensesTab(),
                  _buildSettlementsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_add, color: AppTheme.primaryPurple),
                  title: const Text("Add Person"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _addPerson();
                  }
                ),
                ListTile(
                  leading: const Icon(Icons.receipt_long, color: AppTheme.primaryPurple),
                  title: const Text("Add Expense"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _addExpense();
                  }
                ),
              ],
            ),
          );
        },
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (_people.isEmpty) {
      return const Center(child: Text("Add people and expenses to get started."));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          "Trip Members",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _people.map((p) => Chip(
            label: Text(p.name),
            backgroundColor: AppTheme.primaryOrange.withOpacity(0.2),
          )).toList(),
        ),
        const Divider(height: 30),
        Text(
          "Shared Expenses",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_expenses.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text("No expenses yet."))
        else
          ..._expenses.map((e) => Card(
            child: ListTile(
              title: Text(e.description, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Paid by ${e.paidBy.name}"),
              trailing: Text(
                Provider.of<CurrencyProvider>(context).formatPrice(e.amount),
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryPurple.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.receipt, color: AppTheme.primaryPurple),
              ),
            ),
          )),
      ],
    );
  }

  Widget _buildSettlementsTab() {
    if (_expenses.isEmpty) {
      return const Center(child: Text("Add expenses to see settlements."));
    }

    List<Settlement> settlements = _splitService.calculateSettlements(_people, _expenses);

    if (settlements.isEmpty) {
      return const Center(child: Text("All settled up! No one owes anything."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: settlements.length,
      itemBuilder: (context, index) {
        final s = settlements[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.fromPerson.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text("owes", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryOrange),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(s.toPerson.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        Provider.of<CurrencyProvider>(context).formatPrice(s.amount),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
