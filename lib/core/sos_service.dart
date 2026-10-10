import 'package:url_launcher/url_launcher.dart';

class SOSService {
  /// Triggers an SMS to emergency contacts / local authorities with a predefined message and location.
  /// Uses a mocked location for the prototype.
  static Future<void> triggerSOS() async {
    // Tourist police or general emergency number
    const String emergencyNumber = "1122"; 
    
    // Mocked GPS Coordinates for demonstration
    const double lat = 35.3214;
    const double lng = 74.3412;
    
    final String message = 
        "SOS! I am a tourist in need of immediate assistance. "
        "My last known location is: https://maps.google.com/?q=$lat,$lng";

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: emergencyNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      // Fallback or error handling
      throw 'Could not launch SMS application.';
    }
  }
}
