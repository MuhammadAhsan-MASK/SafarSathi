import 'package:flutter/material.dart';
import '../models/travel_news_model.dart';

class TravelNewsService {
  static List<TravelNewsItem> getLiveAdvisories() {
    final now = DateTime.now();

    return [
      TravelNewsItem(
        id: 'hunza',
        placeName: 'Hunza Valley & Khunjerab',
        region: 'Gilgit-Baltistan',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • All Clear',
        headline: 'Clear autumn weather in Central Hunza; KKH open and smooth for travel',
        fullNewsReport:
            'Gilgit-Baltistan administration and Tourism Police confirm that the Karakoram Highway (N-35) is fully clear and operational through Hassanabad, Aliabad, and Karimabad. Khunjerab Pass border area remains open during daytime hours; tourists must carry heavy thermal winter wear as temperatures drop sharply near the border.',
        currentTemp: 9,
        weatherCondition: 'Sunny & Crisp Autumn',
        weatherIcon: Icons.wb_sunny_rounded,
        feelsLike: 7,
        precipitationChance: '0%',
        windSpeed: '11 km/h',
        humidity: '38%',
        disasterAlert:
            'Zero active disaster or flood alerts. Landslide clearances completed at Attabad tunnels. Normal low seasonal river flow.',
        roadCondition:
            'Karakoram Highway (N-35) 100% open for all vehicles. Note: Babusar Pass is closed for winter, use KKH via Besham/Kohistan.',
        vehicleRecommendation: 'Standard Cars, Hiace Vans & 4x4 for off-road side valleys',
        emergencyHelpline: '1422',
        helplineName: 'GB Tourism Police & Rescue 1122',
        officialSource: 'Pakistan Met Department (PMD) & GBDMA',
        updatedAt: now.subtract(const Duration(minutes: 12)),
        imageUrl: 'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 9, condition: 'Sunny', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Mon', temp: 8, condition: 'Clear', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Tue', temp: 6, condition: 'Chilly', icon: Icons.ac_unit_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'skardu',
        placeName: 'Skardu & Deosai Plains',
        region: 'Gilgit-Baltistan',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • Flights Operating',
        headline: 'PIA & Airblue flights operating smoothly; Jaglot-Skardu road fully clear',
        fullNewsReport:
            'Civil Aviation Authority (CAA) reports clear visibility over Skardu valley with regular scheduled flights arriving from Islamabad and Karachi. Jaglot-Skardu Strategic Highway (S-1) is open for both-way traffic. Deosai National Park is closed to vehicular traffic due to high-altitude winter snow accumulation.',
        currentTemp: 6,
        weatherCondition: 'Partly Cloudy & Cold',
        weatherIcon: Icons.cloud_outlined,
        feelsLike: 4,
        precipitationChance: '5%',
        windSpeed: '14 km/h',
        humidity: '44%',
        disasterAlert:
            'Zero flood or earthquake threats. Indus and Shigar river channels at safe winter minimums.',
        roadCondition:
            'Jaglot-Skardu Highway (S-1) fully open. Shigar & Khaplu roads in excellent condition. Deosai plateau tracks closed for winter.',
        vehicleRecommendation: 'All cars to Skardu & Shigar; 4x4 mandatory for upper valleys',
        emergencyHelpline: '1129',
        helplineName: 'NDMA & Skardu District Emergency',
        officialSource: 'CAA Pakistan & Skardu District Administration',
        updatedAt: now.subtract(const Duration(minutes: 25)),
        imageUrl: 'https://images.unsplash.com/photo-1598890777032-bde835ba27c2?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 6, condition: 'Cloudy', icon: Icons.cloud_outlined),
          ForecastDay(dayName: 'Mon', temp: 5, condition: 'Chilly', icon: Icons.ac_unit_rounded),
          ForecastDay(dayName: 'Tue', temp: 3, condition: 'Snow Peak', icon: Icons.ac_unit_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'murree',
        placeName: 'Murree & Galiyat',
        region: 'Punjab / KP',
        safetyStatus: TravelSafetyStatus.caution,
        statusTitle: 'Travel with Caution • Fog & Frost Advisory',
        headline: 'Dense evening fog and road frost reported; snow chains advised for upper Galiyat',
        fullNewsReport:
            'City Traffic Police Murree and Rawalpindi Administration have issued a travel advisory for tourists visiting Murree, Patriata, and Nathiagali. Heavy fog reduces visibility below 50 meters between 9 PM and 7 AM. Motorists are urged to inspect anti-freeze coolant, tyre tread, and maintain safe following distances on Expressway N-75.',
        currentTemp: 11,
        weatherCondition: 'Misty & Overcast',
        weatherIcon: Icons.cloud_queue_rounded,
        feelsLike: 9,
        precipitationChance: '25%',
        windSpeed: '16 km/h',
        humidity: '72%',
        disasterAlert:
            'Road frost danger during late night and early dawn. Salt dispersal machinery placed on standby near Kashmir Point and Nathiagali.',
        roadCondition:
            'Murree Expressway (N-75) and Old Murree Road open. Speed limit capped at 40 km/h in misty sections.',
        vehicleRecommendation: 'Cars allowed; carry snow chains for Nathiagali and high elevations',
        emergencyHelpline: '051-9269200',
        helplineName: 'Murree Tourism Facilitation Center & Traffic Police',
        officialSource: 'Punjab Disaster Management Authority (PDMA)',
        updatedAt: now.subtract(const Duration(minutes: 8)),
        imageUrl: 'https://images.unsplash.com/photo-1605538032432-a9f0c0d9e504?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 11, condition: 'Misty', icon: Icons.cloud_queue_rounded),
          ForecastDay(dayName: 'Mon', temp: 10, condition: 'Drizzle', icon: Icons.grain_rounded),
          ForecastDay(dayName: 'Tue', temp: 8, condition: 'Cold Rain', icon: Icons.beach_access_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'babusar',
        placeName: 'Naran, Kaghan & Babusar Pass',
        region: 'Khyber Pakhtunkhwa',
        safetyStatus: TravelSafetyStatus.warning,
        statusTitle: 'Winter Closure Notice • High Pass Blocked',
        headline: 'Babusar Pass (13,700 ft) closed for winter season; Naran open with caution',
        fullNewsReport:
            'National Highway Authority (NHA) and District Administration Mansehra have officially closed Babusar Pass to all vehicular traffic following heavy snowfall and sub-zero ice sheets. Travelers destined for Gilgit, Hunza, or Skardu must use the Karakoram Highway via Besham and Kohistan. Naran bazaar remains accessible with winter precautions.',
        currentTemp: 2,
        weatherCondition: 'Freezing Overcast',
        weatherIcon: Icons.ac_unit_rounded,
        feelsLike: -3,
        precipitationChance: '60%',
        windSpeed: '22 km/h',
        humidity: '80%',
        disasterAlert:
            'High snow accumulation and avalanche hazard at Babusar Top and Gitidas. Extreme ice glaze on bridges beyond Kaghan town.',
        roadCondition:
            'Mansehra-Naran road open up to Naran. Babusar Pass closed until June 2027. Divert via KKH N-35.',
        vehicleRecommendation: '4x4 with snow chains only past Kaghan; regular cars not recommended',
        emergencyHelpline: '1129',
        helplineName: 'NDMA & Mansehra District Police',
        officialSource: 'National Highway Authority (NHA) & KPK PDMA',
        updatedAt: now.subtract(const Duration(minutes: 4)),
        imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 2, condition: 'Light Snow', icon: Icons.ac_unit_rounded),
          ForecastDay(dayName: 'Mon', temp: 0, condition: 'Snowfall', icon: Icons.ac_unit_rounded),
          ForecastDay(dayName: 'Tue', temp: -2, condition: 'Heavy Frost', icon: Icons.ac_unit_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'swat',
        placeName: 'Swat Valley & Malam Jabba',
        region: 'Khyber Pakhtunkhwa',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • All Clear',
        headline: 'Swat Motorway clear; Malam Jabba chairlift and tourist spots fully open',
        fullNewsReport:
            'KPK Tourism Police confirms optimal travel conditions across Mingora, Saidu Sharif, Malam Jabba, and Bahrain. River Swat flow is calm and safe. Tourists are visiting Malam Jabba for chairlift rides and zip-lining. Road widening between Bahrain and Kalam has significantly smoothed the drive.',
        currentTemp: 14,
        weatherCondition: 'Mild Sun & Pleasant',
        weatherIcon: Icons.wb_sunny_rounded,
        feelsLike: 14,
        precipitationChance: '5%',
        windSpeed: '9 km/h',
        humidity: '48%',
        disasterAlert:
            'Zero landslide or flood warnings. River Swat embankments operating well within safe seasonal levels.',
        roadCondition:
            'Swat Expressway (M-16) in immaculate condition. Mingora to Kalam road open for all cars.',
        vehicleRecommendation: 'All Sedans, Hatchbacks, Vans and 4x4 vehicles',
        emergencyHelpline: '1422',
        helplineName: 'KPK Tourism Police Helpline',
        officialSource: 'Khyber Pakhtunkhwa Tourism Department (KPTD)',
        updatedAt: now.subtract(const Duration(minutes: 32)),
        imageUrl: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 14, condition: 'Sunny', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Mon', temp: 13, condition: 'Clear', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Tue', temp: 11, condition: 'Chilly', icon: Icons.cloud_outlined),
        ],
      ),

      TravelNewsItem(
        id: 'neelum',
        placeName: 'Neelum Valley & Sharda',
        region: 'Azad Kashmir',
        safetyStatus: TravelSafetyStatus.caution,
        statusTitle: 'Travel with Caution • Evening Chill',
        headline: 'Neelum highway open to Sharda; tourists advised to book heated accommodations',
        fullNewsReport:
            'State Disaster Management Authority (SDMA AJK) reports clear roads along the Neelum Valley Highway from Muzaffarabad through Kundal Shahi, Athmuqam, to Sharda. Due to autumn-winter transition, nights are chilly and several wooden guest lodges operate wood-burners. Sharda to Kel track requires high-clearance jeeps.',
        currentTemp: 10,
        weatherCondition: 'Clear Autumn Day',
        weatherIcon: Icons.wb_sunny_outlined,
        feelsLike: 8,
        precipitationChance: '10%',
        windSpeed: '10 km/h',
        humidity: '52%',
        disasterAlert:
            'River Neelum running clear and tranquil. Occasional small stone falls between Keran and Dowarian cleared promptly.',
        roadCondition:
            'Muzaffarabad to Sharda fully open. Sharda to Kel and Arang Kel cable car operating normally.',
        vehicleRecommendation: 'Cars up to Sharda; 4x4 recommended for Kel and Taobat',
        emergencyHelpline: '1129',
        helplineName: 'SDMA AJK & Rescue 1122 Muzaffarabad',
        officialSource: 'AJK Tourism & State Disaster Management Authority',
        updatedAt: now.subtract(const Duration(minutes: 18)),
        imageUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 10, condition: 'Sunny', icon: Icons.wb_sunny_outlined),
          ForecastDay(dayName: 'Mon', temp: 9, condition: 'Overcast', icon: Icons.cloud_outlined),
          ForecastDay(dayName: 'Tue', temp: 7, condition: 'Cold Night', icon: Icons.ac_unit_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'gwadar',
        placeName: 'Gwadar & Makran Coastal Highway',
        region: 'Balochistan',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • Ideal Beach Weather',
        headline: 'Makran Coastal Highway (N-10) clear; mild coastal breezes across Princess of Hope',
        fullNewsReport:
            'Balochistan Coastal Development Authority and Coastal Highway Police report excellent driving conditions along the 653 km Makran Coastal Highway (N-10). Peak tourist season has commenced for Kund Malir Golden Beach, Buzi Pass, and Gwadar Marine Drive. Marine waters are calm with scuba and boat tours active at Astola Island.',
        currentTemp: 28,
        weatherCondition: 'Sunny & Coastal Breeze',
        weatherIcon: Icons.wb_sunny_rounded,
        feelsLike: 29,
        precipitationChance: '0%',
        windSpeed: '18 km/h',
        humidity: '58%',
        disasterAlert:
            'Zero marine cyclones or stormy weather. Coastal roads and bridges 100% stable and operational.',
        roadCondition:
            'Makran Coastal Highway (N-10) in pristine asphalt condition. Fuel stations active at Ormara and Pasni.',
        vehicleRecommendation: 'All vehicle types (Sedans, SUVs, Coaches, Motorcycles)',
        emergencyHelpline: '130',
        helplineName: 'National Highway & Motorway Police (NHMP)',
        officialSource: 'Balochistan Coastal Development Authority (BCDA)',
        updatedAt: now.subtract(const Duration(minutes: 40)),
        imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 28, condition: 'Sunny', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Mon', temp: 27, condition: 'Breezy', icon: Icons.air_rounded),
          ForecastDay(dayName: 'Tue', temp: 28, condition: 'Clear', icon: Icons.wb_sunny_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'lahore',
        placeName: 'Lahore & Central Punjab',
        region: 'Punjab',
        safetyStatus: TravelSafetyStatus.caution,
        statusTitle: 'Travel with Caution • Smog & Night Fog',
        headline: 'M-2 / M-3 Motorway night visibility alert; daylight travel recommended',
        fullNewsReport:
            'National Highway & Motorway Police (NHMP) and Punjab Environment Protection Department advise tourists and travelers to schedule intercity journeys between 9:00 AM and 6:00 PM. Late-night smog and fog patches reduce visibility on M-2 (Lahore-Islamabad) and M-3 (Lahore-Abdul Hakeem). In-city cultural spots like Badshahi Mosque and Lahore Fort remain open.',
        currentTemp: 22,
        weatherCondition: 'Hazy & Autumn Sun',
        weatherIcon: Icons.blur_on_rounded,
        feelsLike: 23,
        precipitationChance: '0%',
        windSpeed: '6 km/h',
        humidity: '65%',
        disasterAlert:
            'Air quality index elevated in central city. Fog advisory active for motorway travelers between 11 PM and 7 AM.',
        roadCondition:
            'GT Road (N-5) and Motorway M-2 open; speed limits adjusted during fog with police convoy pilots.',
        vehicleRecommendation: 'All vehicles; ensure functional fog lights and front defogger',
        emergencyHelpline: '130',
        helplineName: 'Motorway Police Help Centre',
        officialSource: 'Punjab PDMA & National Highway & Motorway Police',
        updatedAt: now.subtract(const Duration(minutes: 15)),
        imageUrl: 'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 22, condition: 'Hazy', icon: Icons.blur_on_rounded),
          ForecastDay(dayName: 'Mon', temp: 21, condition: 'Smoggy', icon: Icons.blur_on_rounded),
          ForecastDay(dayName: 'Tue', temp: 20, condition: 'Cool Sun', icon: Icons.wb_sunny_outlined),
        ],
      ),

      TravelNewsItem(
        id: 'chitral',
        placeName: 'Chitral & Kalash Valleys',
        region: 'Khyber Pakhtunkhwa',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • Lowari Tunnel 24/7 Open',
        headline: 'Lowari Tunnel open with zero delays; Kalash cultural valleys welcoming tourists',
        fullNewsReport:
            'District Administration Lower Chitral confirms the Lowari Tunnel (N-45) is fully ventilated and operating around the clock. The scenic valleys of Bumburet, Rumbur, and Birir are accessible with regular jeep services from Ayun. Autumn foliage in Chitral town is in full bloom with stable weather.',
        currentTemp: 12,
        weatherCondition: 'Clear & Crisp Mountain Air',
        weatherIcon: Icons.wb_sunny_rounded,
        feelsLike: 11,
        precipitationChance: '0%',
        windSpeed: '8 km/h',
        humidity: '40%',
        disasterAlert:
            'No flash floods or active mudslides. River Kunar at tranquil winter volume.',
        roadCondition:
            'Dir-Chitral N-45 fully metalled and open. Ayun to Bumburet road dry and accessible for 4x4 and cars.',
        vehicleRecommendation: 'All cars up to Chitral town; 4x4 recommended for Kalash Valleys',
        emergencyHelpline: '1122',
        helplineName: 'Rescue 1122 Lower Chitral & Tourism Desk',
        officialSource: 'KPK Tourism Department & District Administration Chitral',
        updatedAt: now.subtract(const Duration(minutes: 48)),
        imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 12, condition: 'Sunny', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Mon', temp: 11, condition: 'Clear', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Tue', temp: 9, condition: 'Chilly', icon: Icons.ac_unit_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'ziarat',
        placeName: 'Ziarat & Quetta Valley',
        region: 'Balochistan',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • All Clear',
        headline: 'Ziarat Juniper forest highway clear; Quaid Residency open for tourists',
        fullNewsReport:
            'Balochistan Tourism and Levies Force report calm and safe travel conditions across the Quetta-Ziarat corridor. Tourists are visiting the historic Quaid-e-Azam Residency, Prospect Point, and Chashma Walk. Night temperatures are brisk (near 2°C), and tourists are advised to carry adequate thermal clothing.',
        currentTemp: 13,
        weatherCondition: 'Crisp Dry Sun',
        weatherIcon: Icons.wb_sunny_outlined,
        feelsLike: 11,
        precipitationChance: '0%',
        windSpeed: '12 km/h',
        humidity: '28%',
        disasterAlert:
            'Zero flood or earthquake threats. Dry, clear road surfaces throughout the valley.',
        roadCondition:
            'Quetta-Ziarat Highway newly carpeted, well-signposted, and clear of traffic hurdles.',
        vehicleRecommendation: 'All cars, SUVs, and commuter coasters',
        emergencyHelpline: '1129',
        helplineName: 'PDMA Balochistan & Ziarat Levies Control',
        officialSource: 'PDMA Balochistan & Ziarat District Administration',
        updatedAt: now.subtract(const Duration(minutes: 55)),
        imageUrl: 'https://images.unsplash.com/photo-1511497584788-87676104235f?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 13, condition: 'Sunny', icon: Icons.wb_sunny_outlined),
          ForecastDay(dayName: 'Mon', temp: 12, condition: 'Dry Sun', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Tue', temp: 10, condition: 'Cold Night', icon: Icons.ac_unit_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'kumrat',
        placeName: 'Kumrat Valley & Dir Kohistan',
        region: 'Khyber Pakhtunkhwa',
        safetyStatus: TravelSafetyStatus.caution,
        statusTitle: 'Travel with Caution • 4x4 Required Past Thal',
        headline: 'Dir to Thal road open; Kumrat pine forest requires 4x4 jeep due to seasonal terrain',
        fullNewsReport:
            'Upper Dir Administration confirms passenger cars can comfortably reach Thal bazaar. For onward travel to the iconic Kumrat pine forests and Kala Chashma, local 4x4 jeeps are operating at fixed union rates. Riverside camping pods offer hot water and heating facilities.',
        currentTemp: 7,
        weatherCondition: 'Overcast & Cold',
        weatherIcon: Icons.cloud_outlined,
        feelsLike: 5,
        precipitationChance: '15%',
        windSpeed: '10 km/h',
        humidity: '62%',
        disasterAlert:
            'Panjkora river flowing at normal safe autumn levels. Zero flash flood warning.',
        roadCondition:
            'Dir-Thal road asphalted. Thal to Kumrat forest is an unpaved, rocky track suitable only for 4x4.',
        vehicleRecommendation: 'Cars up to Thal; 4x4 mandatory for Kumrat Valley',
        emergencyHelpline: '1122',
        helplineName: 'Rescue 1122 Upper Dir',
        officialSource: 'District Administration Upper Dir & Rescue 1122',
        updatedAt: now.subtract(const Duration(minutes: 20)),
        imageUrl: 'https://images.unsplash.com/photo-1448375240586-882707db888b?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 7, condition: 'Overcast', icon: Icons.cloud_outlined),
          ForecastDay(dayName: 'Mon', temp: 6, condition: 'Chilly', icon: Icons.ac_unit_rounded),
          ForecastDay(dayName: 'Tue', temp: 4, condition: 'Cold Rain', icon: Icons.grain_rounded),
        ],
      ),

      TravelNewsItem(
        id: 'islamabad',
        placeName: 'Islamabad & Margalla Hills',
        region: 'Federal Capital',
        safetyStatus: TravelSafetyStatus.safe,
        statusTitle: 'Safe to Travel • All Clear',
        headline: 'Margalla trails and Daman-e-Koh fully open; mild autumn weather prevailing',
        fullNewsReport:
            'Islamabad Wildlife Management Board and Islamabad Traffic Police report excellent travel and hiking conditions across Trail 3, Trail 5, Daman-e-Koh, and Monal Pir Sohawa. City highways including Islamabad Expressway and Srinagar Highway are operating with smooth traffic flow.',
        currentTemp: 19,
        weatherCondition: 'Clear & Crisp Sun',
        weatherIcon: Icons.wb_sunny_rounded,
        feelsLike: 19,
        precipitationChance: '0%',
        windSpeed: '8 km/h',
        humidity: '45%',
        disasterAlert:
            'Zero natural hazard warnings. Margalla hill trails inspected and declared 100% safe.',
        roadCondition:
            'All city avenues and hill climbs in pristine paved condition.',
        vehicleRecommendation: 'All vehicle types',
        emergencyHelpline: '1915',
        helplineName: 'Islamabad Traffic Police & Emergency Helpline',
        officialSource: 'Capital Development Authority (CDA) & PMD',
        updatedAt: now.subtract(const Duration(minutes: 10)),
        imageUrl: 'https://images.unsplash.com/photo-1548013146-72479768bada?w=600&auto=format&fit=crop&q=80',
        forecast: const [
          ForecastDay(dayName: 'Sun', temp: 19, condition: 'Sunny', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Mon', temp: 18, condition: 'Clear', icon: Icons.wb_sunny_rounded),
          ForecastDay(dayName: 'Tue', temp: 17, condition: 'Pleasant', icon: Icons.wb_sunny_outlined),
        ],
      ),
    ];
  }
}
