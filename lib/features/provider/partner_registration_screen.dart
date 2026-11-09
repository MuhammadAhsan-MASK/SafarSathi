import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../auth/user_role_service.dart';
import '../home/main_screen.dart';

class PartnerRegistrationScreen extends StatefulWidget {
  const PartnerRegistrationScreen({super.key});

  @override
  State<PartnerRegistrationScreen> createState() => _PartnerRegistrationScreenState();
}

class _PartnerRegistrationScreenState extends State<PartnerRegistrationScreen> {
  final UserRoleService _roleService = UserRoleService();

  String _selectedRole = 'Hotel Owner';
  final TextEditingController _businessNameCtrl = TextEditingController(text: 'Pine View Mountain Resort');
  final TextEditingController _phoneCtrl = TextEditingController(text: '0300-1234567');
  final TextEditingController _descriptionCtrl = TextEditingController(text: 'Premium mountain hospitality with panoramic valley views, free Wi-Fi, and 24/7 service.');
  String _selectedCity = 'Murree';
  bool _isLoading = false;

  final List<String> _pakistanCities = [
    'Murree',
    'Hunza',
    'Skardu',
    'Swat',
    'Islamabad',
    'Rawalpindi',
    'Naran',
    'Gilgit',
    'Lahore',
    'Karachi',
    'Peshawar',
    'Chitral',
    'Gwadar',
    'Neelum Valley',
    'Multan',
    'Quetta',
  ];

  final List<Map<String, dynamic>> _partnerTypes = [
    {
      'role': 'Hotel Owner',
      'title': 'Hotel & Resort Owner',
      'subtitle': 'Hotels, guest houses, chalets & glamping pods',
      'icon': Icons.hotel_rounded,
      'color': const Color(0xFF6A1B9A),
      'defaultName': 'Pine View Mountain Resort',
    },
    {
      'role': 'Restaurant Owner',
      'title': 'Restaurant & Café Owner',
      'subtitle': 'Local cuisine, desi karahi, cafes & buffets',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFEA580C),
      'defaultName': 'Mall Road Karahi & Chai Point',
    },
    {
      'role': 'Transport Provider',
      'title': 'Transport Fleet Provider',
      'subtitle': 'Hiaces, coasters, 4x4 mountain jeeps & rentals',
      'icon': Icons.directions_bus_rounded,
      'color': const Color(0xFF0284C7),
      'defaultName': 'Northern Express 4x4 Fleet',
    },
    {
      'role': 'Service Provider',
      'title': 'Tour Guide & Trekking Operator',
      'subtitle': 'Mountain drivers, certified guides & valley safaris',
      'icon': Icons.explore_rounded,
      'color': const Color(0xFF059669),
      'defaultName': 'Karakoram Mountain Guides',
    },
  ];

  Future<void> _submitRegistration() async {
    final businessName = _businessNameCtrl.text.trim();
    if (businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Business / Property name.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _roleService.updateUserRole(
        _selectedRole,
        additionalData: {
          'businessName': businessName,
          'city': _selectedCity,
          'phone': _phoneCtrl.text.trim(),
          'description': _descriptionCtrl.text.trim(),
          'registeredAsPartner': true,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('🎉 Welcome! Switched to $_selectedRole Dashboard.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Cleanly replace navigation stack with MainScreen which mounts ProviderDashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text('Partner with SastaSafar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryPurple),
                  SizedBox(height: 16),
                  Text('Setting up your business portal...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF334155)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'VERIFIED PARTNER NETWORK',
                              style: GoogleFonts.poppins(
                                color: Colors.amberAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Grow Your Hospitality & Travel Business',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'List your hotel, restaurant, transport fleet, or guide services and connect with tourists across Pakistan.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Step 1: Select Partner Category
                  Text(
                    '1. Choose Your Business Category',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),

                  ..._partnerTypes.map((type) {
                    final isSelected = _selectedRole == type['role'];
                    final color = type['color'] as Color;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedRole = type['role'] as String;
                            if (_businessNameCtrl.text.isEmpty ||
                                _partnerTypes.any((p) => p['defaultName'] == _businessNameCtrl.text)) {
                              _businessNameCtrl.text = type['defaultName'] as String;
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : const Color(0xFFE2E8F0),
                              width: isSelected ? 2.2 : 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? color.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(type['icon'] as IconData, color: color, size: 24),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type['title'] as String,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSelected ? color : const Color(0xFF1E293B),
                                      ),
                                    ),
                                    Text(
                                      type['subtitle'] as String,
                                      style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Radio<String>(
                                value: type['role'] as String,
                                groupValue: _selectedRole,
                                activeColor: color,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedRole = val;
                                      _businessNameCtrl.text = type['defaultName'] as String;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Step 2: Business Profile Information
                  Text(
                    '2. Business Profile Information',
                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _businessNameCtrl,
                          decoration: InputDecoration(
                            labelText: 'Business / Property Name',
                            hintText: 'e.g. Pine Top Resort Murree',
                            prefixIcon: const Icon(Icons.storefront_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCity,
                                decoration: InputDecoration(
                                  labelText: 'Operating Hub',
                                  prefixIcon: const Icon(Icons.location_city_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                items: _pakistanCities.map((city) {
                                  return DropdownMenuItem(value: city, child: Text(city));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCity = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  labelText: 'Contact / WhatsApp',
                                  hintText: '0300-1234567',
                                  prefixIcon: const Icon(Icons.phone_rounded),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _descriptionCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Short Description / Amenities',
                            hintText: 'Describe services, facilities, or tour routes...',
                            prefixIcon: const Icon(Icons.notes_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Partner Perks / Benefits Row
                  Row(
                    children: [
                      _buildPerkChip(Icons.credit_card_off_rounded, '0% Listing Fee'),
                      const SizedBox(width: 8),
                      _buildPerkChip(Icons.call_rounded, 'Direct Calls'),
                      const SizedBox(width: 8),
                      _buildPerkChip(Icons.bar_chart_rounded, 'Live Analytics'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitRegistration,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.rocket_launch_rounded, size: 20, color: Colors.amberAccent),
                          const SizedBox(width: 10),
                          Text(
                            'Register & Open Provider Portal',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Switch Link
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        setState(() => _isLoading = true);
                        try {
                          await _roleService.updateUserRole('Service Provider');
                          nav.pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainScreen()),
                            (route) => false,
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      icon: const Icon(Icons.bolt_rounded, size: 18, color: AppTheme.primaryPurple),
                      label: Text(
                        'Instant Switch to Provider Mode (No Form)',
                        style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.primaryPurple),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildPerkChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF059669)),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
            ),
          ],
        ),
      ),
    );
  }
}
