import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllFeaturesMenu extends StatelessWidget {
  const AllFeaturesMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('All Features'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.xmark_circle_fill),
          onPressed: () => Get.back(),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              'Dashboard & Analytics',
              [
                _FeatureItem('Dashboard', '/dashboard', CupertinoIcons.chart_bar_square_fill),
                _FeatureItem('Dashboard V2', '/dashboard-v2', CupertinoIcons.chart_pie_fill),
                _FeatureItem('Pro Analytics', '/pro-analytics', CupertinoIcons.graph_circle_fill),
                _FeatureItem('History', '/history', CupertinoIcons.clock_fill),
                _FeatureItem('Prompt History', '/prompt-history', CupertinoIcons.text_bubble_fill),
              ],
            ),
            _buildSection(
              'Widget Creation',
              [
                _FeatureItem('Create Widget', '/create-widget', CupertinoIcons.plus_square_fill),
                _FeatureItem('AI Widget Creator', '/ai-widget-creator', CupertinoIcons.wand_stars),
                _FeatureItem('Widget Creator', '/widget-creator', CupertinoIcons.square_stack_3d_up_fill),
                _FeatureItem('Widget Creator Final', '/widget-creator-final', CupertinoIcons.checkmark_square_fill),
                _FeatureItem('Widget Creation', '/widget-creation', CupertinoIcons.rectangle_3_offgrid_fill),
                _FeatureItem('Investment Widgets', '/investment-widget-creator', CupertinoIcons.money_dollar_circle_fill),
                _FeatureItem('Widget Remix', '/widget-remix', CupertinoIcons.shuffle),
                _FeatureItem('Widget View', '/widget-view', CupertinoIcons.eye_fill),
                _FeatureItem('Widget Preview', '/widget-preview', CupertinoIcons.rectangle_expand_vertical),
              ],
            ),
            _buildSection(
              'Discovery & Browse',
              [
                _FeatureItem('Explore', '/explore', CupertinoIcons.compass_fill),
                _FeatureItem('Discovery', '/discovery', CupertinoIcons.sparkles),
                _FeatureItem('Trending', '/trending', CupertinoIcons.flame_fill),
                _FeatureItem('Template Gallery', '/template-gallery', CupertinoIcons.rectangle_grid_3x2_fill),
                _FeatureItem('Search', '/search', CupertinoIcons.search),
                _FeatureItem('Enhanced Search', '/enhanced-search', CupertinoIcons.search_circle_fill),
              ],
            ),
            _buildSection(
              'AI & Assistant',
              [
                _FeatureItem('AI Assistant', '/ai-assistant', CupertinoIcons.chat_bubble_2_fill),
              ],
            ),
            _buildSection(
              'User Account',
              [
                _FeatureItem('Profile', '/profile', CupertinoIcons.person_fill),
                _FeatureItem('User Profile', '/user-profile', CupertinoIcons.person_circle_fill),
                _FeatureItem('Settings', '/settings', CupertinoIcons.gear_solid),
                _FeatureItem('Notifications', '/notifications', CupertinoIcons.bell_fill),
              ],
            ),
            _buildSection(
              'Authentication',
              [
                _FeatureItem('Login (OTP)', '/login', CupertinoIcons.lock_fill),
                _FeatureItem('Login (Traditional)', '/login-traditional', CupertinoIcons.lock_shield_fill),
                _FeatureItem('Register', '/register', CupertinoIcons.person_add_solid),
                _FeatureItem('Forgot Password', '/forgot-password', CupertinoIcons.lock_rotation),
                _FeatureItem('User Onboarding', '/user-onboarding', CupertinoIcons.book_fill),
              ],
            ),
            _buildSection(
              'Legacy Screens',
              [
                _FeatureItem('Main (Legacy)', '/main-legacy', CupertinoIcons.square_grid_2x2_fill),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_FeatureItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CupertinoColors.separator.withOpacity(0.2)),
          ),
          child: Column(
            children: items.map((item) {
              final isLast = items.last == item;
              return Column(
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Get.toNamed(item.route),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: CupertinoColors.activeBlue,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.label,
                              ),
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_right,
                            color: CupertinoColors.tertiaryLabel,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 52,
                      color: CupertinoColors.separator.withOpacity(0.2),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CupertinoColors.systemIndigo.withOpacity(0.1),
            CupertinoColors.systemPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemIndigo.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: CupertinoColors.systemIndigo,
              ),
              SizedBox(width: 8),
              Text(
                'All Features Enabled',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This menu provides access to all implemented features in AssetWorks Reimagined, including:',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeaturePoint('• All iOS 18 services initialized'),
          _buildFeaturePoint('• Dynamic Island integration'),
          _buildFeaturePoint('• Apple Watch support'),
          _buildFeaturePoint('• Home & Lock Screen widgets'),
          _buildFeaturePoint('• Siri Shortcuts & Spotlight'),
          _buildFeaturePoint('• Advanced haptics & animations'),
          _buildFeaturePoint('• Multiple widget creation flows'),
          _buildFeaturePoint('• AI-powered features'),
        ],
      ),
    );
  }

  Widget _buildFeaturePoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: CupertinoColors.secondaryLabel,
        ),
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final String route;
  final IconData icon;

  _FeatureItem(this.title, this.route, this.icon);
}