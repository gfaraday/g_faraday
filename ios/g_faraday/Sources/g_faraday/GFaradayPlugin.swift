import Flutter
import UIKit

@objc(GFaradayPlugin)
public class GFaradayPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        Faraday.default.setup(messenger: registrar.messenger())
    }
}
