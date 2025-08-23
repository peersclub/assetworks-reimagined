import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';

class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Widgets'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 22),
          ),
        ],
      ),
      body: Center(
        child: Text('Widgets Screen'),
      ),
    );
  }
}