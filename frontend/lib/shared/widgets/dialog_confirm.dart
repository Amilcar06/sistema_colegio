import 'package:flutter/material.dart';

class DialogConfirm {
  static Future<bool> show(
      BuildContext context, {
        required String title,
        required String message,
        String cancelText = 'Cancelar',
        String confirmText = 'Aceptar',
        Color confirmColor = Colors.red,
      }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
