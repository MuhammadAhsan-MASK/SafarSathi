import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme.dart';

class RegionLingoScreen extends StatefulWidget {
  final String regionName;
  final Color color;

  const RegionLingoScreen({
    super.key,
    required this.regionName,
    required this.color,
  });

  @override
  State<RegionLingoScreen> createState() => _RegionLingoScreenState();
}

class _RegionLingoScreenState extends State<RegionLingoScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String _selectedLanguage = 'All';
  String? _currentlySpeaking;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _clearSpeaking() {
    if (mounted && _currentlySpeaking != null) {
      setState(() {
        _currentlySpeaking = null;
      });
    }
  }

  Future<void> _initTts() async {
    try {
      flutterTts.setCompletionHandler(_clearSpeaking);
      flutterTts.setCancelHandler(_clearSpeaking);
      flutterTts.setErrorHandler((_) => _clearSpeaking());

      // Phrases & phonetic guides are Latin-scripted; prefer an available English voice first, falling back to ur-PK.
      for (final locale in ['en-US', 'en-GB', 'ur-PK']) {
        final available = await flutterTts.isLanguageAvailable(locale);
        if (available == true) {
          await flutterTts.setLanguage(locale);
          break;
        }
      }
      await flutterTts.setSpeechRate(0.45);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint("TTS init error: $e");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String key, {String? phoneticText}) async {
    if (_currentlySpeaking == key) {
      await flutterTts.stop();
      _clearSpeaking();
      return;
    }

    try {
      // Stop any prior utterance before setting the new speaking key so cancel handler won't clear it.
      await flutterTts.stop();
      if (!mounted) return;
      setState(() {
        _currentlySpeaking = key;
      });

      final rawSpoken = (phoneticText != null && phoneticText.trim().isNotEmpty)
          ? phoneticText
          : key;
      final spoken = rawSpoken.replaceAll('/', ', ');
      final result = await flutterTts.speak(spoken);
      if (result != 1 && mounted) {
        _clearSpeaking();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Audio pronunciation unavailable on this device.')),
        );
      }
    } catch (e) {
      _clearSpeaking();
    }
  }

  Map<String, dynamic> _getRegionData() {
    final Map<String, dynamic> data = {
      'Gilgit-Baltistan': {
        'languages': ['All', 'Balti', 'Shina', 'Burushaski'],
        'phrases': [
          // Balti (Skardu, Shigar, Khaplu)
          {
            'english': 'Hello / Warm Greetings',
            'local': 'Ju / Juley',
            'pronunciation': 'Joo / Joo-lay',
            'language': 'Balti',
            'note': 'Universal, heartfelt Balti greeting across Skardu & Ladakh border',
          },
          {
            'english': 'How are you?',
            'local': 'Khamzang-a?',
            'pronunciation': 'Kham-zang-aa?',
            'language': 'Balti',
            'note': 'Enquiring about health and well-being',
          },
          {
            'english': 'I am doing well',
            'local': 'Khamzang',
            'pronunciation': 'Kham-zang',
            'language': 'Balti',
            'note': 'Standard polite response meaning well/peaceful',
          },
          {
            'english': 'Thank you very much',
            'local': 'Kadrinche',
            'pronunciation': 'Kha-drin-chay',
            'language': 'Balti',
            'note': 'Deep expression of gratitude',
          },
          {
            'english': 'I need water',
            'local': 'Chhu gos',
            'pronunciation': 'Chhoo goss',
            'language': 'Balti',
            'note': 'Useful when trekking or at restaurants',
          },
          {
            'english': 'How much does this cost?',
            'local': 'Chi tsonduk?',
            'pronunciation': 'Chee tson-dook?',
            'language': 'Balti',
            'note': 'For bargaining in Skardu & Khaplu bazaars',
          },
          {
            'english': 'Is it very far?',
            'local': 'Diba ringmo duk-a?',
            'pronunciation': 'Dee-ba ring-mo dook-aa?',
            'language': 'Balti',
            'note': 'Asking locals about mountain distances',
          },
          // Shina (Gilgit, Diamer, Astore, Hunza valleys)
          {
            'english': 'Peace be upon you / Hello',
            'local': 'Masilamu',
            'pronunciation': 'Ma-see-laa-moo',
            'language': 'Shina',
            'note': 'Traditional Dardic Shina greeting',
          },
          {
            'english': 'How are you?',
            'local': 'Jeji billa?',
            'pronunciation': 'Jay-jee bil-laa?',
            'language': 'Shina',
            'note': 'Common friendly check-in in Gilgit & Chilas',
          },
          {
            'english': 'Thank God / I am good',
            'local': 'Shukur Khudaar',
            'pronunciation': 'Shoo-koor Khoo-daar',
            'language': 'Shina',
            'note': 'Polite response meaning all is well',
          },
          {
            'english': 'Many thanks',
            'local': 'Bolo shukriya',
            'pronunciation': 'Bo-lo shook-ree-yaa',
            'language': 'Shina',
            'note': 'Expressing sincere thanks',
          },
          {
            'english': 'Please give water',
            'local': 'Wai dyo',
            'pronunciation': 'Wye dyoh',
            'language': 'Shina',
            'note': 'Essential word (Wai = Water)',
          },
          {
            'english': 'How much will you take?',
            'local': 'Kachak ghinno?',
            'pronunciation': 'Ka-chak ghin-no?',
            'language': 'Shina',
            'note': 'Asking jeep drivers or merchants for price',
          },
          {
            'english': 'Let us drink tea',
            'local': 'Chai pie',
            'pronunciation': 'Chye pee-ay',
            'language': 'Shina',
            'note': 'A warm social invitation',
          },
          // Burushaski (Hunza, Nagar, Yasin)
          {
            'english': 'Greetings / Hello',
            'local': 'Leh / Bosh',
            'pronunciation': 'Lay / Bosh',
            'language': 'Burushaski',
            'note': 'Iconic greeting in Hunza and Nagar valleys',
          },
          {
            'english': 'Are you doing well?',
            'local': 'Mishaan baa?',
            'pronunciation': 'Mee-shaan baa?',
            'language': 'Burushaski',
            'note': 'Used when welcoming guests in Karimabad',
          },
          {
            'english': 'Welcome',
            'local': 'Ju ba',
            'pronunciation': 'Joo baa',
            'language': 'Burushaski',
            'note': 'Hospitality greeting when arriving at homes',
          },
          {
            'english': 'Thank you',
            'local': 'Ju charsh',
            'pronunciation': 'Joo charsh',
            'language': 'Burushaski',
            'note': 'Gratitude in Burushaski',
          },
          {
            'english': 'Water',
            'local': 'Tsil',
            'pronunciation': 'Tseel',
            'language': 'Burushaski',
            'note': 'Spring/mineral water',
          },
        ],
        'etiquette': [
          'Dress modestly, especially when strolling through mountain villages and outside main hotels.',
          'Always ask for permission before taking photographs of locals, especially women and elderly residents.',
          'Take off your shoes when stepping into traditional wood-paneled homes, mosques, or prayer halls.',
          'Accepting dried apricots, walnuts, or herbal tea when invited into a local home is considered good manners.',
        ],
        'culture': [
          'GB is home to some of the highest literacy rates in Pakistan and a culture of profound peace and communal harmony.',
          'Historic junction of the ancient Silk Road, with rich Tibetan, Central Asian, and Dardic influences.',
          'Freestyle Mountain Polo at Shandur and polo grounds across Skardu and Gilgit is celebrated as a festival of pride.',
        ],
        'food': [
          'Chapshoro: Savory flatbread stuffed with minced beef/mutton, onions, and mountain herbs baked on iron skillets.',
          'Mamtu: Delicately steamed dumplings packed with spiced minced meat, topped with tangy vinegar and chili sauce.',
          'Hunza Walnut Cake & Apricot Oil: Decadent honey-walnut tarts and pure cold-pressed apricot kernel oil.',
        ]
      },

      'Khyber Pakhtunkhwa': {
        'languages': ['All', 'Pashto', 'Hindko'],
        'phrases': [
          // Pashto (Peshawar, Swat, Mardan, Dir)
          {
            'english': 'May you not be tired! (Greeting)',
            'local': 'Staray mashe!',
            'pronunciation': 'Stah-ray ma-shay!',
            'language': 'Pashto',
            'note': 'The most iconic, heartfelt Pashto greeting wishing you strength',
          },
          {
            'english': 'May you never feel misery! (Reply)',
            'local': 'Kharay mashe!',
            'pronunciation': 'Khah-ray ma-shay!',
            'language': 'Pashto',
            'note': 'The respectful, mandatory response to Staray Mashe',
          },
          {
            'english': 'Hearty welcome',
            'local': 'Pakhair raghlay',
            'pronunciation': 'Pa-khair ragh-lay',
            'language': 'Pashto',
            'note': 'Welcoming guests to a village or home',
          },
          {
            'english': 'How are you?',
            'local': 'Senga yai?',
            'pronunciation': 'Sen-ga yai?',
            'language': 'Pashto',
            'note': 'Everyday inquiry about someone’s condition',
          },
          {
            'english': 'I am fine, praise God',
            'local': 'Kha yam, shukur',
            'pronunciation': 'Khah yum, shoo-koor',
            'language': 'Pashto',
            'note': 'Polite standard reply',
          },
          {
            'english': 'Thank you very much',
            'local': 'Dera manana',
            'pronunciation': 'Day-ra ma-naa-na',
            'language': 'Pashto',
            'note': 'Deep gratitude for hospitality',
          },
          {
            'english': 'How much is this?',
            'local': 'Da pa tso day?',
            'pronunciation': 'Daa pa tso day?',
            'language': 'Pashto',
            'note': 'Inquiring prices in Qissa Khwani or Mingora bazaar',
          },
          {
            'english': 'Please reduce the price a bit',
            'local': 'Laga qeemat kam kra',
            'pronunciation': 'La-ga qee-mat kum kraa',
            'language': 'Pashto',
            'note': 'Friendly bargaining phrase',
          },
          {
            'english': 'I want drinking water',
            'local': 'Oba ghwaram',
            'pronunciation': 'Oh-ba ghwah-rum',
            'language': 'Pashto',
            'note': 'Essential hydration phrase',
          },
          {
            'english': 'Where does this road go?',
            'local': 'Da lara kithay zi?',
            'pronunciation': 'Daa laa-ra kee-thay zee?',
            'language': 'Pashto',
            'note': 'Asking directions on mountain passes',
          },
          {
            'english': 'The food is very delicious!',
            'local': 'Dera khwandawar khorak day',
            'pronunciation': 'Day-ra khwan-da-war kho-raak day',
            'language': 'Pashto',
            'note': 'Complimenting the chef or host',
          },
          {
            'english': 'May God protect you (Goodbye)',
            'local': 'Da Khuda pa aman',
            'pronunciation': 'Daa Khoo-daa pa uh-maan',
            'language': 'Pashto',
            'note': 'Traditional Pashto farewell',
          },
          // Hindko (Abbottabad, Haripur, Mansehra, Peshawar City)
          {
            'english': 'How are you?',
            'local': 'Kiya haal ay?',
            'pronunciation': 'Kee-yaa haal ay?',
            'language': 'Hindko',
            'note': 'Standard friendly greeting in Hazara region',
          },
          {
            'english': 'I am totally fine',
            'local': 'Main theek thaak aan',
            'pronunciation': 'Main theek thaak aan',
            'language': 'Hindko',
            'note': 'Common positive response',
          },
          {
            'english': 'Thank you very much',
            'local': 'Bari meherbani',
            'pronunciation': 'Buh-ree meher-baa-nee',
            'language': 'Hindko',
            'note': 'Showing appreciation to hosts',
          },
          {
            'english': 'Where are you heading?',
            'local': 'Kithay chally o?',
            'pronunciation': 'Kee-thay chal-lay oh?',
            'language': 'Hindko',
            'note': 'Conversational travel question',
          },
          {
            'english': 'What is its price?',
            'local': 'Aeda ketna mool ay?',
            'pronunciation': 'Ay-daa ket-naa mool ay?',
            'language': 'Hindko',
            'note': 'Asking shopping and fare costs',
          },
          {
            'english': 'Please serve water',
            'local': 'Pani pilao',
            'pronunciation': 'Paa-nee pee-laa-o',
            'language': 'Hindko',
            'note': 'Requesting a glass of water',
          },
        ],
        'etiquette': [
          'Pashtun culture is rooted in Melmastia (boundless hospitality). Refusing tea or meals offered by hosts is frowned upon.',
          'Always greet the oldest people in the room first with a respectful two-hand shake or slight chest bow.',
          'Modest attire is expected throughout KP; men typically wear Shalwar Kameez and women wear loose shawls (chador).',
        ],
        'culture': [
          'Pashtunwali: An ancient honor code prioritizing courage, hospitality, self-respect, and protection of guests.',
          'Musical traditions center around the soul-stirring acoustic Rubab, Mangay, and Mangay-percussion.',
          'Rich literary tradition featuring legendary poets like Khushal Khan Khattak and Rahman Baba.',
        ],
        'food': [
          'Peshawari Chapli Kebab: Minced beef or mutton flattened with pomegranate seeds, coriander, and fried in pure tallow.',
          'Shinwari Karahi: Tender meat seared strictly with animal fat, tomatoes, ginger, and green chilies without heavy powders.',
          'Peshawari Kahwa: Aromatic green tea brewed with cardamoms, served steaming hot alongside dates or boiled sweets.',
        ]
      },

      'Punjab': {
        'languages': ['All', 'Punjabi', 'Saraiki'],
        'phrases': [
          // Punjabi (Lahore, Faisalabad, Gujranwala, Rawalpindi)
          {
            'english': 'How are you doing?',
            'local': 'Ki haal chaal ay?',
            'pronunciation': 'Kee haal chaal ay?',
            'language': 'Punjabi',
            'note': 'The classic, spirited Punjabi opening inquiry',
          },
          {
            'english': 'I am absolutely fine',
            'local': 'Main bilkul theek aan',
            'pronunciation': 'Main bil-kool theek aan',
            'language': 'Punjabi',
            'note': 'Energetic affirmative response',
          },
          {
            'english': 'Hearty welcome',
            'local': 'Jee aya nu',
            'pronunciation': 'Jee aah-yaan noon',
            'language': 'Punjabi',
            'note': 'The iconic Punjabi sign of warmth and hospitality',
          },
          {
            'english': 'Thank you so much',
            'local': 'Bari meherbani / Shukriya',
            'pronunciation': 'Buh-ree meher-baa-nee',
            'language': 'Punjabi',
            'note': 'Expressing sincere thanks',
          },
          {
            'english': 'How much does it cost?',
            'local': 'Kinne paise banay?',
            'pronunciation': 'Kin-nay py-say buh-nay?',
            'language': 'Punjabi',
            'note': 'Standard price calculation in markets & rickshaws',
          },
          {
            'english': 'Please reduce the price a bit',
            'local': 'Thora ghatt karo bhai',
            'pronunciation': 'Tho-raa ghatt ka-ro bhai',
            'language': 'Punjabi',
            'note': 'Gentle bargaining in Anarkali or Liberty Market',
          },
          {
            'english': 'Can I get drinking water?',
            'local': 'Pani milaiga?',
            'pronunciation': 'Paa-nee mee-lay gaa?',
            'language': 'Punjabi',
            'note': 'Asking for clean drinking water',
          },
          {
            'english': 'It was delicious! Loved it!',
            'local': 'Swad aa gaya!',
            'pronunciation': 'Swaad aa ga-yaa!',
            'language': 'Punjabi',
            'note': 'The highest praise for Lahori or street food',
          },
          {
            'english': 'Please stop at the next turn',
            'local': 'Aglay morr te roko',
            'pronunciation': 'Ag-lay morr tay ro-ko',
            'language': 'Punjabi',
            'note': 'Instructing taxi or auto drivers',
          },
          {
            'english': 'May God protect you (Goodbye)',
            'local': 'Rab rakha',
            'pronunciation': 'Rub ruh-khaa',
            'language': 'Punjabi',
            'note': 'Traditional affectionate Punjabi farewell',
          },
          // Saraiki (Multan, Bahawalpur, D.G. Khan)
          {
            'english': 'How is everything going?',
            'local': 'Kiyan haal hai?',
            'pronunciation': 'Kee-yaan haal hai?',
            'language': 'Saraiki',
            'note': 'Sweet, melodic greeting across Southern Punjab',
          },
          {
            'english': 'Everything is great',
            'local': 'Sabh theek hai',
            'pronunciation': 'Subh theek hai',
            'language': 'Saraiki',
            'note': 'Peaceful response',
          },
          {
            'english': 'Warmest welcome',
            'local': 'Bhali karay aayo',
            'pronunciation': 'Bha-lee ka-ray aa-yo',
            'language': 'Saraiki',
            'note': 'Traditional welcome in the City of Saints (Multan)',
          },
          {
            'english': 'Many thanks to you',
            'local': 'Tuhadi bari meherbani',
            'pronunciation': 'Too-haa-dee buh-ree meher-baa-nee',
            'language': 'Saraiki',
            'note': 'Heartfelt thanks',
          },
          {
            'english': 'Where are you travelling?',
            'local': 'Kithan wanjnay o?',
            'pronunciation': 'Kee-thaan wanj-nay oh?',
            'language': 'Saraiki',
            'note': 'Inquiring destination',
          },
          {
            'english': 'How much is this for?',
            'local': 'Heh kiday mool da hai?',
            'pronunciation': 'Hay kee-day mool daa hai?',
            'language': 'Saraiki',
            'note': 'Asking rates in Multan blue pottery bazaars',
          },
          {
            'english': 'Please have some tea, sir',
            'local': 'Chah piwo sain',
            'pronunciation': 'Chaah pee-wo saa-een',
            'language': 'Saraiki',
            'note': 'Southern Punjab tea invitation',
          },
        ],
        'etiquette': [
          'Punjabis are famous for boundless hospitality and love for entertaining. Never refuse a second helping of food!',
          'Warm embraces (Jhappi) and loud, affectionate exchanges are normal among friends and acquaintances.',
          'When visiting Sufi shrines (like Data Darbar or Shah Rukn-e-Alam), remove shoes and cover your head.',
        ],
        'culture': [
          'The agrarian powerhouse of Pakistan, celebrated through vibrant seasonal festivals, Bhangra beats, and Dhol rhythms.',
          'Rich Sufi heritage preserved in the poetry of Bulleh Shah, Waris Shah, and Sultan Bahoo.',
          'Historic culinary enthusiasm — eating together at open food streets is the ultimate social bonding ritual.',
        ],
        'food': [
          'Sarson Ka Saag & Makki Ki Roti: Slow-cooked mustard greens drenched in homemade desi ghee with fresh cornbread.',
          'Lahori Nihari & Chargha: Fragrant slow-cooked beef shank stew and whole spiced deep-fried chicken.',
          'Multani Sohan Halwa & Creamy Lassi: Dense caramelized nut confection and tall frothy brass glasses of yogurt lassi.',
        ]
      },

      'Sindh': {
        'languages': ['All', 'Sindhi', 'Urdu'],
        'phrases': [
          // Sindhi (Karachi, Hyderabad, Sukkur, Larkana, Thar)
          {
            'english': 'Respectful greeting / Hello',
            'local': 'Sain salam alaikum',
            'pronunciation': 'Saa-een sa-laam uh-lay-kum',
            'language': 'Sindhi',
            'note': 'Gentle, respectful Sindhi salutation',
          },
          {
            'english': 'How are you?',
            'local': 'Kee-an ahyo?',
            'pronunciation': 'Kee-an ah-yo?',
            'language': 'Sindhi',
            'note': 'Everyday friendly inquiry',
          },
          {
            'english': 'Fine and in peace',
            'local': 'Theek thaak, khairiyat',
            'pronunciation': 'Theek thaak, khai-ree-yut',
            'language': 'Sindhi',
            'note': 'Standard response meaning all is peaceful',
          },
          {
            'english': 'Hearty welcome',
            'local': 'Bhali karē aaya',
            'pronunciation': 'Bha-lee ka-ray aa-yaa',
            'language': 'Sindhi',
            'note': 'Warm traditional Sindhi welcome phrase',
          },
          {
            'english': 'Thank you, sir',
            'local': 'Meherbani sain',
            'pronunciation': 'Meher-baa-nee saa-een',
            'language': 'Sindhi',
            'note': 'Graceful expression of appreciation',
          },
          {
            'english': 'How much money is it?',
            'local': 'Paiyso ketro thiyo?',
            'pronunciation': 'Pye-so ket-ro thee-yo?',
            'language': 'Sindhi',
            'note': 'Essential shopping and transport phrase',
          },
          {
            'english': 'Please discount a little',
            'local': 'Thoro ghatt kario',
            'pronunciation': 'Tho-ro ghatt kuh-ree-o',
            'language': 'Sindhi',
            'note': 'Gentle bargaining in Hyderabad or Sukkur markets',
          },
          {
            'english': 'Will drinking water be available?',
            'local': 'Pani milando?',
            'pronunciation': 'Paa-nee mee-lan-do?',
            'language': 'Sindhi',
            'note': 'Asking for drinking water',
          },
          {
            'english': 'Where does this road lead?',
            'local': 'Heh rasto kithe tho wanje?',
            'pronunciation': 'Hay ras-to kee-thay tho wan-jay?',
            'language': 'Sindhi',
            'note': 'Asking road directions',
          },
          {
            'english': 'The food is very delicious',
            'local': 'Khado dharo bhallo aahe',
            'pronunciation': 'Khaa-do dha-ro bhal-lo aa-hay',
            'language': 'Sindhi',
            'note': 'Complimenting Sindhi home or restaurant dishes',
          },
          {
            'english': 'Have some Sindhi tea, brother',
            'local': 'Chah pio ada',
            'pronunciation': 'Chaah pee-o uh-daa',
            'language': 'Sindhi',
            'note': 'Common hospitable invitation (Ada = Brother)',
          },
          {
            'english': 'May God protect you (Farewell)',
            'local': 'Allah vahi',
            'pronunciation': 'Ul-laah vaa-hee',
            'language': 'Sindhi',
            'note': 'Traditional Sufi blessing on departing',
          },
          // Urdu (Urban Karachi & throughout Sindh)
          {
            'english': 'Brother, how much is this?',
            'local': 'Bhai yeh kitnay ka hai?',
            'pronunciation': 'Bhai yeh kit-nay kaa hai?',
            'language': 'Urdu',
            'note': 'Everyday market inquiry across Karachi',
          },
          {
            'english': 'Thank you very much',
            'local': 'Aap ka bohat shukriya',
            'pronunciation': 'Aap kaa buh-hut shook-ree-yaa',
            'language': 'Urdu',
            'note': 'Universal polite gratitude',
          },
          {
            'english': 'Which way to the bazaar?',
            'local': 'Bazaar kis taraf hai?',
            'pronunciation': 'Baa-zaar kis tuh-ruf hai?',
            'language': 'Urdu',
            'note': 'Asking for main markets or landmarks',
          },
        ],
        'etiquette': [
          'Ajrak (intricate block-printed shawl) and Sindhi Topi (mirror-work cap) are symbols of supreme honor, gifted to revered guests.',
          'Sufi shrines (such as Lal Shahbaz Qalandar and Shah Abdul Latif Bhittai) require respectful demeanor; remove footwear outside.',
          'Tea is offered at almost every interaction, from tea stalls to business meetings; it is courteous to sip a few ounces.',
        ],
        'culture': [
          'Known as Bab-ul-Islam (Gateway of Islam), Sindh possesses a 5,000-year history tracing to Mohenjo-Daro on the Indus.',
          'Deep spiritual Sufi heritage defined by message of universal peace, mystic poetry, and evening Dhammal drumming.',
          'Celebrated handicrafts including blue pottery of Hala, Ralli quilts of Thar, and hand-loomed Kashmkari fabrics.',
        ],
        'food': [
          'Sindhi Biryani: Distinctive aromatic long-grain rice layered with tangy plums (aloo bukhara), potatoes, and robust masala.',
          'Sindhi Kadi & Chawal: Tamarind and gram-flour vegetable stew served piping hot over fluffy white rice.',
          'Palla Fish & Shikarpuri Achar: Prized Indus River hilsa fish and world-famous mustard-oil spiced mixed pickles.',
        ]
      },

      'Balochistan': {
        'languages': ['All', 'Balochi', 'Brahui', 'Pashto'],
        'phrases': [
          // Balochi (Quetta, Gwadar, Makran, Turbat)
          {
            'english': 'Hearty welcome',
            'local': 'Wash ahtey',
            'pronunciation': 'Wash ah-tay',
            'language': 'Balochi',
            'note': 'The warmest traditional Balochi greeting to visitors',
          },
          {
            'english': 'How are you?',
            'local': 'Chon aye?',
            'pronunciation': 'Chon eye?',
            'language': 'Balochi',
            'note': 'Everyday friendly check-in',
          },
          {
            'english': 'Are you well and peaceful?',
            'local': 'Durah aye?',
            'pronunciation': 'Doo-rah eye?',
            'language': 'Balochi',
            'note': 'Traditional Balochi enquiry about wellness',
          },
          {
            'english': 'I am fine, praise God',
            'local': 'Shukr, jor aan',
            'pronunciation': 'Shoo-kur, jor aan',
            'language': 'Balochi',
            'note': 'Polite affirmative response',
          },
          {
            'english': 'Thank you very much',
            'local': 'Sak baz mehrbani',
            'pronunciation': 'Sak baaz meher-baa-nee',
            'language': 'Balochi',
            'note': 'Deep expression of gratitude for hospitality',
          },
          {
            'english': 'How much does this cost?',
            'local': 'Eshi chent piri?',
            'pronunciation': 'Ay-shee chent pee-ree?',
            'language': 'Balochi',
            'note': 'Inquiring prices in Quetta or Gwadar bazaars',
          },
          {
            'english': 'Please reduce the price',
            'local': 'Kame kaminja kan',
            'pronunciation': 'Kuh-may kuh-meen-ja kun',
            'language': 'Balochi',
            'note': 'Friendly bargaining phrase',
          },
          {
            'english': 'I need water',
            'local': 'Aap loteen',
            'pronunciation': 'Aap lo-teen',
            'language': 'Balochi',
            'note': 'Asking for drinking water across arid areas',
          },
          {
            'english': 'Where does this road go?',
            'local': 'E raah koja rawt?',
            'pronunciation': 'Ay raah ko-jah rowt?',
            'language': 'Balochi',
            'note': 'Checking route direction on coastal highway or passes',
          },
          {
            'english': 'Very delicious meal',
            'local': 'Washin warragh',
            'pronunciation': 'Wah-sheen wah-ragh',
            'language': 'Balochi',
            'note': 'Complimenting Sajji or Dampukht',
          },
          {
            'english': 'May God protect you (Farewell)',
            'local': 'Khuda e amana',
            'pronunciation': 'Khoo-daa ay uh-maa-na',
            'language': 'Balochi',
            'note': 'Traditional Balochi departure blessing',
          },
          // Brahui (Kalat, Mastung, Khuzdar)
          {
            'english': 'Are you fine and healthy?',
            'local': 'Shar jor us?',
            'pronunciation': 'Shar jor oos?',
            'language': 'Brahui',
            'note': 'The primary wellness greeting in Dravidian Brahui',
          },
          {
            'english': 'Happy and fine',
            'local': 'Khush jor',
            'pronunciation': 'Khoosh jor',
            'language': 'Brahui',
            'note': 'Affirmative wellness reply',
          },
          {
            'english': 'Thank you',
            'local': 'Bari mehrbaani',
            'pronunciation': 'Buh-ree meher-baa-nee',
            'language': 'Brahui',
            'note': 'Gratitude in Brahui',
          },
          {
            'english': 'Give water',
            'local': 'Dir e-te',
            'pronunciation': 'Deer ay-tay',
            'language': 'Brahui',
            'note': 'Essential word (Dir = Water)',
          },
          {
            'english': 'How much is this for?',
            'local': 'Da aakhak na e?',
            'pronunciation': 'Daa aakhak naa ay?',
            'language': 'Brahui',
            'note': 'Asking price of local produce and dry fruits',
          },
          // Pashto (Northern Balochistan: Quetta, Zhob, Pishin)
          {
            'english': 'May you not be tired (Greeting)',
            'local': 'Staray mashe',
            'pronunciation': 'Stah-ray ma-shay',
            'language': 'Pashto',
            'note': 'Common greeting in northern Pashtun belt of Balochistan',
          },
          {
            'english': 'Welcome',
            'local': 'Pakhair',
            'pronunciation': 'Pa-khair',
            'language': 'Pashto',
            'note': 'Friendly welcome',
          },
        ],
        'etiquette': [
          'Hospitality (Mehmandari) is paramount; hosts will go to extraordinary lengths to ensure their guest’s comfort.',
          'Always address tribal elders and family heads with deep deference before addressing younger peers.',
          'Travel in daylight across desert stretches and always carry surplus drinking water in remote areas.',
        ],
        'culture': [
          'Vast rugged landscapes holding 9,000-year-old archaeological wonders including Mehrgarh near Bolan Pass.',
          'Renowned for distinct needlework embroidery (Dozi) and artisanal hand-stitched leather Chawat sandals.',
          'Rich oral folklore, heroic ballads, and coastal fishing traditions spanning the 700km Makran shoreline.',
        ],
        'food': [
          'Balochi Sajji: Whole skewered lamb or chicken slow-roasted around burning wood embers seasoned purely with coarse salt.',
          'Kaak (Pathar Ki Roti): Dense round bread rolled around heated river stones and baked crunchy over open fires.',
          'Dampukht: Tender meat cooked in airtight clay pots with whole garlic, onions, and potatoes in its natural rendered fat.',
        ]
      },

      'Kashmir & Neelum': {
        'languages': ['All', 'Pahari', 'Kashmiri', 'Hindko'],
        'phrases': [
          // Pahari-Pothwari (Muzaffarabad, Mirpur, Rawalakot, Neelum Valley)
          {
            'english': 'How are you doing?',
            'local': 'Kiyan o / Ki haal o?',
            'pronunciation': 'Kee-yaan oh / Kee haal oh?',
            'language': 'Pahari',
            'note': 'Gentle Pahari greeting across Azad Kashmir valleys',
          },
          {
            'english': 'I am totally fine',
            'local': 'Theek thaak shukriya',
            'pronunciation': 'Theek thaak shook-ree-yaa',
            'language': 'Pahari',
            'note': 'Standard reply of wellness',
          },
          {
            'english': 'Hearty welcome',
            'local': 'Jee aya nu',
            'pronunciation': 'Jee aah-yaan noon',
            'language': 'Pahari',
            'note': 'Warm mountain hospitality greeting',
          },
          {
            'english': 'What is the price?',
            'local': 'Kina mul ay?',
            'pronunciation': 'Kee-naa mool ay?',
            'language': 'Pahari',
            'note': 'Asking costs for hotels, jeeps, or handicrafts',
          },
          {
            'english': 'Please discount a bit',
            'local': 'Thora ghatt karo ji',
            'pronunciation': 'Tho-raa ghatt ka-ro jee',
            'language': 'Pahari',
            'note': 'Respectful bargaining',
          },
          {
            'english': 'Can drinking water be found?',
            'local': 'Pani labsi?',
            'pronunciation': 'Paa-nee lub-see?',
            'language': 'Pahari',
            'note': 'Asking for fresh mountain spring water',
          },
          {
            'english': 'Where are you travelling to?',
            'local': 'Kithay julnay o?',
            'pronunciation': 'Kee-thay jool-nay oh?',
            'language': 'Pahari',
            'note': 'Asking travel directions along the Neelum River',
          },
          {
            'english': 'This is a very beautiful area',
            'local': 'Bara khoobsoorat elaqah ay',
            'pronunciation': 'Buh-raa khoob-soo-rat eh-laa-qaa ay',
            'language': 'Pahari',
            'note': 'Praising the scenic landscape to local hosts',
          },
          {
            'english': 'Drink Kashmiri pink tea',
            'local': 'Noon chai piyo',
            'pronunciation': 'Noon chye pee-yo',
            'language': 'Pahari',
            'note': 'Inviting someone for traditional salted tea',
          },
          {
            'english': 'May God keep you safe (Farewell)',
            'local': 'Rab hawaalay',
            'pronunciation': 'Rub huh-waa-lay',
            'language': 'Pahari',
            'note': 'Affectionate mountain parting blessing',
          },
          // Kashmiri (Neelum Valley, Leepa, and ethnic Kashmiri families)
          {
            'english': 'Are you doing well?',
            'local': 'Variye chhua?',
            'pronunciation': 'Vah-ree-yay chhoo-aa?',
            'language': 'Kashmiri',
            'note': 'Traditional Kashmiri inquiry of wellness',
          },
          {
            'english': 'I am doing well, thank you',
            'local': 'Me chhu theek, shukriya',
            'pronunciation': 'May chhoo theek, shook-ree-yaa',
            'language': 'Kashmiri',
            'note': 'Polite affirmative answer',
          },
          {
            'english': 'What is your name?',
            'local': 'Tuhund naav kya chhu?',
            'pronunciation': 'Too-hoond naav kyah chhoo?',
            'language': 'Kashmiri',
            'note': 'Introducing yourself to local guides and hosts',
          },
          {
            'english': 'Is drinking water available?',
            'local': 'Aab chhu aamut?',
            'pronunciation': 'Aab chhoo aa-moot?',
            'language': 'Kashmiri',
            'note': 'Essential Kashmiri word (Aab = Water)',
          },
          {
            'english': 'Thank you so much',
            'local': 'Tuhund setha shukriya',
            'pronunciation': 'Too-hoond say-thaa shook-ree-yaa',
            'language': 'Kashmiri',
            'note': 'Deep gratitude in authentic Kashmiri',
          },
          // Hindko (Border regions and valley settlements)
          {
            'english': 'Welcome with open arms',
            'local': 'Khush aamdeed',
            'pronunciation': 'Khoosh aam-deed',
            'language': 'Hindko',
            'note': 'Warm reception greeting',
          },
          {
            'english': 'Is the road ahead clear?',
            'local': 'Aglan rasta theek ay?',
            'pronunciation': 'Ag-laan ras-taa theek ay?',
            'language': 'Hindko',
            'note': 'Checking road conditions after rain or snow',
          },
        ],
        'etiquette': [
          'Always keep your original CNIC or identification readily accessible, as security checkpoints are frequent near border areas.',
          'Help preserve pristine alpine ecosystems — pack out all plastics and trash when camping near Ratti Gali or Arang Kel.',
          'Dress modestly and respect rural privacy, especially near traditional wooden log villages and sacred shrines.',
        ],
        'culture': [
          'Known as Heaven on Earth, celebrated for lush pine forests, glacial streams, and intricate wooden architecture.',
          'Rich craftsmanship in fine Pashmina shawls, walnut-wood carved boxes, and chain-stitch embroidered rugs.',
          'Centuries-old scholarly heritage preserved in sites like the ancient Sharda Peeth university ruins in upper Neelum.',
        ],
        'food': [
          'Kashmiri Noon Chai: Signature pink salted tea brewed with soda bicarbonate, milk, and garnished with crushed pistachios.',
          'Kulcha & Kashmiri Bakarkhani: Flaky, layered tandoor-baked breads eaten hot during chilly mornings with tea.',
          'Gushtaba & Roghan Josh: Velvety minced mutton meatballs in creamy yogurt gravy and slow-simmered Kashmiri chili lamb.',
        ]
      },
    };

    return data[widget.regionName] ?? data['Punjab']!;
  }

  @override
  Widget build(BuildContext context) {
    final data = _getRegionData();
    final allPhrases = data['phrases'] as List<Map<String, String>>;
    final languages = (data['languages'] as List<dynamic>).cast<String>();
    final etiquette = data['etiquette'] as List<String>;
    final culture = data['culture'] as List<String>;
    final food = data['food'] as List<String>;

    final filteredPhrases = _selectedLanguage == 'All'
        ? allPhrases
        : allPhrases.where((p) => p['language'] == _selectedLanguage).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.regionName,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color.withAlpha(200), widget.color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.translate_rounded,
                    size: 80,
                    color: Colors.white.withAlpha(60),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Culture & People', Icons.diversity_3, widget.color),
                  const SizedBox(height: 12),
                  _buildListCard(culture),

                  const SizedBox(height: 28),

                  _buildSectionTitle('Must-Try Cuisine', Icons.restaurant_menu, widget.color),
                  const SizedBox(height: 12),
                  _buildListCard(food),

                  const SizedBox(height: 28),

                  _buildSectionTitle('Cultural Etiquette', Icons.info_outline, widget.color),
                  const SizedBox(height: 12),
                  _buildListCard(etiquette),

                  const SizedBox(height: 32),

                  _buildSectionTitle(
                    'Local Dialects & Travel Phrases',
                    Icons.record_voice_over_rounded,
                    widget.color,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap any card to hear authentic pronunciation or tap copy to share with drivers & locals.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Language Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: languages.map((lang) {
                        final isSelected = _selectedLanguage == lang;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(lang),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                _selectedLanguage = lang;
                              });
                            },
                            selectedColor: widget.color,
                            checkmarkColor: Colors.white,
                            labelStyle: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? widget.color
                                    : Colors.grey.withAlpha(80),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Phrase Cards
                  ...filteredPhrases.map((p) => _buildPhraseCard(p)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((e) {
          final parts = e.split(': ');
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 10),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, height: 1.4),
                      children: parts.length > 1
                          ? [
                              TextSpan(
                                text: '${parts[0]}: ',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: parts.sublist(1).join(': ')),
                            ]
                          : [TextSpan(text: e)],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPhraseCard(Map<String, String> phrase) {
    final isSpeaking = _currentlySpeaking == phrase['local'];
    final lang = phrase['language'];
    final note = phrase['note'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSpeaking ? widget.color : widget.color.withAlpha(40),
          width: isSpeaking ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSpeaking
                ? widget.color.withAlpha(35)
                : Colors.black.withAlpha(10),
            blurRadius: isSpeaking ? 12 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _speak(
            phrase['local'] ?? '',
            phoneticText: phrase['pronunciation'],
          ),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // English title + Language pill
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        phrase['english']!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    if (lang != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.color.withAlpha(70)),
                        ),
                        child: Text(
                          lang,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Local script & Audio action
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        phrase['local']!,
                        style: GoogleFonts.poppins(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      color: Colors.grey[500],
                      tooltip: 'Copy phrase',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: phrase['local']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Copied "${phrase['local']}" to clipboard',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSpeaking
                            ? widget.color
                            : widget.color.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSpeaking
                            ? Icons.graphic_eq_rounded
                            : Icons.volume_up_rounded,
                        color: isSpeaking ? Colors.white : widget.color,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Phonetic pronunciation guide
                Row(
                  children: [
                    Icon(
                      Icons.hearing_outlined,
                      size: 14,
                      color: widget.color.withAlpha(200),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        phrase['pronunciation']!,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: widget.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                if (note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    note,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
