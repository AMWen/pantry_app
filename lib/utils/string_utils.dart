import 'package:flutter/material.dart';
import '../data/constants.dart';

bool isPlural(String word) {
  // Check if word is an irregular plural or ends with s
  final irregularPlurals = ['children', 'men', 'women', 'feet', 'teeth', 'mice', 'people', 'cacti'];

  if (irregularPlurals.contains(word.toLowerCase())) {
    return true;
  }

  return word.endsWith('s');
}

Color getTagColor(String? tag) {
  if (tag == null || tag.isEmpty) return Colors.grey;
  
  int index = tagOrder.indexOf(tag);
  double hue = index >= 0 ? (index / tagOrder.length) * 360 : 0;
  double saturation = index >= 0 ? (index + tagOrder.length) / (tagOrder.length * 2) : 1;
  double lightness = 0.75;

  return HSVColor.fromAHSV(1.0, hue, saturation, lightness).toColor();
}
