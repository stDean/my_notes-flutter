import 'package:flutter/material.dart';
import 'package:my_motes/utils/dialog/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showGenericDialog(
    context: context,
    title: 'An Error Occurred',
    content: text,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
