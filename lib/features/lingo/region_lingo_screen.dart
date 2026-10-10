import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    // Attempting to set Urdu/Pakistani localization for accurate regional accents
    await flutterTts.setLanguage("ur-PK"); 
    await flutterTts.setSpeechRate(0.5); 
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Map<String, dynamic> _getRegionData() {
    final defaultData = {
      'phrases': [
        {'english': 'Hello', 'local': 'Assalam o Alaikum', 'pronunciation': 'Ass-ah-laam o A-lay-kum'},
        {'english': 'Thank you', 'local': 'Shukriya', 'pronunciation': 'Shook-ree-ya'},
        {'english': 'How much?', 'local': 'Kitnay ka hai?', 'pronunciation': 'Kit-nay ka hai'},
        {'english': 'Water', 'local': 'Pani', 'pronunciation': 'Paa-nee'},
        {'english': 'Yes / No', 'local': 'Jee / Nahi', 'pronunciation': 'Jee / Na-hee'},
      ],
      'etiquette': [
        'Dress modestly and respect local customs.',
        'Use your right hand for eating and giving/receiving items.',
        'Greetings are very important in Pakistani culture.',
        'Avoid discussing sensitive political or sectarian topics.'
      ],
      'culture': [
        'Pakistanis are known for their profound hospitality (Mehman Nawazi).',
        'Communities are closely knit, and respecting elders is paramount.',
        'Tea (Chai) is the centerpiece of socializing.'
      ],
      'food': [
        'Karahi: A staple meat curry cooked in a wok.',
        'Biryani: Iconic spiced rice.',
        'Chai: Essential milky sweet tea.'
      ]
    };

    final Map<String, dynamic> data = {
      'Gilgit-Baltistan': {
        'phrases': [
          {'english': 'Hello (Shina)', 'local': 'As-salamu alaykum', 'pronunciation': 'As-salamu alaykum'},
          {'english': 'Thank you (Shina)', 'local': 'Shukriya', 'pronunciation': 'Shook-ree-ya'},
          {'english': 'Hello (Balti)', 'local': 'Yang chokh', 'pronunciation': 'Yang chok'},
          {'english': 'Thank you (Balti)', 'local': 'Kadrinche', 'pronunciation': 'Kha-drin-chay'},
        ],
        'etiquette': [
          'Dress modestly, especially when visiting villages outside main tourist hubs.',
          'Always ask for permission before taking photos of locals, particularly women.',
          'Take off your shoes when entering a local home or a mosque.',
          'Bring small gifts like fruit if invited to someone’s house.'
        ],
        'culture': [
          'The people of GB are renowned for being incredibly peaceful and welcoming.',
          'The culture is deeply historical, tracing back to the Silk Route with strong Tibetan influences.',
          'Freestyle Polo is not just a sport here, it is a passionate cultural festival.'
        ],
        'food': [
          'Chapshoro: A popular meat pie resembling a local pizza or calzone.',
          'Mamtu: Delicately steamed dumplings stuffed with minced meat.',
          'Apricot Soups/Juices: Hunza Valley is legendary for its nutrient-rich apricot produce.'
        ]
      },
      'Khyber Pakhtunkhwa': {
        'phrases': [
          {'english': 'Hello', 'local': 'Pakhair raghlay', 'pronunciation': 'Pa-khair ray-lay'},
          {'english': 'Thank you', 'local': 'Manana', 'pronunciation': 'Ma-na-na'},
          {'english': 'How are you?', 'local': 'Senga yai?', 'pronunciation': 'Sang-ga yai'},
        ],
        'etiquette': [
          'Pashtun culture highly values hospitality (Melmastia). You must accept tea if offered!',
          'Elders are highly respected. Always greet them first.',
          'Conservative dress is extremely important.'
        ],
        'culture': [
          'The foundation of the culture is Pashtunwali, an ancient honor code prioritizing courage and asylum.',
          'Music revolves around the Rubab, creating distinct, soulful folk melodies.',
          'Loyalty and honor are the most defining characteristics of the region’s people.'
        ],
        'food': [
          'Chapli Kebab: A uniquely spiced, flat minced meat patty from Peshawar.',
          'Peshawari Karahi: A minimalistic but intensely savory lamb/chicken dish.',
          'Kahwa: Traditional green tea aiding digestion usually served after heavy meals.'
        ]
      },
      'Sindh': {
        'phrases': [
          {'english': 'Hello', 'local': 'Bhali karē aaya', 'pronunciation': 'Bha-lee ka-ray aa-ya'},
          {'english': 'Thank you', 'local': 'Meherbani', 'pronunciation': 'Meher-baa-nee'},
          {'english': 'How are you?', 'local': 'Kee-an ahyo?', 'pronunciation': 'Kee-an ah-yo'},
        ],
        'etiquette': [
          'Ajrak (a printed shawl) and Sindhi Topi are symbols of deep respect and honor.',
          'Offerings at Sufi shrines should be made respectfully.',
          'Food is often shared intimately among families, and it is polite to accept.'
        ],
        'culture': [
          'Sindh is the land of Sufis, and its culture is defined by mystic poetry, peace, and spiritual music.',
          'It holds the ancient ruins of Mohenjo-Daro, making its heritage thousands of years old.',
          'Festivals (Urs) are celebrated with massive devotion, color, and Dhamaal (Sufi dancing).'
        ],
        'food': [
          'Sindhi Biryani: Distinct from other biryanis, it uses potatoes, plums, and a highly spiced masala.',
          'Sai Bhaji: A nutritious local dish made of spinach and lentils.',
          'Palla Fish: A celebrated local fish found in the Indus River.'
        ]
      },
      'Punjab': {
        'phrases': [
          {'english': 'Hello', 'local': 'Ki haal ay?', 'pronunciation': 'Kee haal ay'},
          {'english': 'Thank you', 'local': 'Shukriya / Meherbani', 'pronunciation': 'Meher-baa-nee'},
          {'english': 'Come in', 'local': 'Jee aya nu', 'pronunciation': 'Jee iny-aa noo'},
        ],
        'etiquette': [
          'Punjabis are widely known for being outgoing, joyous, and immensely food-loving.',
          'Never refuse a second helping of food unless you absolutely have to.',
          'Loud greetings, physical embraces (hugs), and loud interactions are very common.'
        ],
        'culture': [
          'Punjab is the agricultural heart of Pakistan resulting in a rich, vibrant agrarian festival culture (like Basant or Baisakhi).',
          'Bhangra music and dance originate here, dominating the cultural joy.',
          'The people are incredibly festive, spirited, and famous for their larger-than-life weddings.'
        ],
        'food': [
          'Sarson Ka Saag & Makki Ki Roti: Mustard greens paired with cornbread, a signature rural dish.',
          'Lahori Chargha: Deep-fried whole chicken coated in potent spices.',
          'Lassi: A heavy, refreshing yogurt drink, served sweet or salty.'
        ]
      }
    };

    return data[widget.regionName] ?? defaultData;
  }

  @override
  Widget build(BuildContext context) {
    final data = _getRegionData();
    final phrases = data['phrases'] as List<Map<String, String>>;
    final etiquette = data['etiquette'] as List<String>;
    final culture = data['culture'] as List<String>;
    final food = data['food'] as List<String>;

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
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color.withAlpha(180), widget.color],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.public, size: 80, color: Colors.white.withAlpha(70)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Culture & People', Icons.diversity_3, widget.color),
                  const SizedBox(height: 16),
                  _buildListCard(culture),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Local Food', Icons.restaurant_menu, widget.color),
                  const SizedBox(height: 16),
                  _buildListCard(food),

                  const SizedBox(height: 32),
                  
                  _buildSectionTitle('Cultural Etiquette', Icons.info_outline, widget.color),
                  const SizedBox(height: 16),
                  _buildListCard(etiquette),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Useful Phrases (Tap to Hear)', Icons.translate_rounded, widget.color),
                  const SizedBox(height: 16),
                  ...phrases.map((p) => _buildPhraseCard(p)),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(List<String> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ', style: TextStyle(color: widget.color, fontSize: 18, fontWeight: FontWeight.bold)),
              Expanded(child: Text(e, style: GoogleFonts.poppins(fontSize: 14))),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildPhraseCard(Map<String, String> phrase) {
    return InkWell(
      onTap: () => _speak(phrase['local']!),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: widget.color.withAlpha(80)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phrase['english']!,
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phrase['local']!,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phrase['pronunciation']!,
                    style: GoogleFonts.poppins(fontSize: 13, fontStyle: FontStyle.italic, color: widget.color),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.color.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.volume_up_rounded, color: widget.color),
            )
          ],
        ),
      ),
    );
  }
}
