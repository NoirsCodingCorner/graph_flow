import 'package:flutter/material.dart';

/// Builds a connection point widget for the selected state.
/// This version returns a circular widget with a blue border when selected,
/// and (for demonstration) displays an icon.
Widget StandardConnectionPoint(bool forSelected) {
  return Container(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: forSelected ? Colors.blue : Colors.grey,
        width: 2,
      ),
    ),
    child: Center(
      child: Icon(
        Icons.link,
        color: forSelected ? Colors.blue : Colors.grey,
        size: 16,
      ),
    ),
  );
}
