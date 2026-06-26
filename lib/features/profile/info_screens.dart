import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String content;

  const InfoScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: Text(
            content,
            style: GoogleFonts.poppins(fontSize: 14, height: 1.6, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}

class StaticContent {
  static const String privacyPolicy = """
Privacy Policy for SastaSafar

Last updated: June 26, 2026

At SastaSafar, we prioritize your privacy. This policy explains how we collect, use, and protect your information.

1. Information Collection: We collect information you provide when creating an account, such as name, email, and profile details.
2. Location Data: SastaSafar uses location services to provide route recommendations and nearby service suggestions.
3. Data Sharing: We do not sell your personal data. Information is shared with service providers only as necessary for bookings.
4. Security: We implement industry-standard security measures to protect your account.
5. Your Rights: You can request data deletion or access your data at any time through our support channel.
""";

  static const String termsOfService = """
Terms of Service for SastaSafar

1. Acceptance: By using SastaSafar, you agree to these terms.
2. User Conduct: Users must provide accurate information and respect other community members.
3. Service Providers: Providers are responsible for the accuracy of their listings and quality of service.
4. Bookings: SastaSafar facilitates connections but is not responsible for provider-customer disputes.
5. Intellectual Property: All app content is the property of SastaSafar.
6. Termination: We reserve the right to suspend accounts that violate these terms.
""";

  static const String aboutContent = """
About SastaSafar

SastaSafar is your ultimate travel companion, designed to make traveling across Pakistan affordable, safe, and exciting.

Built with a vision to empower travelers and support local service providers, SastaSafar offers:
- Seamless booking for Hotels, Restaurants, and Transport.
- Intelligent route planning with safety and efficiency in mind.
- A platform for local vendors to showcase their services.

We believe that every journey should be memorable without breaking the bank. Welcome to SastaSafar – Your Journey, Our Passion.
""";

  static const String helpSupport = """
Help & Support

We are here to help you 24/7!

Frequently Asked Questions:
- How to book? Browse categories and select your preferred listing.
- How to become a provider? Switch mode in your profile.
- Payment issues? Contact our billing support below.

Contact Us:
Email: support@sastasafar.pk
Phone: +92-300-SASTA-00
Address: SastaSafar HQ, Tech Park, Karachi, Pakistan.
""";
}

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Personal Information', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
          ),
        ),
      ),
      body: Builder(
        builder: (context) => SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildInfoCard(context, 'Display Name', user?.displayName ?? 'Not Set', Icons.person_outline),
              _buildInfoCard(context, 'Email Address', user?.email ?? 'Not Available', Icons.email_outlined),
              _buildInfoCard(context, 'Account ID', user?.uid ?? 'Unknown', Icons.fingerprint),
              const SizedBox(height: 20),
              Text(
                'This information is synced with your secure account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(label),
            content: Text(value, style: GoogleFonts.poppins()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ],
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryPurple),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    value, 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
