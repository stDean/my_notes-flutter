import 'package:flutter/material.dart';
import 'package:my_motes/utils/dialog/generic_dialog.dart';

Future<void> showPasswordResetDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Password Reset',
    content: 'Email sent, check email to reset password',
    optionBuilder: () => {'OK': null},
  );
}
