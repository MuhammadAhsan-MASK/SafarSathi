import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/currency_provider.dart';
import 'cost_summary_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  double _hotelPrice = 5000;
  int _nights = 3;
  double _mealPrice = 800;
  int _mealsPerDay = 3;
  double _transportFare = 2000;
  double _attractionFees = 500;
  double _budgetLimit = 50000;

  double get _totalCost =>
      (_hotelPrice * _nights) +
      (_mealPrice * _mealsPerDay * _nights) +
      _transportFare +
      _attractionFees;

  bool get _isOverBudget => _totalCost > _budgetLimit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Planner'),
        actions: [
          _buildCurrencySelector(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBudgetOverview(context),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trip Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildServiceSection(
                    context,
                    'Stay',
                    'Hotel Accommodation',
                    '${Provider.of<CurrencyProvider>(context).formatPrice(_hotelPrice)} / night',
                    Icons.hotel_rounded,
                    onEdit: () => _editPrice('Hotel Price', _hotelPrice, (val) => setState(() => _hotelPrice = val)),
                  ),
                  _buildCounterRow(
                    'Number of Nights',
                    _nights,
                    (val) => setState(() => _nights = val),
                  ),
                  const Divider(height: 40),
                  _buildServiceSection(
                    context,
                    'Dining',
                    'Daily Meals',
                    '${Provider.of<CurrencyProvider>(context).formatPrice(_mealPrice)} / meal',
                    Icons.restaurant_rounded,
                    onEdit: () => _editPrice('Meal Price', _mealPrice, (val) => setState(() => _mealPrice = val)),
                  ),
                  _buildCounterRow(
                    'Meals per Day',
                    _mealsPerDay,
                    (val) => setState(() => _mealsPerDay = val),
                  ),
                  const Divider(height: 40),
                  _buildServiceSection(
                    context,
                    'Transportation',
                    'Travel Budget',
                    '${Provider.of<CurrencyProvider>(context).formatPrice(_transportFare)} (Full Trip)',
                    Icons.directions_bus_rounded,
                    onEdit: () => _editPrice('Transport Fare', _transportFare, (val) => setState(() => _transportFare = val)),
                  ),
                  const Divider(height: 40),
                  _buildServiceSection(
                    context,
                    'Attractions',
                    'Entry Fees & Misc',
                    '${Provider.of<CurrencyProvider>(context).formatPrice(_attractionFees)} total fees',
                    Icons.location_on_rounded,
                    onEdit: () => _editPrice('Attraction Fees', _attractionFees, (val) => setState(() => _attractionFees = val)),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CostSummaryScreen(
                              total: _totalCost,
                              hotel: _hotelPrice * _nights,
                              food: _mealPrice * _mealsPerDay * _nights,
                              transport: _transportFare,
                              attractions: _attractionFees,
                            ),
                          ),
                        );
                      },
                      child: const Text('SAVE TRIP PLAN'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetOverview(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _isOverBudget ? Colors.red[50] : Theme.of(context).primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: _isOverBudget ? Colors.red.withOpacity(0.2) : Theme.of(context).primaryColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Estimated Total',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              currencyProvider.formatPrice(_totalCost),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _isOverBudget ? Colors.red : Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: _isOverBudget ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isOverBudget ? 'Over Budget by ${currencyProvider.formatPrice(_totalCost - _budgetLimit)}' : 'Within Budget',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currencyProvider.selectedCurrency,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.currency_exchange, size: 20, color: Colors.black54),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          items: currencyProvider.currencies.map((String cur) {
            return DropdownMenuItem<String>(
              value: cur,
              child: Text(cur),
            );
          }).toList(),
          onChanged: (String? newVal) {
            if (newVal != null) {
              currencyProvider.setCurrency(newVal);
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceSection(BuildContext context, String title, String name, String price, IconData icon, {required VoidCallback onEdit}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.grey[700]),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                price,
                style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 20),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildCounterRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 52),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Row(
            children: [
              IconButton(
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$value',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editPrice(String title, double currentValue, Function(double) onSaved) {
    final controller = TextEditingController(text: currentValue.toInt().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Amount (Rs.)',
            prefixText: 'Rs. ',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                onSaved(val);
                Navigator.pop(context);
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
