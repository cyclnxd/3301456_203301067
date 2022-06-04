import 'package:flutter/material.dart';

showSnackBar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

String datePicker({required DateTime start, required DateTime end}) {
  int difference = end.difference(start).inMinutes;

  if (difference < 1) {
    return '${end.difference(start).inSeconds}s ago';
  } else if (difference > 60 && difference < 1440) {
    return '${end.difference(start).inHours}h ago';
  } else if (difference >= 1440) {
    return '${end.difference(start).inDays}d ago';
  } else {
    return '${end.difference(start).inMinutes}m ago';
  }
}
