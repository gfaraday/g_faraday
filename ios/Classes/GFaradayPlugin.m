#import "GFaradayPlugin.h"
#if __has_include(<g_faraday/g_faraday-Swift.h>)
#import <g_faraday/g_faraday-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "g_faraday-Swift.h"
#endif

@implementation GFaradayPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGFaradayPlugin registerWithRegistrar:registrar];
}
@end
