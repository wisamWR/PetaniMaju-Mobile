import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class CustomShowcase extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final Widget child;
  final bool isLast;

  const CustomShowcase({
    super.key,
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: showcaseKey,
      container: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => ShowCaseWidget.of(context).dismiss(),
                  child: const Text("Lewati",
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      ShowCaseWidget.of(context).dismiss();
                    } else {
                      ShowCaseWidget.of(context).next();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF166534),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(isLast ? "Selesai" : "Lanjut"),
                ),
              ],
            ),
          ],
        ),
      ),
      height: 200,
      width: 280,
      child: child,
    );
  }
}
