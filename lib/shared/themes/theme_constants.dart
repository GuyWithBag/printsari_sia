import 'package:flutter/material.dart';

import 'colors.dart';

Color cardColor = white;
ShapeBorder cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16.0),
);
double? cardElevation = 4.0;
EdgeInsets cardMargin = const EdgeInsets.all(16.0);
double pagePadding = 20;
double containerMaxWidth = 500;
WidgetStateProperty<Color?> iconButtonBackground =
    WidgetStateProperty.all(black.withAlpha(36));
// 'bg-cardColor'

// backgroundColor: cardColor