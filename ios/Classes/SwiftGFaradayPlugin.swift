import Flutter
import UIKit

public class SwiftGFaradayPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        Faraday.default.setup(messenger: registrar.messenger())
    }
}
