import 'package:flutter/material.dart';

import 'colors.dart';

Color cardColor = posSurface;
ShapeBorder cardShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(24.0),
  side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
);
double? cardElevation = 0.0;
EdgeInsets cardMargin = const EdgeInsets.all(16.0);
double pagePadding = 24;
double containerMaxWidth = 500;
WidgetStateProperty<Color?> iconButtonBackground =
    WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05));
