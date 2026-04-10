import 'package:flutter/material.dart';
import '../../../core/theme.dart';

/// 홈/메뉴 바로가기: 번호 자리에 D, 이어서 O·N·E 순의 리스트 마커.
class DoneListShortcutIcon extends StatelessWidget {
  final Color color;
  final double size;

  const DoneListShortcutIcon({
    super.key,
    required this.color,
    required this.size,
  });

  static const List<String> _markers = ['D', 'O', 'N', 'E'];

  @override
  Widget build(BuildContext context) {
    final markerColW = size * 0.28;
    final fontSize = (size * 0.34).clamp(7.0, 14.0);
    final lineW = size * 0.48;
    final lineH = (size * 0.1).clamp(2.0, 4.0);
    final gap = size * 0.06;

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < _markers.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            Row(
              children: [
                SizedBox(
                  width: markerColW,
                  child: Text(
                    _markers[i],
                    textAlign: TextAlign.center,
                    style: appStyle(
                      context,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                ),
                Container(
                  width: lineW,
                  height: lineH,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(lineH / 2),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
