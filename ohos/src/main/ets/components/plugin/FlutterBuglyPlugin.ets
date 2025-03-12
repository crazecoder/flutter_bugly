/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
00 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import {
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import {
  Bugly,
  BuglyBuilder
} from "bugly";

export default class FlutterBuglyPlugin implements FlutterPlugin, MethodCallHandler {
  private channel: MethodChannel | null = null;

  constructor() {
  }

  getUniqueClassName(): string {
    return "FlutterBuglyPlugin";
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), "crazecoder/flutter_bugly");
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel != null) {
      this.channel.setMethodCallHandler(null);
    }
  }

  public onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case "initBugly":
        this.initBugly(call, result);
        break;
      
      case "setUserId":
        this.setUserId(call, result);
        break;

      case "setDeviceId":
        this.setDeviceId(call, result);
        break;
      
      case "setDeviceModel":
        this.setDeviceModel(call, result);
        break;

      case "putUserData":
        this.putUserData(call,result);
        break;

      case "postCatchedException":
        this.postCatchedException(call, result);
        break;

      default:
        result.notImplemented();
        break;
    }
  }

  private async initBugly(call: MethodCall, result: MethodResult): Promise<void> {
    let builder = new BuglyBuilder();

    builder.appId = call.argument("appId") as string;   // 必填，Bugly产品信息中的APP ID
    builder.appKey = call.argument("appKey") as string;    // 必填，Bugly产品信息中的APP KEY
    builder.deviceId = call.argument("deviceId") as string;     // 必填，设备ID，应保证设备ID对不同设备唯一
    builder.platform = BuglyBuilder.PLATFORM_PRO;    // 必填，设置上报平台，专业版本需设置为[BuglyBuilder.PLATFORM_PRO]
    
    // 选填，业务的 App 版本
    if (call.hasArgument("appVersion")) {
      builder.appVersion = call.argument("appVersion") as string;
    } else {
      builder.appVersion = "1.0.0";
    }

    // 选填，业务 App 版本的构建号
    if (call.hasArgument("buildNum")) {
      builder.buildNum = call.argument("buildNum")as string;
    } else {
      builder.buildNum = "0";
    }

    // 选填，业务 App 渠道
    if (call.hasArgument("channel")) {
      builder.appChannel = call.argument("channel") as string;
    } else {
      builder.appChannel = "website";
    }

    // 选填，用户 ID，如不设置则为空
    if (call.hasArgument("userId")) {
      builder.userId = call.argument("userId") as string;
    } else {
      builder.userId = "";
    }

    // 选填，机型，如不设置则为空
    if (call.hasArgument("deviceModel")) {
      builder.deviceModel = call.argument("deviceModel") as string;
    } else {
      builder.deviceModel = "";
    }

    // 选填，默认开启，开启后 Bugly SDK 会打印更多调试日志，线上版本可关闭
    if (call.hasArgument("debugMode")) {
      builder.debugMode = call.argument("debugMode") as boolean;
    } else {
      builder.debugMode = true;
    }

    // 选填，延迟初始化时间，单位 ms
    if (call.hasArgument("initDelay")) {
      builder.initDelay = call.argument("initDelay") as number;
    } else {
      builder.initDelay = 0;
    }

    await Bugly.init(getContext(this), builder);   // 如果需等待Bugly完全初始化完成，使用await Bugly.init(context, builder);
    result.success("Bugly initialization successful");
  }

  // 设置用户 ID
  private setUserId(call: MethodCall, result: MethodResult): void {
    const userId = call.argument("userId") as string;
    Bugly.updateUserId(userId);
    result.success(null);
  }

  // 设置设备ID
  private setDeviceId(call: MethodCall, result: MethodResult): void {
    const deviceId = call.argument("deviceId") as string;
    Bugly.updateDeviceId(deviceId);
    result.success(null);
  }
  
  // 设置设备型号
  private setDeviceModel(call: MethodCall, result: MethodResult): void {
    const deviceModel = call.argument("deviceModel") as string;
    Bugly.updateDeviceModel(deviceModel);
    result.success(null);
  }

  // 设置设备型号
  private putUserData(call: MethodCall, result: MethodResult): void {
    const key = call.argument("key") as string;
    const value = call.argument("value") as string;
    Bugly.putUserData(key, value);
    result.success(null);
  }

  // 上报自定义异常
  private postCatchedException(call: MethodCall, result: MethodResult): void {
    let name: string | null = null;
    let message: string | null = null;
    let stack: string | null = null;

    if (call.hasArgument("crash_type")) {
      name = call.argument("crash_type") as string;
    }
    if (call.hasArgument("crash_message")) {
      message = call.argument("crash_message") as string;
    }
    if (call.hasArgument("crash_detail")) {
      stack = call.argument("crash_detail") as string;
    }

    Bugly.postCustomError(name, message, stack);
    result.success(null);
  }
}
