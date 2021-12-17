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
          BuglyConfig * config = [[BuglyConfig alloc] init];
          NSString *channel = call.arguments[@"channel"];
          BOOL isChannelEmpty = [self isBlankString:channel];
          if(!isChannelEmpty){
            config.channel = channel;
          }
          [Bugly startWithAppId:appId config:config];
          NSLog(@"Bugly appId: %@", appId);

          NSDictionary * dict = @{@"message":@"Bugly 初始化成功",@"appId":appId, @"isSuccess":@YES};
          NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
          NSString * json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

          result(json);
      }else{
          NSDictionary * dict = @{@"message":@"Bugly appId不能为空", @"isSuccess":@NO};
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
      NSArray *stackTraceArray = [crash_detail componentsSeparatedByString:@""];
      NSDictionary *data = call.arguments[@"crash_data"];
      if(data == nil){
        data = [NSMutableDictionary dictionary];
      }

      [Bugly reportExceptionWithCategory:5 name:crash_message reason:@" " callStack:stackTraceArray extraInfo:data terminateApp:NO];
      result(nil);
  }else if([@"setUserId" isEqualToString:call.method]){
      NSString *userId = call.arguments[@"userId"];
      if (![self isBlankString:userId]) {
          [Bugly setUserIdentifier:userId];
      }
      result(nil);
  }else if([@"setUserTag" isEqualToString:call.method]){
      NSNumber *userTag = call.arguments[@"userTag"];
      if (userTag!=nil) {
          NSInteger anInteger = [userTag integerValue];
          [Bugly setTag:anInteger];
      }
      result(nil);
  }else if([@"putUserData" isEqualToString:call.method]){
      NSString *key = call.arguments[@"key"];
      NSString *value = call.arguments[@"value"];
      if (![self isBlankString:key]&&![self isBlankString:value]){
          [Bugly setUserValue:value forKey:key];
      }
      result(nil);
  }else if([@"BuglyLog" isEqualToString:call.method]){///自定义日志
         NSString *tag = call.arguments[@"tag"];
         NSString *log = call.arguments[@"log"];
         NSInteger levelInteger =4;
         NSNumber *level = call.arguments[@"level"];
         if (level!=nil) {
            levelInteger = [level integerValue];
         }
        switch(levelInteger){
           case 5:
                BLYLogVerbose(tag, log);
              break;
           case 4:
                BLYLogDebug(tag, log);
              break;
           case 3:
                BLYLogInfo(tag, log);
              break;
           case 2:
                BLYLogWarn(tag, log);
              break;
           case 1:
                BLYLogError(tag, log);
              break;
           default :
                BLYLogDebug(tag, log);
              break;
        }
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
