class CulturalCalendar {
  static final Map<int, List<String>> _monthlyEvents = {
    1: ["Winter Sports Festival (Malam Jabba)"],
    2: ["National Spring Festival (Lahore)"],
    3: ["Pakistan Day Parade (Islamabad)", "Spring Blossom (Hunza/Skardu)"],
    4: ["Baisakhi (Hasanabdal)"],
    5: ["Chilam Joshi Festival (Kalash Valley)"],
    6: ["Summer Festivals (Northern Areas)"],
    7: ["Shandur Polo Festival (Shandur Pass, Gilgit-Chitral)"],
    8: ["Uchal Festival (Kalash)"],
    9: ["Silk Route Festival (Nagar/Hunza)"],
    10: ["Autumn Colors (Gilgit-Baltistan)"],
    11: ["Lok Mela (Islamabad)"],
    12: ["Choimus Festival (Kalash)"],
  };

  static String getEventsForMonth(int month) {
    if (_monthlyEvents.containsKey(month) && _monthlyEvents[month]!.isNotEmpty) {
      return _monthlyEvents[month]!.join(", ");
    }
    return "Focus on scenic beauty and local cuisine.";
  }
  
  static String getCurrentMonthEvents() {
    return getEventsForMonth(DateTime.now().month);
  }
}
