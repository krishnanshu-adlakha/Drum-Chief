import 'dart:math';

import 'package:flutter/material.dart';

//2,4,8,16,32

class FixedNumberPicker extends StatefulWidget {
  /// Selected value for Start position - #initialValue cant be bigger than #maxValue and cant be smaller than #minValue
  final int initialValue;

  /// Min value user can pick - #minValue cant be bigger than #initialValue amd #maxValue
  final int minValue;

  /// Max value user can pick
  final int maxValue;

  /// if user interaction picker this methods return selected value
  final ValueChanged<int> onChanged;

  /// Direction of scrolling.
  final Axis? axis;

  /// height and width of single item for vertical.
  final double? size;

  /// Decoration to apply to picked number where the selected value is placed
  final BoxDecoration? pickedItemDecoration;

  /// Decoration to apply non-picked numbers
  final BoxDecoration? otherItemsDecoration;

  /// Style of picked number. If null, it uses Theme's headline5 with primaryColor
  final TextStyle? pickedItemTextStyle;

  /// Style of non-picked numbers. If null, it uses Theme's bodyText2
  final TextStyle? otherItemsTextStyle;

  final List<int> items;
  final int selectedItem;

  const FixedNumberPicker({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.items,
    required this.selectedItem,
    this.axis,
    this.size,
    this.pickedItemDecoration,
    this.otherItemsDecoration,
    this.pickedItemTextStyle,
    this.otherItemsTextStyle,
  })  : assert(initialValue < maxValue),
        assert(initialValue >= minValue),
        assert(minValue < maxValue);

  @override
  State<FixedNumberPicker> createState() => _IntegerNumberPickerState();
}

class _IntegerNumberPickerState extends State<FixedNumberPicker> {
  late FixedExtentScrollController _controller;
  late int returnValue;
  

  @override
  void initState() {
    super.initState();
    returnValue = widget.items.indexOf(widget.selectedItem);
    _controller = FixedExtentScrollController(initialItem: returnValue);
  }

  @override
  Widget build(BuildContext context) {
    final pickedItemStyle = BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor, width: 3),
        borderRadius: const BorderRadius.all(Radius.circular(360)));

    final otherItemsStyle = BoxDecoration(
        border: Border.all(color: Theme.of(context).unselectedWidgetColor),
        borderRadius: const BorderRadius.all(Radius.circular(360)));

    final pickedItemTextStyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(color: Theme.of(context).primaryColor);
    final otherItemsTextStyle = Theme.of(context)
        .textTheme
        .titleSmall!
        .copyWith(color: Theme.of(context).unselectedWidgetColor);

    return Transform.rotate(
      angle: widget.axis == Axis.vertical || widget.axis == null ? 0 : -pi / 2,
      child: ListWheelScrollView.useDelegate(
        controller: _controller,
        onSelectedItemChanged: ((value) {
          widget.onChanged(widget.items[value]);
          setState(() {
            returnValue = value;
          });
        }),
        physics: const BouncingScrollPhysics(),
        perspective: 0.01,
        itemExtent: widget.size ?? 40,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: widget.items.length,
          builder: (c, i) => i == returnValue
              ? Container(
                  width: widget.size ?? 40,
                  decoration: widget.pickedItemDecoration ?? pickedItemStyle,
                  child: Transform.rotate(
                    angle: widget.axis == Axis.vertical || widget.axis == null
                        ? 0
                        : pi / 2,
                    child: Center(
                      child: Text((widget.items[i]).toString(),
                          style: widget.pickedItemTextStyle ??
                              pickedItemTextStyle),
                    ),
                  ),
                )
              : Container(
                  width: widget.size ?? 40,
                  decoration: widget.otherItemsDecoration ?? otherItemsStyle,
                  child: Transform.rotate(
                    angle: widget.axis == Axis.vertical || widget.axis == null
                        ? 0
                        : pi / 2,
                    child: Center(
                      child: Text(
                        (widget.items[i]).toString(),
                        style:
                            widget.otherItemsTextStyle ?? otherItemsTextStyle,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
