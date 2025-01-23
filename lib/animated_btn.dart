import 'package:flutter/material.dart';

/// [Widget] building the [MaterialApp].
class DraggleBtnWidget extends StatelessWidget {
  const DraggleBtnWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            // Specify IconData as type argument for Dock
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  double mainHeight = 72.0;
  double childHeight = 48.0;
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = widget.items.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      height:
          mainHeight, // Fixed height for the container (item height + margin)
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          return Draggable<T>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(minWidth: childHeight),
                height: childHeight,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      Colors.primaries[item.hashCode % Colors.primaries.length],
                ),
                child:
                    Center(child: Icon(item as IconData, color: Colors.white)),
              ),
            ),
            childWhenDragging: Container(
              constraints: BoxConstraints(minWidth: childHeight),
              height: childHeight,
            ), // Empty container when dragging
            child: DragTarget<T>(
              onWillAccept: (data) {
                return data != item; // Prevent self-drop
              },
              onAccept: (data) {
                setState(() {
                  final fromIndex = _items.indexOf(data);
                  final toIndex = _items.indexOf(item);

                  // Swap the items
                  _items[fromIndex] = _items[toIndex];
                  _items[toIndex] = data;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        childHeight = 55.0;
                        mainHeight = 79.0;
                        // Increase size when mouse enters
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        childHeight = 48.0;
                        mainHeight = 72.0;
                        // Reset size when mouse exits
                      });
                    },
                    child: AnimatedContainer(
                      key: ValueKey<T>(item), // Unique key for animation
                      constraints: BoxConstraints(minWidth: childHeight),
                      height: childHeight, // Fixed height for each item
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors
                            .primaries[item.hashCode % Colors.primaries.length],
                      ),
                      duration: const Duration(milliseconds: 300),
                      child: Center(
                          child: Icon(item as IconData, color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
