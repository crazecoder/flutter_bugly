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
  }else if([@"postCatchedException" isEqualToString:call.method]){
      NSString *crash_detail = call.arguments[@"crash_detail"];
      NSString *crash_message = call.arguments[@"crash_message"];
      if (crash_detail == nil || crash_detail == NULL) {
         crash_message = @"";
      }
      if ([crash_detail isKindOfClass:[NSNull class]]) {
          crash_message = @"";
      }
      NSException* ex = [[NSException alloc]initWithName:crash_message
                                                  reason:crash_detail
                                                userInfo:nil];
      [Bugly reportException:ex];
      result(nil);
  }else {
    result(FlutterMethodNotImplemented);
  }
}

@end
