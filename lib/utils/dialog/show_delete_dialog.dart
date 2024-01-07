import 'package:flutter/material.dart';
import 'package:my_motes/utils/dialog/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete Note',
    content: 'Are you sure you want to delete this note?',
    optionBuilder: () => {
      'Cancel': false,
      'Delete': true,
    },
  ).then((value) => value ?? false);
}
