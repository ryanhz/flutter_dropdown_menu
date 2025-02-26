import 'package:flutter/material.dart';

import 'package:dropdown_menu/_src/drapdown_common.dart';

typedef DropdownMenuHeadTapCallback = void Function(int index);

typedef GetItemLabel<T> = String? Function(T data);

String? defaultGetItemLabel<T>(T data) {
  if (data is String) return data;
  return (data as Map)["title"];
}

class DropdownHeader<T> extends DropdownWidget {
  final List<T> titles;
  final int? activeIndex;
  final DropdownMenuHeadTapCallback? onTap;
  final int maxLines;

  final TextOverflow overflow;

  final bool showLeftLine;

  /// height of menu
  final double height;

  /// get label callback
  final GetItemLabel<T> getItemLabel;

  DropdownHeader(
      {super.key,
      super.controller,
      required this.titles,
      this.activeIndex,
      this.onTap,
      this.height = 46.0,
      this.maxLines = 1,
      this.overflow = TextOverflow.ellipsis,
      this.showLeftLine = true,
      GetItemLabel? getItemLabel})
      : getItemLabel = getItemLabel ?? defaultGetItemLabel,
        assert(titles.isNotEmpty);

  @override
  DropdownState<DropdownWidget> createState() {
    return _DropdownHeaderState();
  }
}

class _DropdownHeaderState<T> extends DropdownState<DropdownHeader<T>> {
  Widget buildItem(BuildContext context, T title, bool selected, int index) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color unselectedColor = Theme.of(context).unselectedWidgetColor;
    final GetItemLabel<T> getItemLabel = widget.getItemLabel;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
        child: DecoratedBox(
          decoration: BoxDecoration(
              border: Border(
                  left: widget.showLeftLine
                      ? Divider.createBorderSide(context)
                      : BorderSide.none)),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    getItemLabel(title)!,
                    style: TextStyle(
                      color: selected ? primaryColor : unselectedColor,
                    ),
                    maxLines: widget.maxLines,
                    overflow: widget.overflow,
                  ),
                ),
                Icon(
                  selected ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: selected ? primaryColor : unselectedColor,
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!(index);

          return;
        }
        if (controller != null) {
          if (_activeIndex == index) {
            controller!.hide();
            setState(() {
              _activeIndex = null;
            });
          } else {
            controller!.show(index);
          }
        }
        //widget.onTap(index);
      },
    );
  }

  int? _activeIndex;
  late List<T> _titles;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    final int? activeIndex = _activeIndex;
    final List<T> titles = _titles;
    final double height = widget.height;

    for (int i = 0, c = widget.titles.length; i < c; ++i) {
      list.add(buildItem(context, titles[i], i == activeIndex, i));
    }

    list = list.map((Widget widget) {
      return Expanded(
        child: widget,
      );
    }).toList();

    final Decoration decoration = BoxDecoration(
      border: Border(
        bottom: Divider.createBorderSide(context),
      ),
    );

    return DecoratedBox(
      decoration: decoration,
      child: SizedBox(
          height: height,
          child: Row(
            children: list,
          )),
    );
  }

  @override
  void initState() {
    _titles = widget.titles;
    super.initState();
  }

  @override
  void onEvent(DropdownEvent? event) {
    switch (event) {
      case DropdownEvent.SELECT:
        {
          if (_activeIndex == null) return;

          setState(() {
            _activeIndex = null;
            dynamic title = controller!.data;
            _titles[controller!.menuIndex!] = title as T;
          });
        }
        break;
      case DropdownEvent.HIDE:
        {
          if (_activeIndex == null) return;
          setState(() {
            _activeIndex = null;
          });
        }
        break;
      case DropdownEvent.ACTIVE:
        {
          if (_activeIndex == controller!.menuIndex) return;
          setState(() {
            _activeIndex = controller!.menuIndex;
          });
        }
        break;
      default:
        break;
    }
  }
}
