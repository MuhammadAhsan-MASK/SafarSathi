import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'cultural_calendar.dart';
import 'app_secrets.dart';

class GeminiService {
  // 🔑 Key is loaded from lib/core/app_secrets.dart (gitignored — never committed)
  static const String _apiKey = AppSecrets.geminiApiKey;

  static const List<String> _models = [
    'gemini-3.5-flash-lite',
    'gemini-flash-lite-latest',
    'gemini-3.1-flash-lite',
    'gemini-3-flash-preview',
    'gemini-3.8-flash',
    'gemini-3.5-flash',
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
        debugPrint('Gemini model $model returned ${res.statusCode}');
        // Try next available candidate model on any non-200 code
        continue;
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
      // Keep up to the last 8 conversation turns to maintain context without hitting token limits
      final recentHistory =
          history.length > 8 ? history.sublist(history.length - 8) : history;

      final contents = <Map<String, dynamic>>[];

      for (final msg in recentHistory) {
        final text = (msg['text'] ?? '').trim();
        if (text.isEmpty) continue;
        contents.add({
          'role': msg['role'] == 'user' ? 'user' : 'model',
          'parts': [{'text': text}],
        });
      }

      // Gemini contents array must start with role 'user'
      while (contents.isNotEmpty && contents.first['role'] != 'user') {
        contents.removeAt(0);
      }

      if (contents.isEmpty) {
        contents.add({
          'role': 'user',
          'parts': [{'text': lastUserText.isNotEmpty ? lastUserText : 'Hello'}],
        });
      }

      final response = await _postGenerateContent({
        'system_instruction': {
          'parts': [{'text': _systemPrompt}],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 650,
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
        'generationConfig': {
          'temperature': 0.85,
          'maxOutputTokens': 850,
          'responseMimeType': 'application/json',
        },
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

    // Diverse, highly curated regional fallbacks if API is offline or quota exceeded
    final fallbacks = [
      {
        'destination': 'Gorakh Hill Station',
        'tagline': 'The Murree of Sindh with freezing night breezes!',
        'why': 'Gorakh Hills offers a completely unexpected alpine escape in Dadu, Sindh. Perfect for a $vibe getaway within PKR ${budget.toStringAsFixed(0)}.',
        'highlight1': '4x4 Jeep safari from Wahi Pandi — PKR 4,000–6,000 shared',
        'highlight2': 'Sunset view from Benazir Viewpoint — Free',
        'highlight3': 'Night bonfire & stargazing under zero light pollution — Free',
        'accommodation': 'Sindh Tourism (STDC) Rest House or camping tents (PKR 2,500–5,000/night)',
        'bestTime': 'October – March',
        'tip': 'Bring warm jackets even in summer; night temperatures can drop below 10°C.',
      },
      {
        'destination': 'Kumrat Valley',
        'tagline': 'Untouched deodar pine forests and roaring turquoise waters!',
        'why': 'Kumrat is ideal for an authentic $vibe retreat within PKR ${budget.toStringAsFixed(0)}. Its dense canopy and waterfalls feel like a fairytale.',
        'highlight1': 'Katora Lake high-altitude trek — Jeep to Jandrai (~PKR 3,500)',
        'highlight2': 'Kumrat Riverbank camping & trout fishing — PKR 1,500',
        'highlight3': 'Do Kala Chashma waterfall hike — Free',
        'accommodation': 'Riverside wooden pods & luxury camping tents (PKR 3,000–6,500/night)',
        'bestTime': 'May – September',
        'tip': 'Rent a 4x4 from Thal bazaar; standard cars cannot clear the forest trails.',
      },
      {
        'destination': 'Makran Coastal Highway & Ormara',
        'tagline': 'Where golden desert dunes collide with the Arabian Sea!',
        'why': 'A breathtaking coastal road trip that fits your $vibe preference and PKR ${budget.toStringAsFixed(0)} budget with scenic freedom.',
        'highlight1': 'Princess of Hope & Sphinx natural rock formations in Hingol — Free',
        'highlight2': 'Bioluminescent night tides at Ormara Beach — Free',
        'highlight3': 'Fresh fish bbq caught straight from the sea — PKR 800–1,500',
        'accommodation': 'Ormara Beach resorts or coastal cottages (PKR 3,500–7,000/night)',
        'bestTime': 'November – February',
        'tip': 'Fuel up completely in Hub or Zero Point; gas stations are sparse on the highway.',
      },
      {
        'destination': 'Hunza Valley',
        'tagline': 'Where heaven meets the majestic Karakoram peaks!',
        'why': 'Hunza is perfect for your $vibe adventure within PKR ${budget.toStringAsFixed(0)}. Stunning mountain vistas and hospitable culture await.',
        'highlight1': 'Eagle\'s Nest Viewpoint over Rakaposhi — Free (jeep ~PKR 2,500)',
        'highlight2': 'Attabad Lake jet ski & motorboat ride — PKR 1,000/person',
        'highlight3': 'Baltit & Altit Heritage Forts entry — PKR 600',
        'accommodation': 'Karimabad guesthouses (PKR 3,000–6,500/night)',
        'bestTime': 'April – October',
        'tip': 'Try local walnut cakes at Cafe de Hunza and fresh dried apricots.',
      },
      {
        'destination': 'Skardu & Deosai Plains',
        'tagline': 'Gateway to K2 and the mystical Land of Giants!',
        'why': 'Skardu matches your $vibe journey with alpine lakes and desert dunes within PKR ${budget.toStringAsFixed(0)}.',
        'highlight1': 'Deosai National Park & Sheosar Lake safari — Shared jeep PKR 4,000',
        'highlight2': 'Katpana Desert cold-desert quad biking — PKR 1,500',
        'highlight3': 'Upper Kachura Lake boat ride — PKR 500',
        'accommodation': 'Traditional riverside lodges (PKR 3,500–7,500/night)',
        'bestTime': 'June – September',
        'tip': 'Carry plenty of battery banks; northern cold drains phone batteries quickly.',
      },
      {
        'destination': 'Neelum Valley & Arang Kel',
        'tagline': 'The emerald jewel of Azad Kashmir!',
        'why': 'Neelum Valley fits your $vibe aspirations within PKR ${budget.toStringAsFixed(0)}. Lush green terraced fields and crystal rivers surround you.',
        'highlight1': 'Arang Kel cable car & panoramic mountain hike — PKR 500',
        'highlight2': 'Dhani & Kutton waterfalls — Free to explore',
        'highlight3': 'Keran riverside walk with view of the Line of Control — Free',
        'accommodation': 'Wooden riverside cabins (PKR 2,500–6,000/night)',
        'bestTime': 'May – October',
        'tip': 'Carry your original CNIC / passport as security checkpoints are mandatory.',
      },
      {
        'destination': 'Swat Valley & Malam Jabba',
        'tagline': 'The Switzerland of the East with rich Gandhara history!',
        'why': 'Swat offers incredible $vibe experiences that fit your PKR ${budget.toStringAsFixed(0)} budget with great motorways and lush valleys.',
        'highlight1': 'Malam Jabba zipline & chairlift — PKR 1,200',
        'highlight2': 'Mahodand Lake off-road jeep excursion — Shared jeep PKR 3,000',
        'highlight3': 'Ushu pine forest picnic — Free',
        'accommodation': 'Hotels in Mingora or Kalam (PKR 2,500–6,000/night)',
        'bestTime': 'April – October',
        'tip': 'Bargain for authentic handmade Swati shawls in Mingora bazaar.',
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
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 900,
        'responseMimeType': 'application/json',
      },
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
    if (q.contains('murree') || q.contains('galiyat') || q.contains('nathia')) {
      return '🌲 **Murree & Galiyat Travel Guide:**\n\n'
          '• **Distance:** 1.5–2 hours from Islamabad via Murree Expressway\n'
          '• **Budget:** PKR 4,000–8,000 per person for a 1-day or weekend trip\n'
          '• **Must-see:** Mall Road, Pindi Point, Kashmir Point, Patriata Chairlift\n'
          '• **Transport:** Hi-Ace van from Faizabad (~PKR 350) or private taxi (~PKR 3,500)\n'
          '• **Tip:** Visit on weekdays to avoid traffic congestion on Mall Road.';
    }
    if (q.contains('islamabad') || q.contains('isb') || q.contains('rawalpindi') || q.contains('pindi')) {
      return '🏛️ **Islamabad & Rawalpindi Guide:**\n\n'
          '• **Must-see:** Faisal Mosque, Daman-e-Koh, Monal (Margalla Hills), Lok Virsa, Pakistan Monument\n'
          '• **Budget:** PKR 3,000–6,000/day for food and local commute\n'
          '• **Food:** Cheezious, Savour Foods (Pindi), Melody Food Park, Saidpur Village\n'
          '• **Transport:** Metro Bus (PKR 30 flat), Careem, or Yango.';
    }
    if (q.contains('karachi') || q.contains('clifton') || q.contains('sea view')) {
      return '🌊 **Karachi — City of Lights:**\n\n'
          '• **Must-see:** Clifton Beach, Port Grand, Mazar-e-Quaid, Burns Road, Mohatta Palace\n'
          '• **Food:** Burns Road Nihari & Haleem, Student Biryani, Kolachi at Do Darya\n'
          '• **Best time:** November to February (cool coastal breezes)\n'
          '• **Budget:** PKR 4,000–8,000/day (hotels + food + transport).';
    }
    if (q.contains('swat') || q.contains('kalam') || q.contains('malam jabba')) {
      return '🏞️ **Swat & Kalam Valley:**\n\n'
          '• **Best time:** April to October (lush green) or Jan–Feb for skiing at Malam Jabba\n'
          '• **Budget:** PKR 15,000–25,000 per person (3–4 days)\n'
          '• **Must-see:** Malam Jabba Ski Resort, Mahodand Lake, Ushu Forest, Mingora Bazaar\n'
          '• **Transport:** Swat Express via M-16 Motorway (4–5 hours from Islamabad).';
    }
    if (q.contains('naran') || q.contains('kaghan') || q.contains('saif ul malook') || q.contains('babusar')) {
      return '🏔️ **Naran & Kaghan Valley:**\n\n'
          '• **Best time:** June to September (roads clear of snow)\n'
          '• **Budget:** PKR 18,000–30,000 per person (3–4 days)\n'
          '• **Must-see:** Lake Saif-ul-Malook (jeep ride), Babusar Top, Lulusar Lake, Shogran\n'
          '• **Jeep rent:** PKR 3,500–5,000 for Saif-ul-Malook return.';
    }
    if (q.contains('neelum') || q.contains('kashmir') || q.contains('arang kel')) {
      return '🌲 **Neelum Valley, Azad Kashmir:**\n\n'
          '• **Best time:** May to October\n'
          '• **Budget:** PKR 14,000–25,000 per person (3–4 days)\n'
          '• **Must-see:** Dhani Waterfall, Kutton, Keran (LOC view), Sharda Peeth, Arang Kel\n'
          '• **Important:** Carry original CNIC / passport as security checkpoints are mandatory.';
    }
    if (q.contains('transport') || q.contains('bus') || q.contains('train') || q.contains('daewoo') || q.contains('flight')) {
      return '🚌 **Pakistan Transport Options:**\n\n'
          '• **Intercity Bus:** Faisal Movers, Daewoo Express, Road Master, Sania Express (comfortable, punctual, PKR 1,500–3,500)\n'
          '• **Northern Areas:** NATCO (Rawalpindi Pirwadhai) for Gilgit, Hunza, and Skardu\n'
          '• **Train:** Pakistan Railways (Green Line & Tezgam recommended for Karachi-Lahore-ISB)\n'
          '• **Flights:** PIA, Airblue, Serene, Fly Jinnah (ISB–Skardu/Gilgit depends on weather).';
    }
    if (q.contains('hotel') || q.contains('stay') || q.contains('guesthouse') || q.contains('room')) {
      return '🏨 **Accommodation & Lodging Advice:**\n\n'
          '• **Budget Guesthouses:** PKR 2,000–3,500/night (clean, basic amenities)\n'
          '• **Mid-Range Hotels:** PKR 5,000–10,000/night (hot water, Wi-Fi, generator)\n'
          '• **Luxury / Resorts:** PKR 15,000–35,000/night (Serena, Pearl Continental, Luxus)\n'
          '• **Tip:** Book 2 weeks in advance during peak summer (July–August) in northern valleys.';
    }
    if (q.contains('safety') || q.contains('safe') || q.contains('emergency') || q.contains('police') || q.contains('1122')) {
      return '🚨 **Safety & Emergency Helplines:**\n\n'
          '• **Rescue 1122:** Emergency medical & rescue across Punjab, KPK, and AJK\n'
          '• **Motorway & Highway Police:** Call 130\n'
          '• **Tourist Police Helpline:** 1422 (KPK Tourism)\n'
          '• **General Emergency:** 15 (Police)\n'
          '• **Safety Tip:** Always check local road conditions and landslides before crossing high mountain passes like Babusar or Lowari.';
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
