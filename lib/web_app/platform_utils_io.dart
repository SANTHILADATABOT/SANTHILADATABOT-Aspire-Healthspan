
// import 'dart:io';
//
// bool get isIOS => Platform.isIOS;

// platform_utils_io.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

bool get isIOS =>
    !kIsWeb &&
        (Platform.isIOS || (Platform.isMacOS && defaultTargetPlatform == TargetPlatform.iOS));


