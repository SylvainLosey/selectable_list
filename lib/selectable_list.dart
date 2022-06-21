library selectable_list;

import 'package:flutter/widgets.dart';

/// A widget displaying a selectable [List] of items.
///
/// When one of the items is selected, the other elements of the list are
/// animated out, leaving the selected value. When tapping on the value again,
/// the other values are animated back into the list.
///
/// Should be typed with first (E) the type of [items], second (V) the type
/// of [selectedValue]
///
/// Based on [AnimatedList]
class SelectableList<E, V> extends StatefulWidget {
  /// The items must be comparable (two different instance with the same value
  /// must return true). Either:
  ///
  /// 1. Override the == operator and hashCode. This can be done easily with
  /// packages such as Equatable: https://pub.dev/packages/equatable
  ///
  /// 2. Use const instances of the items (mark the name field as final, add
  /// const to the constructor definition and the calls to it)
  final List<E> items;

  /// The builder converting one item to a [Widget] representing it. The builder
  /// function exposes the item, wheter it is currently selected, and an onTap
  /// callback which should be passed to the widget which will be responsible
  /// of invoking the callback
  final Widget Function(
          BuildContext context, E item, bool selected, void Function()? onTap)
      itemBuilder;

  /// The currently selected value. Should be stored in a StatefulWidget or
  /// another state management solution
  final V selectedValue;

  /// Callback invoked when an item is selected, should be used to set the state
  /// of the [selectedValue]
  final void Function(E item) onItemSelected;

  /// Callback invoked when an item is deselected, should be used to set the
  /// state of [selectedValue] to null
  final void Function(E item) onItemDeselected;

  /// A function that can convert the item into the [selectedValue].
  /// Useful when items are a class and [selectedValue] is a field of that class
  final V Function(E item)? valueSelector;

  final Duration? animationDuration;

  const SelectableList(
      {super.key,
      required this.items,
      required this.itemBuilder,
      required this.selectedValue,
      required this.onItemSelected,
      required this.onItemDeselected,
      this.valueSelector,
      this.animationDuration});

  @override
  State<SelectableList<E, V>> createState() => _SelectableListState<E, V>();
}

class _SelectableListState<E, V> extends State<SelectableList<E, V>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late _ListModel<E> _displayedItems;

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _displayedItems.length,
      itemBuilder: _buildItem,
      shrinkWrap: true,
    );
  }

  @override
  void initState() {
    super.initState();

    _displayedItems = _ListModel<E>(
        listKey: _listKey,
        items: widget.selectedValue == null
            ? widget.items
            : [
                widget.items.firstWhere(
                    (e) => _valueSelector(e) == widget.selectedValue)
              ],
        removedItemBuilder: _buildRemovedItem,
        animationDuration: widget.animationDuration);
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    final currentItem = _displayedItems[index];
    final selected = widget.selectedValue == _valueSelector(currentItem);

    return _SelectableItem(
        animation: animation,
        child: widget.itemBuilder(context, currentItem, selected, () {
          if (widget.selectedValue != _valueSelector(currentItem)) {
            widget.onItemSelected(currentItem);

            for (var elem in widget.items) {
              if (_valueSelector(elem) != _valueSelector(currentItem)) {
                _remove(elem);
              }
            }
          } else {
            widget.onItemDeselected(currentItem);

            for (var elem in widget.items) {
              if (!_displayedItems.contains(elem)) {
                _insert(widget.items.indexOf(elem), elem);
              }
            }
          }
        }));
  }

  Widget _buildRemovedItem(
      E item, BuildContext context, Animation<double> animation) {
    final selected = widget.selectedValue == _valueSelector(item);

    return _SelectableItem(
      animation: animation,
      child: widget.itemBuilder(context, item, selected, null),
    );
  }

  void _insert(int index, item) {
    _displayedItems.insert(index, item);
  }

  void _remove(item) {
    _displayedItems.removeAt(_displayedItems.indexOf(item));
  }

  V _valueSelector(E item) {
    if (widget.valueSelector != null) return widget.valueSelector!(item);
    return item as V;
  }
}

class _SelectableItem extends StatelessWidget {
  const _SelectableItem({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(sizeFactor: animation, child: child);
  }
}

/// Keeps a Dart [List] in sync with an [AnimatedList].
///
/// The [insert] and [removeAt] methods apply to both the internal list and
/// the animated list that belongs to [listKey].
///
/// This class only exposes as much of the Dart List API as is needed by the
/// sample app. More list methods are easily added, however methods that
/// mutate the list must make the same changes to the animated list in terms
/// of [AnimatedListState.insertItem] and [AnimatedList.removeItem].
///
/// From https://api.flutter.dev/flutter/widgets/AnimatedList-class.html
class _ListModel<E> {
  _ListModel(
      {required this.listKey,
      required this.removedItemBuilder,
      required Iterable<E> items,
      this.animationDuration})
      : _items = List<E>.from(items);

  final GlobalKey<AnimatedListState> listKey;
  final Function removedItemBuilder;
  final List<E> _items;
  final Duration? animationDuration;

  final kDefaultDuration = const Duration(milliseconds: 200);

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList!.insertItem(
      index,
      duration: animationDuration ?? kDefaultDuration,
    );
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList!.removeItem(
        index,
        duration: animationDuration ?? kDefaultDuration,
        (BuildContext context, Animation<double> animation) {
          return removedItemBuilder(removedItem, context, animation);
        },
      );
    }

    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) {
    final index = _items.indexOf(item);
    if (index < 0) {
      throw Exception(
          """The items of SelectableList are not comparable. You can:
      1. Override the == operator and hashCode. This can be done easily with packages such as Equatable: https://pub.dev/packages/equatable
      2. Use const instances of the items (mark the name field as final, add const to the constructor definition and the calls to it)
    """);
    }
    return index;
  }

  bool contains(E item) => _items.contains(item);
}
