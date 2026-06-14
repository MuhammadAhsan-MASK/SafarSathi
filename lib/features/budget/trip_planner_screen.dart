import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import 'budget_analysis_screen.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController(text: '50000');
  DateTime? _startDate;
  DateTime? _endDate;
  int _travelers = 1;

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
                  _buildInputField('Destination', Icons.location_on_outlined, 'e.g., Hunza, Skardu, Karachi', _destinationController),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker('Start Date', _startDate, (date) => setState(() => _startDate = date))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDatePicker('End Date', _endDate, (date) => setState(() => _endDate = date))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTravelersDropdown(),
                  const SizedBox(height: 20),
                  _buildInputField('Total Budget (PKR)', Icons.account_balance_wallet_outlined, 'e.g., 50000', _budgetController, isNumber: true),
                  const SizedBox(height: 30),
                  _buildBudgetBreakdownPreview(),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BudgetAnalysisScreen()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Continue to Budget Analysis'),
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

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Text(
        'Plan your Pakistan adventure',
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
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

  Widget _buildTravelersDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number of Travelers', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _travelers,
              isExpanded: true,
              items: [1, 2, 3, 4, 5].map((e) => DropdownMenuItem(value: e, child: Text('$e ${e == 1 ? 'Person' : 'People'}'))).toList(),
              onChanged: (val) => setState(() => _travelers = val!),
            ),
          ),
        ),
      ],
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
