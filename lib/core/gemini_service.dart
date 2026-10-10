import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cultural_calendar.dart';
import 'app_secrets.dart';

class GeminiService {
  // 🔑 Key is loaded from lib/core/app_secrets.dart (gitignored — never committed)
  static const String _apiKey = AppSecrets.geminiApiKey;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

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
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      await Future.delayed(const Duration(milliseconds: 800));
      return _mockResponse(history.last['text'] ?? '');
    }

    try {
      final contents = <Map<String, dynamic>>[];

      // Build conversation history for the API
      for (final msg in history) {
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [{'text': msg['text']}],
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [{'text': _systemPrompt}],
          },
          'contents': contents,
          'generationConfig': {
            'temperature': 0.8,
            'maxOutputTokens': 512,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else if (response.statusCode == 429) {
        // Fallback to mock responses if rate limited
        return _mockResponse(history.last['text'] ?? '');
      } else {
        return 'Sorry, I couldn\'t connect right now. Please try again. (Error ${response.statusCode})';
      }
    } catch (e) {
      return 'Network error. Please check your connection and try again.';
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
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}],
            }
          ],
          'generationConfig': {'temperature': 0.9, 'maxOutputTokens': 512},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
          final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
          final map = jsonDecode(clean) as Map<String, dynamic>;
          return map.map((k, v) => MapEntry(k, v.toString()));
        } else {
          print("API Error or rate limit: \$data");
        }
      } else {
         print("API HTTP Error: \${response.statusCode} - \${response.body}");
      }
    } catch (e) {
       print("SurpriseMe API parse error: \$e");
    }

    // Diverse Fallbacks if API fails
    final fallbacks = [
      {
        'destination': 'Hunza Valley',
        'tagline': 'Where heaven meets the mountains of Pakistan!',
        'why': 'Hunza is perfect for your $vibe adventure within PKR ${budget.toStringAsFixed(0)}. The stunning scenery and rich culture make it unmissable.',
        'highlight1': 'Eagle\'s Nest Viewpoint — Free (jeep hire ~PKR 3,000)',
        'highlight2': 'Attabad Lake boat ride — PKR 500/person',
        'highlight3': 'Baltit Fort — Entry PKR 500',
        'accommodation': 'Guesthouses PKR 1,500–3,000/night',
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
        'accommodation': 'Hotels PKR 2,000–5,000/night',
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
      }
    ];

    fallbacks.shuffle();
    return fallbacks.first;
  }

  /// AI-powered Smart Packing Assistant checklist generator
  static Future<List<Map<String, dynamic>>> generatePackingList({
    required String destination,
    required String vibe,
    required String duration,
    required String weatherConditions, // e.g. "Sunny", "Snow (Code 73)"
  }) async {
    final prompt = '''
You are a Smart Packing Assistant for Pakistan travel. A traveler is packing for a trip with these details:
- Destination: $destination
- Vibe: $vibe
- Duration: $duration
- Weather: $weatherConditions

CRITICAL INSTRUCTION: The packing items MUST strictly reflect the "$vibe" vibe.
- If "Business", include formal wear, laptop, blazer, etc.
- If "Adventure", include hiking boots, flashlight, rugged clothes, etc.
- If "Relaxation", include books, comfortable loungewear, swimsuit, etc.

Provide a highly customized and strictly categorized packing checklist. Reply ONLY in exact JSON format (an array of categories), no markdown blocks, no extra text:
[
  {
    "category": "Clothing",
    "items": [
      { "item": "Thermal wear", "reason": "Because of the snowy weather" },
      { "item": "Jeans", "reason": "Durable for the vibe" }
    ]
  },
  {
    "category": "Essentials & Gear",
    "items": []
  },
  {
    "category": "Toiletries",
    "items": []
  }
]
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
             {'role': 'user', 'parts': [{'text': prompt}]}
          ],
          'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 800},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        final clean = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> list = jsonDecode(clean);
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
    } catch (e) {
      print("generatePackingList API error: \$e");
    }

    // Dynamic Fallback if API fails
    final lowerVibe = vibe.toLowerCase();
    
    List<Map<String, dynamic>> clothingItems = [];
    if (lowerVibe.contains('business')) {
      clothingItems = [
        { "item": "Formal Suit/Blazer", "reason": "Crucial for business meetings in \$destination." },
        { "item": "Dress Shoes", "reason": "Professional attire." }
      ];
    } else if (lowerVibe.contains('adventure')) {
      clothingItems = [
        { "item": "Hiking Boots", "reason": "Essential for trails in \$destination." },
        { "item": "Thermal Jacket", "reason": "For outdoor cold weather." }
      ];
    } else if (lowerVibe.contains('relaxation')) {
      clothingItems = [
        { "item": "Comfortable Loungewear", "reason": "For relaxing at the hotel." },
        { "item": "Swimsuit/Trunks", "reason": "If your hotel has a pool." }
      ];
    } else {
      clothingItems = [
        { "item": "Warm Jacket", "reason": "Always good to have for evening chills in \$destination." },
        { "item": "Comfortable Walking Shoes", "reason": "Essential for your \$vibe trip." }
      ];
    }

    List<Map<String, dynamic>> techItems = [
      { "item": "Power Bank", "reason": "Crucial for remote areas." },
      { "item": "Universal Adapter", "reason": "Just in case." }
    ];
    if (lowerVibe.contains('business')) {
      techItems.add({ "item": "Laptop & Charger", "reason": "For work on the go." });
    } else if (lowerVibe.contains('adventure')) {
      techItems.add({ "item": "Headlamp", "reason": "For night camping or caves." });
    }

    return [
      { "category": "Clothing", "items": clothingItems },
      { "category": "Tech & Gear", "items": techItems },
      {
        "category": "Health & Emergency",
        "items": [
          { "item": "Basic First Aid Kit", "reason": "Includes bandages, panadol, mask." },
          { "item": "Sunscreen & Chapstick", "reason": "Protects against harsh conditions." }
        ]
      }
    ];
  }

  /// Mock responses for demo when no API key is set
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
          '• **Travel:** Flight from ISB (~PKR 8,000–15,000) or 20hr drive\n\n'
          'Would you like a detailed trip plan for Skardu?';
    }
    if (q.contains('budget') || q.contains('cheap') || q.contains('affordable') || q.contains('pkr')) {
      return '💰 **Budget Travel Tips for Pakistan:**\n\n'
          '• Travel by Daewoo/YUTONG buses — very affordable\n'
          '• Stay at guesthouses: PKR 800–2,000/night\n'
          '• Eat local: Daal chawal, biryani under PKR 300\n'
          '• Visit in shoulder season for cheaper hotels\n'
          '• Book through SastaSafar\'s Trip Planner for best deals!\n\n'
          'What\'s your total budget? I can plan accordingly!';
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
          '• **Punjab (Lahore, Multan):** Oct–March (avoid summer heat)\n'
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
          '• **Chapli Kabab** — KPK delicacy (~PKR 50 each)\n\n'
          'Use SastaSafar\'s Restaurants tab to find top-rated spots near you!';
    }

    return '🇵🇰 Great question! I\'m SafarBot, your Pakistan travel guide.\n\n'
        'I can help you plan trips to amazing places like **Hunza, Skardu, Lahore, Swat, Neelum Valley** and more!\n\n'
        'Try asking me:\n'
        '• "Best places to visit in Pakistan"\n'
        '• "Budget trip to Hunza for 2 people"\n'
        '• "What should I eat in Lahore?"\n\n'
        '_Note: The AI API is currently rate-limited (too many requests), so I am using offline fallback responses._';
  }
}
