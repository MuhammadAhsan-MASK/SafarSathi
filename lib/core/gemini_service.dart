import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cultural_calendar.dart';
import 'app_secrets.dart';

class GeminiService {
  // 🔑 Key is loaded from lib/core/app_secrets.dart (gitignored — never committed)
  static const String _apiKey = AppSecrets.geminiApiKey;

  static const List<String> _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
  ];

  static Future<http.Response> _postGenerateContent(
      Map<String, dynamic> body) async {
    http.Response? lastResponse;
    for (final model in _models) {
      final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey');
      try {
        final res = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body),
            )
            .timeout(const Duration(seconds: 10));
        if (res.statusCode == 200) {
          return res;
        }
        lastResponse = res;
        // Try next available model on 404/429/503
        if (res.statusCode == 503 || res.statusCode == 404 || res.statusCode == 429) {
          continue;
        }
        return res;
      } catch (e) {
        debugPrint('Gemini model $model request error: $e');
      }
    }
    return lastResponse ?? http.Response('{"error": "Unavailable"}', 503);
  }

  static String? _extractResponseText(http.Response response) {
    if (response.statusCode != 200) return null;
    try {
      final data = jsonDecode(response.body);
      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) return null;
      final content = candidates[0]['content'];
      if (content is! Map) return null;
      final parts = content['parts'];
      if (parts is! List || parts.isEmpty) return null;
      final text = parts[0]['text'];
      return text is String && text.trim().isNotEmpty ? text : null;
    } catch (e) {
      debugPrint('Gemini parse error: $e');
      return null;
    }
  }

  static const String _systemPrompt = '''
You are SafarBot, a friendly and knowledgeable AI travel assistant for SastaSafar — a Pakistan travel app.

Your expertise:
- Tourist destinations across Pakistan (Hunza, Skardu, Lahore, Karachi, Murree, Fairy Meadows, Neelum Valley, Swat, etc.)
- Budget travel tips in PKR (Pakistani Rupees)
- Local food recommendations
- Transport options (buses, flights, jeeps, wagons)
- Weather and best travel seasons
- Cultural tips and safety advice
- Hotel and accommodation suggestions
- Itinerary planning for different budgets

Keep your responses:
- Concise and conversational
- Helpful with specific PKR cost estimates when asked about budget
- Warm and encouraging about exploring Pakistan's beauty
- Formatted with bullet points when listing multiple items

If asked something outside travel/Pakistan, politely redirect to travel topics.
''';

  static Future<String> sendMessage(List<Map<String, String>> history) async {
    final lastUserText = history.isNotEmpty ? (history.last['text'] ?? '') : '';

    if (_apiKey == 'YOUR_GEMINI_API_KEY' || _apiKey.trim().isEmpty) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockResponse(lastUserText);
    }

    try {
      final contents = <Map<String, dynamic>>[];

      for (final msg in history) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [{'text': msg['text'] ?? ''}],
        });
      }

      final response = await _postGenerateContent({
        'system_instruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.8,
          'maxOutputTokens': 512,
        },
      });

      final text = _extractResponseText(response);
      if (text != null) {
        return text;
      }
      // Graceful offline / rate-limit fallback instead of exposing raw error codes
      return _mockResponse(lastUserText);
    } catch (e) {
      debugPrint('SafarBot offline fallback: $e');
      return _mockResponse(lastUserText);
    }
  }

  /// AI-powered trip suggestion based on budget, vibe, and duration
  static Future<Map<String, String>> surpriseMe({
    required double budget,
    required String vibe,
    required String duration,
  }) async {
    final currentEvents = CulturalCalendar.getCurrentMonthEvents();
    final prompt = '''
You are a Pakistan travel expert. A traveler has the following preferences:
- Total budget: PKR ${budget.toStringAsFixed(0)}
- Trip vibe: $vibe
- Duration: $duration
- Current Month Events/Festivals: $currentEvents

CRITICAL: Pick a UNIQUE, DIVERSE, and highly unexpected Pakistan destination. DO NOT always pick Hunza or Skardu. Explore hidden gems like Kumrat, Taobat, Gorakh Hills, Makran Coast, Khuzdar, Cholistan, or lesser-known valleys. Be unpredictable!
If the "Current Month Events" are relevant to the traveler's vibe (e.g. Polo, blossom, snow festival), heavily prioritize suggesting a trip built around that event.

Suggest ONE perfect Pakistan destination for them. Reply ONLY in this exact JSON format, no markdown, no extra text:
{
  "destination": "Destination Name",
  "tagline": "A short exciting one-liner about this destination",
  "why": "2-sentence reason why this destination matches their vibe and budget",
  "highlight1": "Must-do activity 1 with PKR cost",
  "highlight2": "Must-do activity 2 with PKR cost",
  "highlight3": "Must-do activity 3 with PKR cost",
  "accommodation": "Recommended stay type and price range in PKR",
  "bestTime": "Best months to visit",
  "tip": "One unique local tip for this destination"
}
''';

    try {
      final response = await _postGenerateContent({
        'contents': [
          {
            'role': 'user',
            'parts': [{'text': prompt}],
          }
        ],
        'generationConfig': {'temperature': 0.9, 'maxOutputTokens': 512},
      });

      final text = _extractResponseText(response);
      if (text != null) {
        final startIndex = text.indexOf('{');
        final endIndex = text.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          final jsonStr = text.substring(startIndex, endIndex + 1);
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          return map.map((k, v) => MapEntry(k, v.toString()));
        }
      }
    } catch (e) {
      debugPrint('SurpriseMe API parse error: $e');
    }

    // Diverse Fallbacks if API fails or is offline
    final fallbacks = [
      {
        'destination': 'Hunza Valley',
        'tagline': 'Where heaven meets the mountains of Pakistan!',
        'why': 'Hunza is perfect for your $vibe adventure within PKR ${budget.toStringAsFixed(0)}. The stunning scenery and rich culture make it unmissable.',
        'highlight1': 'Eagle\'s Nest Viewpoint — Free (jeep hire ~PKR 3,000)',
        'highlight2': 'Attabad Lake boat ride — PKR 500/person',
        'highlight3': 'Baltit Fort — Entry PKR 500',
        'accommodation': 'Guesthouses PKR 2,500–5,500/night',
        'bestTime': 'May – October',
        'tip': 'Try the local dried apricots and cherry juice — a Hunza specialty!',
      },
      {
        'destination': 'Swat Valley',
        'tagline': 'The Switzerland of the East!',
        'why': 'Swat offers incredible $vibe experiences that fit your PKR ${budget.toStringAsFixed(0)} budget perfectly. Lush green meadows and rivers await.',
        'highlight1': 'Malam Jabba Ski Resort — Entry PKR 1,000',
        'highlight2': 'Kalam Valley exploring — Jeep PKR 4,000',
        'highlight3': 'Mahodand Lake — Boat ride PKR 1,000',
        'accommodation': 'Hotels PKR 2,500–6,000/night',
        'bestTime': 'April – September',
        'tip': 'Bargain for local Swati shawls at the Mingora bazaar!',
      },
      {
        'destination': 'Neelum Valley',
        'tagline': 'A paradise on Earth in Kashmir!',
        'why': 'Neelum Valley matches your $vibe needs and PKR ${budget.toStringAsFixed(0)} limit. The blue waters and thick forests are magical.',
        'highlight1': 'Arang Kel hike — Cable car PKR 500',
        'highlight2': 'Dhani Waterfall — Free to visit',
        'highlight3': 'Kutton Jagran Resort — Relaxing views',
        'accommodation': 'Wooden Cabins PKR 3,000–6,000/night',
        'bestTime': 'May – October',
        'tip': 'Carry original CNIC as there are many security checkpoints.',
      },
    ];

    fallbacks.shuffle();
    return fallbacks.first;
  }

  /// AI-powered Smart Packing Assistant checklist generator.
  /// Throws on failure/offline so [SmartPackingScreen] applies its climate-matched local database.
  static Future<List<Map<String, dynamic>>> generatePackingList({
    required String destination,
    required String vibe,
    required String duration,
    required String weatherConditions,
  }) async {
    final prompt = '''
You are a Smart Packing Assistant for Pakistan travel. A traveler is packing for a trip with these details:
- Destination: $destination
- Vibe: $vibe
- Duration: $duration
- Weather: $weatherConditions

CRITICAL INSTRUCTION: The packing items MUST strictly reflect BOTH the weather conditions ("$weatherConditions") and destination ("$destination") as well as the "$vibe" vibe.
Do NOT include cold/mountain/hiking items for warm/coastal cities like Karachi, Gwadar, Lahore, or Multan.

Reply ONLY in exact JSON format (an array of categories), no markdown blocks, no extra text:
[
  {
    "category": "Clothing",
    "items": [
      { "item": "Example Item", "reason": "Clear reason for $destination" }
    ]
  }
]
''';

    final response = await _postGenerateContent({
      'contents': [
        {
          'role': 'user',
          'parts': [{'text': prompt}],
        }
      ],
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 900},
    });

    final text = _extractResponseText(response);
    if (text == null) {
      throw Exception('AI packing response unavailable (status ${response.statusCode})');
    }

    final startIndex = text.indexOf('[');
    final endIndex = text.lastIndexOf(']');
    if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
      throw Exception('Invalid AI packing JSON payload');
    }

    final jsonStr = text.substring(startIndex, endIndex + 1);
    final List<dynamic> decoded = jsonDecode(jsonStr);
    final List<Map<String, dynamic>> normalized = [];

    for (final rawCat in decoded) {
      if (rawCat is! Map) continue;
      final catName = (rawCat['category'] ?? 'Essentials').toString();
      final rawItems = rawCat['items'];
      final List<Map<String, dynamic>> itemsList = [];
      if (rawItems is List) {
        for (final it in rawItems) {
          if (it is Map && (it['item'] ?? '').toString().trim().isNotEmpty) {
            itemsList.add({
              'item': it['item'].toString().trim(),
              'reason': (it['reason'] ?? 'Recommended for $destination').toString().trim(),
              'checked': false,
            });
          }
        }
      }
      if (itemsList.isNotEmpty) {
        normalized.add({
          'category': catName,
          'items': itemsList,
        });
      }
    }

    if (normalized.isEmpty) {
      throw Exception('Empty AI packing categories');
    }
    return normalized;
  }

  /// Offline fallback responses for SafarBot when network/quota is unavailable
  static String _mockResponse(String input) {
    final q = input.toLowerCase();

    if (q.contains('hunza') || q.contains('gilgit')) {
      return '🏔️ **Hunza Valley** is one of Pakistan\'s most stunning destinations!\n\n'
          '• **Best time:** May–October\n'
          '• **Budget:** PKR 15,000–30,000 per person (3–4 days)\n'
          '• **Must-see:** Eagle\'s Nest, Attabad Lake, Baltit Fort\n'
          '• **Travel:** NATCO bus from Rawalpindi (~PKR 2,000)\n\n'
          'Want me to plan a complete itinerary for Hunza?';
    }
    if (q.contains('skardu') || q.contains('k2') || q.contains('baltoro')) {
      return '🏔️ **Skardu** is the gateway to K2 and the Karakoram!\n\n'
          '• **Best time:** June–September\n'
          '• **Budget:** PKR 20,000–40,000 per person (5 days)\n'
          '• **Must-see:** Shangrila Resort, Satpara Lake, Deosai Plains\n'
          '• **Travel:** Flight from ISB (~PKR 15,000–25,000) or 20hr drive\n\n'
          'Would you like a detailed trip plan for Skardu?';
    }
    if (q.contains('budget') || q.contains('cheap') || q.contains('affordable') || q.contains('pkr')) {
      return '💰 **Budget Travel Tips for Pakistan:**\n\n'
          '• Travel by Daewoo/Faisal Movers buses — very affordable\n'
          '• Stay at local guesthouses: PKR 2,000–4,500/night\n'
          '• Eat local: Daal chawal, biryani under PKR 400\n'
          '• Visit in shoulder season for cheaper hotels\n'
          '• Use SastaSafar\'s Trip Planner for exact route & stay matching!\n\n'
          'What\'s your total budget? I can help plan accordingly!';
    }
    if (q.contains('lahore')) {
      return '🕌 **Lahore** — The heart of Pakistan!\n\n'
          '• **Best for:** History, food, and culture\n'
          '• **Must-see:** Badshahi Mosque, Lahore Fort, Food Street\n'
          '• **Budget:** PKR 5,000–10,000/day (hotels + food + transport)\n'
          '• **Try:** Nihari, Halwa Puri, Lahori Chargha!\n\n'
          'Lahore is perfect for a weekend trip. Want an itinerary?';
    }
    if (q.contains('weather') || q.contains('season') || q.contains('when')) {
      return '☀️ **Best seasons to visit Pakistan:**\n\n'
          '• **North (Hunza, Skardu):** May–October\n'
          '• **Punjab (Lahore, Multan):** Oct–March (avoid summer peak heat)\n'
          '• **Sindh (Karachi):** Nov–March\n'
          '• **Azad Kashmir (Neelum, Murree):** Apr–Jun, Sep–Oct\n\n'
          'Where are you planning to go?';
    }
    if (q.contains('hello') || q.contains('hi') || q.contains('salam') || q.contains('hey')) {
      return '👋 **Assalam o Alaikum! I\'m SafarBot!**\n\n'
          'Your personal Pakistan travel assistant 🇵🇰\n\n'
          'I can help you with:\n'
          '• 🗺️ Destination recommendations\n'
          '• 💰 Budget planning in PKR\n'
          '• 🍜 Food & restaurant tips\n'
          '• 🚌 Transport options\n'
          '• 📅 Itinerary planning\n\n'
          'Where would you like to explore first?';
    }
    if (q.contains('food') || q.contains('eat') || q.contains('restaurant')) {
      return '🍽️ **Pakistan\'s must-try foods:**\n\n'
          '• **Karahi** — best in Peshawar & Lahore (~PKR 800–1,500)\n'
          '• **Biryani** — Karachi-style is legendary (~PKR 300–600)\n'
          '• **Sajji** — Balochistan specialty (~PKR 1,000)\n'
          '• **Nihari** — Lahore breakfast classic (~PKR 400)\n'
          '• **Chapli Kabab** — KPK delicacy (~PKR 150 each)\n\n'
          'Use SastaSafar\'s Dining section to find top-rated spots near you!';
    }

    return '🇵🇰 I\'m SafarBot, your Pakistan travel assistant!\n\n'
        'I can help you explore places like **Hunza, Skardu, Lahore, Swat, Murree, and Neelum Valley**.\n\n'
        'Try asking me:\n'
        '• "Best places to visit in Pakistan"\n'
        '• "Budget trip to Hunza"\n'
        '• "What should I eat in Lahore?"\n'
        '• "Best travel season"';
  }
}
