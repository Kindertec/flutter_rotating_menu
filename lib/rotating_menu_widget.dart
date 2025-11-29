import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'menu_item_widget.dart';

class RotatingMenuWidget extends HookConsumerWidget {
  final double radius;
  final double itemSize;
  final Widget? centerWidget;
  final List<MenuItemData>? customItems;

  const RotatingMenuWidget({
    super.key,
    this.radius = 110.0,
    this.itemSize = 70.0,
    this.centerWidget,
    this.customItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default demo items
    final defaultItems = [
      MenuItemData(
        title: 'Item 1',
        icon: Icons.build_circle,
        color: Colors.orange,
        onTap: () => _showSnackBar(context, 'Item 1 tapped'),
      ),
      MenuItemData(
        title: 'Item 2',
        icon: Icons.handyman,
        color: Colors.blue,
        onTap: () => _showSnackBar(context, 'Item 2 tapped'),
      ),
      MenuItemData(
        title: 'Item 3',
        icon: Icons.business,
        color: Colors.green,
        onTap: () => _showSnackBar(context, 'Item 3 tapped'),
      ),
      MenuItemData(
        title: 'Item 4',
        icon: Icons.directions_car,
        color: Colors.purple,
        onTap: () => _showSnackBar(context, 'Item 4 tapped'),
      ),
      MenuItemData(
        title: 'Item 5',
        icon: Icons.local_hospital,
        color: Colors.red,
        onTap: () => _showSnackBar(context, 'Item 5 tapped'),
      ),
    ];

    final items = customItems ?? defaultItems;
    final itemCount = items.length;

    final rotationAngle = useState(0.0);
    final velocity = useState(0.0);
    final startAngle = useRef(0.0);
    final startTime = useRef(0.0);

    final tickerRef = useRef<Ticker?>(null);
    final simulationRef = useRef<FrictionSimulation?>(null);

    useEffect(() {
      tickerRef.value = Ticker((elapsed) {
        if (simulationRef.value != null) {
          final sim = simulationRef.value!;
          final time = elapsed.inMilliseconds / 1000.0;

          if (sim.isDone(time)) {
            tickerRef.value?.stop();
            simulationRef.value = null;
          } else {
            rotationAngle.value = sim.x(time);
          }
        }
      });

      return () => tickerRef.value?.dispose();
    }, []);

    final controllers = List.generate(
      itemCount,
      (_) => useAnimationController(
        duration: const Duration(milliseconds: 200),
      ),
    );

    final animations = useMemoized(
      () => controllers
          .map((c) => Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: c, curve: Curves.elasticOut),
              ))
          .toList(),
    );

    for (var animation in animations) {
      useListenable(animation);
    }

    useEffect(() {
      Future.microtask(() async {
        for (int i = 0; i < itemCount; i++) {
          await controllers[i].forward();
        }
      });
      return null;
    }, []);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.47,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final center = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight / 2,
          );

          void onRotationStart(DragStartDetails details) {
            final pos = details.localPosition;
            startAngle.value = atan2(pos.dy - center.dy, pos.dx - center.dx);
            startTime.value = DateTime.now().millisecondsSinceEpoch.toDouble();
            velocity.value = 0.0;
          }

          void onRotationUpdate(DragUpdateDetails details) {
            final pos = details.localPosition;
            final angle = atan2(pos.dy - center.dy, pos.dx - center.dx);
            final now = DateTime.now().millisecondsSinceEpoch.toDouble();
            final timeDiff = (now - startTime.value) / 1000.0;

            if (timeDiff < 0.001) return;

            double deltaAngle = angle - startAngle.value;

            if (deltaAngle.abs() > pi) {
              deltaAngle -= (2 * pi) * deltaAngle.sign;
            }

            rotationAngle.value += deltaAngle;
            velocity.value = deltaAngle / timeDiff;
            startAngle.value = angle;
            startTime.value = now;
          }

          void onRotationEnd(DragEndDetails details) {
            final sim = FrictionSimulation(
              0.05,
              rotationAngle.value,
              velocity.value,
            );
            simulationRef.value = sim;

            final ticker = tickerRef.value;
            if (ticker != null) {
              if (ticker.isActive) ticker.stop();
              ticker.start();
            }
          }

          Offset getItemOffset(int index) {
            final angle =
                rotationAngle.value + (2 * pi * index / itemCount) - (pi / 2);
            final dx = radius * cos(angle);
            final dy = radius * sin(angle);
            return Offset(dx, dy);
          }

          return GestureDetector(
            onPanStart: onRotationStart,
            onPanUpdate: onRotationUpdate,
            onPanEnd: onRotationEnd,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(items.length, (index) {
                  final offset = getItemOffset(index);
                  return Transform.translate(
                    offset: offset,
                    child: MenuItemWidget(
                      title: items[index].title,
                      icon: items[index].icon,
                      color: items[index].color,
                      size: itemSize,
                      animation: animations[index],
                      onTap: items[index].onTap,
                    ),
                  );
                }),
                centerWidget ??
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.apps,
                        size: 30,
                        color: Colors.blue.shade700,
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class MenuItemData {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  MenuItemData({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
