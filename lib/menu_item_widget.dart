import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double size;
  final Animation<double> animation;
  final VoidCallback onTap;

  const MenuItemWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.animation,
    required this.onTap,
    this.size = 70.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: animation.value,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: size * 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: size + 20,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
