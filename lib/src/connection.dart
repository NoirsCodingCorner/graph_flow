import 'dart:math';
import 'package:flutter/material.dart';

/// Extension on [Color] to provide a non-deprecated way for explicit ARGB32 conversion.
extension ColorConversion on Color {
  /// Converts this [Color] into a 32-bit ARGB integer.
  ///
  /// The result packs the alpha, red, green, and blue components into a single integer value.
  int toARGB32() {
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
}

/// Represents a connection between two points in the application.
///
/// A [Connection] defines a link between two unique connection point identifiers.
/// Optionally, a connection color can be provided; otherwise, a random color is generated.
/// This class provides JSON serialization support as well as proper equality and hashing.
class Connection {
  /// The unique identifier for the first connection point.
  final String id1;

  /// The unique identifier for the second connection point.
  final String id2;

  /// The color associated with this connection.
  ///
  /// If no color is provided, a random opaque color is generated.
  final Color color;

  /// Creates a [Connection] instance with the given [id1], [id2], and an optional [color].
  ///
  /// If [color] is null, a random color is generated.
  Connection(this.id1, this.id2, Color? color)
      : color = color ?? _generateRandomColor();

  /// Generates a random opaque [Color].
  ///
  /// Returns a [Color] with full opacity and random RGB components.
  static Color _generateRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  /// Converts this [Connection] into a JSON-compatible map.
  ///
  /// The [color] is represented by its 32-bit ARGB integer obtained via [toARGB32].
  /// Returns a [Map] containing the connection data.
  Map<String, dynamic> toJson() {
    return {
      'id1': id1,
      'id2': id2,
      'color': color.toARGB32(),
    };
  }

  /// Creates a new [Connection] instance from a JSON [Map].
  ///
  /// Expects the map to contain:
  /// - `id1`: A [String] representing the first connection point.
  /// - `id2`: A [String] representing the second connection point.
  /// - `color`: An [int] representing the 32-bit ARGB color value.
  ///
  /// Throws a [FormatException] if any required key is missing or if the type is invalid.
  factory Connection.fromJson(Map<String, dynamic> json) {
    if (json['id1'] is! String ||
        json['id2'] is! String ||
        json['color'] is! int) {
      throw FormatException('Invalid JSON format for Connection');
    }
    return Connection(
      json['id1'] as String,
      json['id2'] as String,
      Color(json['color'] as int),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Connection &&
              runtimeType == other.runtimeType &&
              id1 == other.id1 &&
              id2 == other.id2 &&
              color.toARGB32() == other.color.toARGB32();

  @override
  int get hashCode => id1.hashCode ^ id2.hashCode ^ color.toARGB32().hashCode;
}
