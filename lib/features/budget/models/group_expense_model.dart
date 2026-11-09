class Person {
  final String id;
  final String name;

  Person({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Person.fromMap(Map<String, dynamic> map) => Person(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class GroupExpense {
  final String id;
  final String description;
  final double amount;
  final Person paidBy;
  final List<Person> splitAmong;
  final String category;
  final DateTime date;

  GroupExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    this.category = 'General',
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'description': description,
        'amount': amount,
        'paidBy': paidBy.toMap(),
        'splitAmong': splitAmong.map((p) => p.toMap()).toList(),
        'category': category,
        'date': date.toIso8601String(),
      };

  factory GroupExpense.fromMap(Map<String, dynamic> map) {
    return GroupExpense(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paidBy: Person.fromMap(Map<String, dynamic>.from(map['paidBy'] ?? {})),
      splitAmong: (map['splitAmong'] as List<dynamic>? ?? [])
          .map((p) => Person.fromMap(Map<String, dynamic>.from(p)))
          .toList(),
      category: map['category'] ?? 'General',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}

class Settlement {
  final Person fromPerson;
  final Person toPerson;
  final double amount;
  bool isSettled;

  Settlement({
    required this.fromPerson,
    required this.toPerson,
    required this.amount,
    this.isSettled = false,
  });

  Map<String, dynamic> toMap() => {
        'from': fromPerson.toMap(),
        'to': toPerson.toMap(),
        'amount': amount,
        'isSettled': isSettled,
      };

  factory Settlement.fromMap(Map<String, dynamic> map) => Settlement(
        fromPerson: Person.fromMap(Map<String, dynamic>.from(map['from'] ?? {})),
        toPerson: Person.fromMap(Map<String, dynamic>.from(map['to'] ?? {})),
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        isSettled: map['isSettled'] ?? false,
      );
}

class GroupSplitService {
  List<Settlement> calculateSettlements(List<Person> people, List<GroupExpense> expenses) {
    final Map<String, double> balances = {for (var p in people) p.id: 0.0};

    for (var expense in expenses) {
      if (!balances.containsKey(expense.paidBy.id)) continue;

      // Credited to the person who paid
      balances[expense.paidBy.id] = (balances[expense.paidBy.id] ?? 0.0) + expense.amount;

      // Debited equally among the designated split members
      if (expense.splitAmong.isNotEmpty) {
        double splitAmount = expense.amount / expense.splitAmong.length;
        for (var person in expense.splitAmong) {
          if (balances.containsKey(person.id)) {
            balances[person.id] = (balances[person.id] ?? 0.0) - splitAmount;
          }
        }
      }
    }

    // Separate into debtors and creditors
    List<MapEntry<String, double>> debtors = balances.entries.where((e) => e.value < -0.01).toList();
    List<MapEntry<String, double>> creditors = balances.entries.where((e) => e.value > 0.01).toList();

    debtors.sort((a, b) => a.value.compareTo(b.value)); // Most negative first
    creditors.sort((a, b) => b.value.compareTo(a.value)); // Highest positive first

    List<Settlement> settlements = [];
    int i = 0;
    int j = 0;

    // Work on local copies
    final debtorBalances = debtors.map((e) => MapEntry(e.key, -e.value)).toList();
    final creditorBalances = creditors.map((e) => MapEntry(e.key, e.value)).toList();

    while (i < debtorBalances.length && j < creditorBalances.length) {
      String debtorId = debtorBalances[i].key;
      double debtAmount = debtorBalances[i].value;

      String creditorId = creditorBalances[j].key;
      double creditAmount = creditorBalances[j].value;

      double settledAmount = debtAmount < creditAmount ? debtAmount : creditAmount;

      Person? fromP = people.where((p) => p.id == debtorId).firstOrNull;
      Person? toP = people.where((p) => p.id == creditorId).firstOrNull;

      if (fromP != null && toP != null && settledAmount > 0.01) {
        settlements.add(Settlement(
          fromPerson: fromP,
          toPerson: toP,
          amount: settledAmount,
        ));
      }

      debtorBalances[i] = MapEntry(debtorId, debtAmount - settledAmount);
      creditorBalances[j] = MapEntry(creditorId, creditAmount - settledAmount);

      if (debtorBalances[i].value < 0.01) i++;
      if (creditorBalances[j].value < 0.01) j++;
    }

    return settlements;
  }
}
