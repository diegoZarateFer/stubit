import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:stubit/widgets/image_button.dart';
import 'package:stubit/widgets/user_menu.dart';

class UserButton extends StatelessWidget {
  const UserButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ImageButton(
      imagePath: "assets/images/user.png",
      onPressed: () { 
        showPopover(
          context: context,
          bodyBuilder: (ctx) =>  const UserMenu(),
          width: 180,
          height: 150,
          backgroundColor: const Color(0xFF000002),
        );
      },
    );
  }
}
