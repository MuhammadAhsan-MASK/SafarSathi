import 'package:flutter_test/flutter_test.dart';
import 'package:travel_guide/features/budget/models/group_expense_model.dart';

void main() {
  group('Group Expense Splitter Tests', () {
    final splitService = GroupSplitService();

    test('Equal split between 3 people', () {
      final p1 = Person(id: '1', name: 'Ahsan');
      final p2 = Person(id: '2', name: 'Ali');
      final p3 = Person(id: '3', name: 'Bilal');
      final people = [p1, p2, p3];

      final expense = GroupExpense(
        id: 'e1',
        description: 'Dinner',
        amount: 3000,
        paidBy: p1,
        splitAmong: [p1, p2, p3],
      );

      final settlements = splitService.calculateSettlements(people, [expense]);
      
      // Each person should pay 1000. Ahsan paid 3000, so he paid 2000 extra.
      // Ali owes Ahsan 1000. Bilal owes Ahsan 1000.
      expect(settlements.length, 2);
      
      bool aliSettled = settlements.any((s) => s.fromPerson.id == '2' && s.toPerson.id == '1' && (s.amount - 1000.0).abs() < 0.01);
      bool bilalSettled = settlements.any((s) => s.fromPerson.id == '3' && s.toPerson.id == '1' && (s.amount - 1000.0).abs() < 0.01);
      
      expect(aliSettled, true);
      expect(bilalSettled, true);
    });

    test('No one owes anything', () {
      final p1 = Person(id: '1', name: 'Ahsan');
      final p2 = Person(id: '2', name: 'Ali');
      final people = [p1, p2];

      final expense1 = GroupExpense(
        id: 'e1',
        description: 'Dinner',
        amount: 1000,
        paidBy: p1,
        splitAmong: [p1, p2],
      );

      final expense2 = GroupExpense(
        id: 'e2',
        description: 'Breakfast',
        amount: 1000,
        paidBy: p2,
        splitAmong: [p1, p2],
      );

      final settlements = splitService.calculateSettlements(people, [expense1, expense2]);
      
      expect(settlements.length, 0); // Completely settled out
    });
  });
}
