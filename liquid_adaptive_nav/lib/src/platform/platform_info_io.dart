import 'dart:io';

import 'package:flutter/foundation.dart';

/// Host runtime OS flags using `dart:io`, safely guarded by `kIsWeb`.
bool get isIOSHost => !kIsWeb && Platform.isIOS;

bool get isAndroidHost => !kIsWeb && Platform.isAndroid;

bool get isMobileNativeHost => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
