import 'package:flutter/material.dart';


/// @author: Sagar K.C.
/// @email: sagar.kc@fonepay.com
/// @created_at: 5/17/2024, Friday

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.centerTitle = false,
  });

  final String? title;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      title: Text(
        title ?? 'Enter your wedding details here',
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      backgroundColor: Colors.red.withOpacity(0.7),
      actions: [
        PopupMenuButton(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          color: Colors.white,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: Text("About Us"),
            ),
            const PopupMenuItem(
              value: 2,
              child: Text("Privacy Policy"),
            ),
          ],
          onSelected: (value) {
      /*      if (value == 1) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            } else if (value == 2) {
              try {
                launchUrlString(
                    "https://thulotechnology.com/privacy-policy-for-wedding-invitation-video-maker/");
              } catch (e) {
                debugPrint("Error while launching web view");
              }
            } else if (value == 3) {}*/
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

