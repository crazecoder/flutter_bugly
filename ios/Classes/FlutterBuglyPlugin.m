#import "FlutterBuglyPlugin.h"
#import <Bugly/Bugly.h>

@implementation FlutterBuglyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"crazecoder/flutter_bugly"
            binaryMessenger:[registrar messenger]];
  FlutterBuglyPlugin* instance = [[FlutterBuglyPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"initBugly" isEqualToString:call.method]) {
      NSString *appId = call.arguments[@"appId"];
      BOOL b = [self isBlankString:appId];
      if(!b){
          [Bugly startWithAppId:appId];
          NSLog(@"Bugly appId: %@", appId);
          NSDictionary * dict = @{@"message":@"Bugly 初始化成功", @"isSuccess":@YES};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          
          result(json);
      }else{
          NSDictionary * dict = @{@"message":@"Bugly 初始化失败", @"isSuccess":@NO};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
          
          result(json);
      }
      
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
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
    
}

@end
