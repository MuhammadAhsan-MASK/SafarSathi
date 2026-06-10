import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/currency_provider.dart';

class CostSummaryScreen extends StatelessWidget {
  final double total;
  final double hotel;
  final double food;
  final double transport;
  final double attractions;

  const CostSummaryScreen({
    super.key,
    required this.total,
    required this.hotel,
    required this.food,
    required this.transport,
    required this.attractions,
  });

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Summary'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuccessIcon(context),
              const SizedBox(height: 30),
              const Center(
                child: Text(
                  'Trip Plan Saved!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Your trip has been successfully planned.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Expense Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildBreakdownItem(context, 'Accommodation', hotel, Icons.hotel_rounded, Colors.blue),
              _buildBreakdownItem(context, 'Dining & Food', food, Icons.restaurant_rounded, Colors.orange),
              _buildBreakdownItem(context, 'Transportation', transport, Icons.directions_bus_rounded, Colors.teal),
              _buildBreakdownItem(context, 'Tourist Attractions', attractions, Icons.location_on_rounded, Colors.purple),
              const Divider(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Estimate',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    currencyProvider.formatPrice(total),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('BACK TO HOME'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_circle_rounded,
          size: 80,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(BuildContext context, String label, double amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            Provider.of<CurrencyProvider>(context).formatPrice(amount),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
