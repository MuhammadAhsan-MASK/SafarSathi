import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an external web URL safely, adding `https://` if no scheme is present.
Future<void> launchExternalUrl(BuildContext context, String rawUrl) async {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No website link available')),
      );
    }
    return;
  }

  final normalized = (trimmed.startsWith('http://') ||
          trimmed.startsWith('https://') ||
          trimmed.contains('://'))
      ? trimmed
      : 'https://$trimmed';

  try {
    final uri = Uri.parse(normalized);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $trimmed')),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $trimmed')),
      );
    }
  }
}
