import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/currency_provider.dart';
import 'services/transport_service.dart';
import 'models/transport_model.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TransportService _transportService = TransportService();
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.transportBg,
      appBar: AppBar(
        title: const Text('Transport'),
        backgroundColor: Colors.transparent,
        actions: [_buildCurrencySelector(context)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sourceController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Source',
                      prefixIcon: const Icon(Icons.location_searching),
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _destinationController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Destination',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<TransportOption>>(
        stream: _transportService.getTransportOptions(
          source: _sourceController.text,
          destination: _destinationController.text,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final options = snapshot.data ?? [];
          if (options.isEmpty) {
            return const Center(child: Text('No transport options found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              return _buildTransportCard(context, options[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildTransportCard(BuildContext context, TransportOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(option.icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.type,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      option.route,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                  Text(
                    option.time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Available Seats: Check Schedule'),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  textStyle: const TextStyle(fontSize: 14),
                ),
                child: const Text('SELECT'),
              ),
            ],
          ),
        ],
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
}
