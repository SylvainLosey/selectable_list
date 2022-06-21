import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selectable_list/selectable_list.dart';

class SelectableListExample extends StatefulWidget {
  const SelectableListExample({super.key});
  @override
  State<SelectableListExample> createState() => _SelectableListExampleState();
}

class _SelectableListExampleState extends State<SelectableListExample> {
  String? selectedName;

  @override
  Widget build(BuildContext context) {
    return SelectableList<Person, String?>(
      items: persons,
      itemBuilder: (context, person, selected, onTap) => ListTile(
          title: Text(person.name),
          subtitle: Text('${person.age.toString()} years old'),
          selected: selected,
          onTap: onTap),
      valueSelector: (person) => person.name,
      selectedValue: selectedName,
      onItemSelected: (person) => setState(() => selectedName = person.name),
      onItemDeselected: (person) => setState(() => selectedName = null),
    );
  }
}

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}

final persons = [
  Person("Ella", 3),
  Person("James", 25),
  Person("Gertrude", 99)
];

void main() {
  testWidgets('List displays the items once', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SelectableListExample())));
    for (var person in persons) {
      expect(find.text(person.name), findsOneWidget);
    }
  });

  testWidgets('When an item is selected the others disappear', (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SelectableListExample())));
    final firstItem = find.text(persons.first.name);
    expect(firstItem, findsOneWidget);
    await tester.tap(firstItem);
    await tester.pumpAndSettle();

    expect(firstItem, findsOneWidget);
    expect(find.text(persons[1].name), findsNothing);
    expect(find.text(persons[2].name), findsNothing);
  });

  testWidgets('When a selected item is tapped the original items are back',
      (tester) async {
    await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SelectableListExample())));
    final firstItem = find.text(persons.first.name);
    expect(firstItem, findsOneWidget);

    // Tap a first time to select
    await tester.tap(firstItem);
    await tester.pumpAndSettle();

    // Tap again on the selected value, the other values should reappear
    await tester.tap(firstItem);
    await tester.pumpAndSettle();
    for (var person in persons) {
      expect(find.text(person.name), findsOneWidget);
    }
  });
}
