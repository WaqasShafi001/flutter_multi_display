
import 'flutter_multi_display_platform_interface.dart';

class FlutterMultiDisplay {
  Future<String?> getPlatformVersion() {
    return FlutterMultiDisplayPlatform.instance.getPlatformVersion();
  }
}
