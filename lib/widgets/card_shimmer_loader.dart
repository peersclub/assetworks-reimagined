import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class CardShimmerLoader extends StatelessWidget {
  const CardShimmerLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildShimmerCard(context),
        ),
      ),
    );
  }

  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: CupertinoColors.systemGrey5,
        highlightColor: CupertinoColors.systemGrey6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Username and title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 14,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 200,
                          height: 12,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey4,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Follow button
                  Container(
                    width: 70,
                    height: 28,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Summary placeholder
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Stats row
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}