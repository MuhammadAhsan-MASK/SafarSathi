class Person {
  final String id;
  final String name;

  Person({required this.id, required this.name});

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

  GroupExpense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
  });
}

class Settlement {
  final Person fromPerson;
  final Person toPerson;
  final double amount;

  Settlement({
    required this.fromPerson,
    required this.toPerson,
    required this.amount,
  });
}

class GroupSplitService {
  List<Settlement> calculateSettlements(List<Person> people, List<GroupExpense> expenses) {
    // Map to keep track of each person's net balance
    // Positive balance means the person is owed money
    // Negative balance means the person owes money
    final Map<String, double> balances = { for (var p in people) p.id : 0.0 };

    for (var expense in expenses) {
      if (!balances.containsKey(expense.paidBy.id)) continue;
      
      // The person who paid getting credited
      balances[expense.paidBy.id] = (balances[expense.paidBy.id] ?? 0.0) + expense.amount;

      // The cost gets split among the participants
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

    // Sort to potentially settle largest amounts first
    debtors.sort((a, b) => a.value.compareTo(b.value)); // Lowest (most negative) first
    creditors.sort((a, b) => b.value.compareTo(a.value)); // Highest positive first

    List<Settlement> settlements = [];
    int i = 0; // Debtor index
    int j = 0; // Creditor index

    while (i < debtors.length && j < creditors.length) {
      String debtorId = debtors[i].key;
      double debtAmount = -debtors[i].value;

      String creditorId = creditors[j].key;
      double creditAmount = creditors[j].value;

      double settledAmount = debtAmount < creditAmount ? debtAmount : creditAmount;

      Person? fromP = people.where((p) => p.id == debtorId).firstOrNull;
      Person? toP = people.where((p) => p.id == creditorId).firstOrNull;

      if (fromP != null && toP != null) {
        settlements.add(Settlement(
          fromPerson: fromP,
          toPerson: toP,
          amount: settledAmount,
        ));
      }

      debtors[i] = MapEntry(debtors[i].key, -(debtAmount - settledAmount));
      creditors[j] = MapEntry(creditors[j].key, creditAmount - settledAmount);

      if (-debtors[i].value < 0.01) i++;
      if (creditors[j].value < 0.01) j++;
    }

    return settlements;
  }
}
