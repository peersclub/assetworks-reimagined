import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class WidgetCardShimmer extends StatelessWidget {
  final int count;
  
  const WidgetCardShimmer({
    Key? key,
    this.count = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(count, (index) => _buildShimmerCard(context)),
    );
  }
  
  Widget _buildShimmerCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.darkBackgroundGray
            : CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.systemGrey5.darkColor
            : CupertinoColors.systemGrey5,
        highlightColor: CupertinoTheme.of(context).brightness == Brightness.dark
            ? CupertinoColors.systemGrey4.darkColor
            : CupertinoColors.systemGrey6,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Section
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Username and Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 180,
                          height: 14,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Follow Button
                  Container(
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // AI Summary Section
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 200,
                      height: 14,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey5,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Stats and Actions Row
              Container(
                padding: EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.systemGrey5,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Stats
                    Row(
                      children: List.generate(3, (index) => Container(
                        margin: EdgeInsets.only(right: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 24,
                              height: 12,
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemGrey5,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ),
                    
                    // Action Buttons
                    Row(
                      children: List.generate(4, (index) => Container(
                        margin: EdgeInsets.only(left: 12),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey5,
                          borderRadius: BorderRadius.circular(11),
                        ),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}