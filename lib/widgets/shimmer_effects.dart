
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingItem extends StatelessWidget {
  const ShimmerLoadingItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            radius: 20,
          ),
          const SizedBox(width: 20),
          Container(
            width: 100,
            height: 16,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
