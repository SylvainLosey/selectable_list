import 'package:flutter/material.dart';
import 'package:selectable_list/selectable_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final persons = [
    Person("Ella", 3),
    Person("James", 25),
    Person("Gertrude", 99)
  ];

  String? selectedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selectable list example")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SelectableList<Person, String?>(
          items: persons,
          itemBuilder: (context, person, selected, onTap) => ListTile(
              title: Text(person.name),
              subtitle: Text('${person.age.toString()} years old'),
              selected: selected,
              onTap: onTap),
          valueSelector: (person) => person.name,
          selectedValue: selectedName,
          onItemSelected: (person) =>
              setState(() => selectedName = person.name),
          onItemDeselected: (person) => setState(() => selectedName = null),
        ),
      ),
    );
  }
}

class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}
