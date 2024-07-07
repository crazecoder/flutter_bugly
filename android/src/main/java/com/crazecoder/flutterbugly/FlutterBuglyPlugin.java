package com.crazecoder.flutterbugly;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.crazecoder.flutterbugly.bean.BuglyInitResultInfo;
import com.crazecoder.flutterbugly.utils.JsonUtil;
import com.crazecoder.flutterbugly.utils.MapUtil;
import com.tencent.bugly.crashreport.CrashReport;

import io.flutter.BuildConfig;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FlutterBuglyPlugin
 */
public class FlutterBuglyPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private Result result;
    private boolean isResultSubmitted = false;
    private static MethodChannel channel;
    @SuppressLint("StaticFieldLeak")
    private static Activity activity;
    private FlutterPluginBinding flutterPluginBinding;


    @Override
    public void onMethodCall(final MethodCall call, @NonNull final Result result) {
        isResultSubmitted = false;
        this.result = result;
        if (call.method.equals("initBugly")) {
            if (call.hasArgument("appId")) {
                String appId = call.argument("appId").toString();
                CrashReport.UserStrategy strategy = new CrashReport.UserStrategy(activity);
                setChannel(call, strategy);
                setDeviceID(call, strategy);
                setDeviceModel(call, strategy);
                setAppVersion(call, strategy);
                setAppPackageName(call, strategy);

                //设置Bugly初始化延迟
                if (call.hasArgument("initDelay")) {
                    long delay = Long.parseLong(call.argument("initDelay").toString());
                    strategy.setAppReportDelay(delay);
                }
                //设置anr时是否获取系统trace文件，默认为false
                if (call.hasArgument("enableCatchAnrTrace")) {
                    boolean enableCatchAnrTrace = call.argument("enableCatchAnrTrace");
                    strategy.setEnableCatchAnrTrace(enableCatchAnrTrace);
                }
                //设置是否获取anr过程中的主线程堆栈，默认为true
                if (call.hasArgument("enableRecordAnrMainStack")) {
                    boolean enableRecordAnrMainStack = call.argument("enableRecordAnrMainStack");
                    strategy.setEnableRecordAnrMainStack(enableRecordAnrMainStack);
                }
                CrashReport.initCrashReport(activity.getApplicationContext(), appId, BuildConfig.DEBUG);

                result(getResultBean(true, appId, "Bugly 初始化成功"));
            } else {
                result(getResultBean(false, null, "Bugly appId不能为空"));
            }
        } else if (call.method.equals("setUserId")) {
            if (call.hasArgument("userId")) {
                String userId = call.argument("userId");
                CrashReport.setUserId(activity.getApplicationContext(), userId);
            }
            result(null);
        } else if (call.method.equals("setUserTag")) {
            if (call.hasArgument("userTag")) {
                Integer userSceneTag = call.argument("userTag");
                if (userSceneTag != null)
                    CrashReport.setUserSceneTag(activity.getApplicationContext(), userSceneTag);
            }
            result(null);
        } else if (call.method.equals("setChannel")) {
            setChannel(call, null);
            result(null);
        } else if (call.method.equals("setDeviceID")) {
            setDeviceID(call, null);
            result(null);
        } else if (call.method.equals("setDeviceModel")) {
            setDeviceModel(call, null);
            result(null);
        } else if (call.method.equals("setAppVersion")) {
            setAppVersion(call, null);
            result(null);
        } else if (call.method.equals("setAppPackageName")) {
            setAppPackageName(call, null);
            result(null);
        } else if (call.method.equals("putUserData")) {
            if (call.hasArgument("key") && call.hasArgument("value")) {
                String userDataKey = call.argument("key");
                String userDataValue = call.argument("value");
                CrashReport.putUserData(activity.getApplicationContext(), userDataKey, userDataValue);
            }
            result(null);
        } else if (call.method.equals("postCatchedException")) {
            postException(call);
            result(null);
        } else {
            result.notImplemented();
            isResultSubmitted = true;
        }

    }

    /**
     * 配置APP渠道号
     */
    private void setChannel(final MethodCall call, CrashReport.UserStrategy strategy) {
        if (call.hasArgument("channel")) {
            String channel = call.argument("channel");
            if (!TextUtils.isEmpty(channel)) {
                if (strategy == null) {
                    CrashReport.setAppChannel(activity.getApplicationContext(), channel);
                } else {
                    strategy.setAppChannel(channel);
                }
            }
        }
    }

    /**
     * 设置设备id
     */
    private void setDeviceID(final MethodCall call, CrashReport.UserStrategy strategy) {
        if (call.hasArgument("deviceId")) {
            String deviceId = call.argument("deviceId");
            if (!TextUtils.isEmpty(deviceId)) {
                if (strategy == null) {
                    CrashReport.setDeviceId(activity.getApplicationContext(), deviceId);
                } else {
                    strategy.setDeviceID(deviceId);
                }
            }
        }
    }

    /**
     * 设置设备型号
     */
    private void setDeviceModel(final MethodCall call, CrashReport.UserStrategy strategy) {
        if (call.hasArgument("deviceModel")) {
            String deviceModel = call.argument("deviceModel");
            if (!TextUtils.isEmpty(deviceModel)) {
                if (strategy == null) {
                    CrashReport.setDeviceModel(activity.getApplicationContext(), deviceModel);
                } else {
                    strategy.setDeviceModel(deviceModel);
                }
            }
        }
    }

    /**
     * 设置App版本
     *
     * @param call
     */
    private void setAppVersion(final MethodCall call, CrashReport.UserStrategy strategy) {
        if (call.hasArgument("appVersion")) {
            String appVersion = call.argument("appVersion");
            if (!TextUtils.isEmpty(appVersion)) {
                if (strategy == null) {
                    CrashReport.setAppVersion(activity.getApplicationContext(), appVersion);
                } else {
                    strategy.setAppVersion(appVersion);
                }
            }
        }
    }

    /**
     * 设置App包名
     *
     * @param call
     */
    private void setAppPackageName(final MethodCall call, CrashReport.UserStrategy strategy) {
        if (call.hasArgument("appPackage")) {
            String appPackage = call.argument("appPackage");
            if (!TextUtils.isEmpty(appPackage)) {
                if (strategy == null) {
                    CrashReport.setAppPackage(activity.getApplicationContext(), appPackage);
                } else {
                    strategy.setAppPackageName(appPackage);
                }
            }
        }
    }

    private void postException(MethodCall call) {
        String message = "";
        String detail = null;
        if (call.hasArgument("crash_message")) {
            message = call.argument("crash_message");
        }
        if (call.hasArgument("crash_detail")) {
            detail = call.argument("crash_detail");
        }
        if (TextUtils.isEmpty(detail)) return;
        CrashReport.postException(8, "Flutter Exception", message, detail, null);

    }

    private void result(Object object) {
        if (result != null && !isResultSubmitted) {
            if (object == null) {
                result.success(null);
            } else {
                result.success(JsonUtil.toJson(MapUtil.deepToMap(object)));
            }
            isResultSubmitted = true;
        }
    }

    private BuglyInitResultInfo getResultBean(boolean isSuccess, String appId, String msg) {
        BuglyInitResultInfo bean = new BuglyInitResultInfo();
        bean.setSuccess(isSuccess);
        bean.setAppId(appId);
        bean.setMessage(msg);
        return bean;
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        this.flutterPluginBinding = binding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        flutterPluginBinding = null;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "crazecoder/flutter_bugly");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

    }

    @Override
    public void onDetachedFromActivity() {

    }
}