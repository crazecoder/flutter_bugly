#import "FlutterBuglyPlugin.h"
#import <Bugly/Bugly.h>

@implementation FlutterBuglyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_bugly"
            binaryMessenger:[registrar messenger]];
  FlutterBuglyPlugin* instance = [[FlutterBuglyPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initBugly" isEqualToString:call.method]) {
    NSString *appId = call.arguments[@"appId"];
    [Bugly startWithAppId:appId];
      NSLog(@"Bugly appId: %@", appId);
    result(@"Bugly 初始化成功");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
