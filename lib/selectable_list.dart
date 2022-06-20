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
/// Base on [AnimatedList]
class SelectableList<E, V> extends StatefulWidget {
  /// The items to display
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

  /// A function responsible for converting the item into the [selectedValue].
  /// If they are the same, the function can simply return the received item
  final V Function(E item) valueSelector;

  /// Callback invoked when an item is selected, should be used to set the state
  /// of the [selectedValue]
  final void Function(E item) onItemSelected;

  /// Callback invoked when an item is deselected, should be used to set the
  /// state of [selectedValue] to null
  final void Function(E item) onItemDeselected;

  final Duration? animationDuration;

  const SelectableList(
      {super.key,
      required this.items,
      required this.itemBuilder,
      required this.valueSelector,
      required this.selectedValue,
      required this.onItemSelected,
      required this.onItemDeselected,
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
                    (e) => widget.valueSelector(e) == widget.selectedValue)
              ],
        removedItemBuilder: _buildRemovedItem,
        animationDuration: widget.animationDuration);
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    final currentItem = _displayedItems[index];
    final selected = widget.selectedValue == widget.valueSelector(currentItem);

    return _SelectableItem(
        animation: animation,
        child: widget.itemBuilder(context, currentItem, selected, () {
          if (widget.selectedValue != widget.valueSelector(currentItem)) {
            widget.onItemSelected(currentItem);

            for (var elem in widget.items) {
              if (widget.valueSelector(elem) !=
                  widget.valueSelector(currentItem)) {
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
    final selected = widget.selectedValue == widget.valueSelector(item);

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

  int indexOf(E item) => _items.indexOf(item);

  bool contains(E item) => _items.contains(item);
}
