# g_faraday Objective 集成

## 创建 `FaradayHelper.swift`

``` swift
@objc class FaradayHelper: NSObject {
    
    @objc static func enableAutomaticallyExtension() {
        // 自动处理导航栏
        UINavigationController.fa.automaticallyHandleNavigationBarHidden()
        // 自动回调空值到flutter侧，避免flutter侧 await 一直不返回
        UIViewController.fa.automaticallyCallbackNullToFlutter()
    }
    
    @objc static func startFlutterEngine(navigatorDelegate: FaradayNavigationDelegate,
                                         httpProvider: FaradayHttpProvider? = nil,
                                         commonHandler: FaradayHandler? = nil) {
        Faraday.default.startFlutterEngine(navigatorDelegate: navigatorDelegate, httpProvider: httpProvider, commonHandler: commonHandler)
    }
    
    @objc static var currentFlutterViewController: FaradayFlutterViewController? {
        return Faraday.default.currentFlutterViewController
    }
    
    @objc static func postNotification(_ name: String, arguments: Any? = nil) {
        Faraday.default.postNotification(name, arguments: arguments)
    }
    
    @objc static func enableCallback(_ viewController: FaradayFlutterViewController, callback token: CallbackToken) {
        viewController.fa.enableCallback(with: token)
    }
}
```

## 实现对应接口

``` objc

@import g_faraday;

@interface AppDelegate (Faraday) <FFNavigationDelegate, FFHttpProvider>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    [FaradayHelper enableAutomaticallyExtension];
    
    [FaradayHelper startFlutterEngineWithNavigatorDelegate:self httpProvider:self commonHandler:^(NSString * _Nonnull name, id _Nullable arguments, void (^ _Nonnull completion)(id _Nullable result)) {
        
    }];

    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end


@implementation AppDelegate(Faraday)

// mark -
- (void)push:(NSString * _Nonnull)name arguments:(id _Nullable)arguments options:(Options * _Nonnull)options callback:(NSUUID * _Nonnull)token {
    
    FFViewController *fvc = [[FFViewController alloc] init:@"home" arguments:nil backgroundClear:NO engine:nil callback:^(id _Nullable result) {
        
    }];
    
    UIViewController *root = [UIApplication.sharedApplication keyWindow].rootViewController;
    
    [root presentViewController:fvc animated:true completion:^{
            
    }];
    
    // 重要 不然咩有回调
    [FaradayHelper enableCallback:fvc callback:token];
}

// mark -
- (void)requestWithMethod:(NSString * _Nonnull)method url:(NSString * _Nonnull)url parameters:(NSDictionary<NSString *,id> * _Nullable)parameters headers:(NSDictionary<NSString *,NSString *> * _Nullable)headers completion:(void (^ _Nonnull)(id _Nullable))completion {
}

@end

```
