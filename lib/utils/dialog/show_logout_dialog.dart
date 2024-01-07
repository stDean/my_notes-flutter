import 'package:flutter/material.dart';
import 'package:my_motes/utils/dialog/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Log Out',
    content: 'Are you sure you want to log out?',
    optionBuilder: () => {
      'Cancel': false,
      'Log Out': true,
    },
  ).then((value) => value ?? false);
}
