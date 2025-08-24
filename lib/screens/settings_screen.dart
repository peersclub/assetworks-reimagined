import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: CupertinoListSection.insetGrouped(
          children: [
            CupertinoListTile.notched(
              title: const Text('Dark Mode'),
              trailing: CupertinoSwitch(
                value: false,
                onChanged: (value) {},
              ),
            ),
            CupertinoListTile.notched(
              title: const Text('Notifications'),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () {},
            ),
            CupertinoListTile.notched(
              title: const Text('Privacy'),
              trailing: const Icon(CupertinoIcons.chevron_right),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}