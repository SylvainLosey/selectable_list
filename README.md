<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A widget displaying a selectable [List] of items. When one of the items is selected, 
the other elements of the list are animated out, leaving the selected value. 
When tapping on the value again, the other values are animated back into the list.

![Example app](https://s8.gifyu.com/images/ezgif.com-gif-maker46941615186e1f54.gif)

## Features

- Use this plugin when you want to allow the user to choose one element in a list, 
and only show this element when selected. This is useful in forms for example.

- Based on the AnimatedList widget

## Usage

```dart
class _ScrollableListExampleState extends State<_ScrollableListExample> {
  final persons = [
    Person("Ella", 3),
    Person("James", 25),
    Person("Gertrude", 99)
  ];

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
        onItemSelected: (person) =>
            setState(() => selectedName = person.name),
        onItemDeselected: (person) => setState(() => selectedName = null),
    ),
  }
}

```

Check the example folder for more details
