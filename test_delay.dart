import 'package:flutter/material.dart';
void main() {
  ReorderableListView(
    children: [],
    onReorder: (i, j) {},
    buildDefaultDragHandles: true,
    clipBehavior: Clip.hardEdge,
    dragStartBehavior: DragStartBehavior.start,
    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
    restorationId: '',
    scrollDirection: Axis.vertical,
    scrollController: null,
    primary: false,
    physics: null,
    shrinkWrap: false,
    padding: null,
    reverse: false,
    cacheExtent: null,
    semanticChildCount: null,
    dragStartDuration: const Duration(milliseconds: 150),
  );
}
