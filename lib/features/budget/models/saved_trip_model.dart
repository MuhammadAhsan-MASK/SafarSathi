import 'dart:convert';

class SavedTrip {
  final String id;
  final String title;
  final String destination;
  final String origin;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int travelers;
  final List<String> companions;
  final String? notes;
  final bool isCurrent;

  SavedTrip({
    required this.id,
    required this.title,
    required this.destination,
    this.origin = 'Islamabad',
    required this.startDate,
    required this.endDate,
    this.budget = 50000,
    this.travelers = 3,
    this.companions = const ['Ali', 'Hamza', 'Ahsan'],
    this.notes,
    this.isCurrent = false,
  });

  int get durationDays {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff + 1;
  }

  SavedTrip copyWith({
    String? id,
    String? title,
    String? destination,
    String? origin,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    int? travelers,
    List<String>? companions,
    String? notes,
    bool? isCurrent,
  }) {
    return SavedTrip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      origin: origin ?? this.origin,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      travelers: travelers ?? this.travelers,
      companions: companions ?? this.companions,
      notes: notes ?? this.notes,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'origin': origin,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budget': budget,
      'travelers': travelers,
      'companions': companions,
      'notes': notes,
      'isCurrent': isCurrent,
    };
  }

  factory SavedTrip.fromMap(Map<String, dynamic> map) {
    return SavedTrip(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Trip to ${map['destination'] ?? 'Pakistan'}',
      destination: map['destination'] ?? 'Murree',
      origin: map['origin'] ?? 'Islamabad',
      startDate: DateTime.tryParse(map['startDate'] ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(map['endDate'] ?? '') ?? DateTime.now().add(const Duration(days: 3)),
      budget: (map['budget'] ?? 50000).toDouble(),
      travelers: (map['travelers'] ?? 3).toInt(),
      companions: List<String>.from(map['companions'] ?? ['Ali', 'Hamza', 'Ahsan']),
      notes: map['notes'],
      isCurrent: map['isCurrent'] ?? false,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory SavedTrip.fromJson(String source) => SavedTrip.fromMap(jsonDecode(source));
}
