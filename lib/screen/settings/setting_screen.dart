import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/widget/network_image.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(.94),
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // user card
            // SimpleUserCard(
            //   imageRadius: 10,
            //   userName: "ທ່ານ ສົມສີ ສີທອງແທ້",
            //   userProfilePic: const AssetImage("assets/images/sample_profile.jpg"),
            // ),
            SettingsGroup(
              items: [
                SettingsItem(
                  onTap: () {

                  },
                  icons: CupertinoIcons.pencil_outline,
                  iconStyle: IconStyle(),
                  title:
                  'Gold Products',
                  subtitle:
                  "Manage Gold Products",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                ),
                SettingsItem(
                  onTap: () {

                  },
                  icons: CupertinoIcons.pencil_outline,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal
                  ),
                  title:
                  'Shop Information',
                  subtitle:
                  "Manage Shop Information",
                  titleMaxLine: 1,
                  subtitleMaxLine: 1,
                ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: CupertinoIcons.pencil_outline,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.orange
                //   ),
                //   title:
                //   'Gold Products',
                //   subtitle:
                //   "Manage Gold Products",
                //   titleMaxLine: 1,
                //   subtitleMaxLine: 1,
                // ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: CupertinoIcons.pencil_outline,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.green
                //   ),
                //   title:
                //   'Gold Products',
                //   subtitle:
                //   "Manage Gold Products",
                //   titleMaxLine: 1,
                //   subtitleMaxLine: 1,
                // ),
                // SettingsItem(
                //   onTap: () {},
                //   icons: Icons.fingerprint,
                //   iconStyle: IconStyle(
                //     iconsColor: Colors.white,
                //     withBackground: true,
                //     backgroundColor: Colors.red,
                //   ),
                //   title: 'Privacy',
                //   subtitle: "Lock Ziar'App to improve your privacy",
                // ),
                // SettingsItem(
                //   onTap: () {},
                //   icons: Icons.dark_mode_rounded,
                //   iconStyle: IconStyle(
                //     iconsColor: Colors.white,
                //     withBackground: true,
                //     backgroundColor: Colors.red,
                //   ),
                //   title: 'Dark mode',
                //   subtitle: "Automatic",
                //   trailing: Switch.adaptive(
                //     value: false,
                //     onChanged: (value) {},
                //   ),
                // ),
              ],
            ),
            SettingsGroup(
              items: [
                SettingsItem(
                  onTap: () {},
                  icons: Icons.info_rounded,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'About',
                  subtitle: "Learn more about App",
                ),
              ],
            ),
            // You can add a settings title
            SettingsGroup(
              settingsGroupTitle: "Account",
              items: [
                SettingsItem(
                  onTap: () {},
                  icons: Icons.exit_to_app_rounded,
                  title: "Sign Out",
                ),
                SettingsItem(
                  onTap: () {},
                  icons: CupertinoIcons.repeat,
                  title: "Change email",
                ),
                SettingsItem(
                  onTap: () {},
                  icons: CupertinoIcons.delete_solid,
                  title: "Delete account",
                  titleStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
