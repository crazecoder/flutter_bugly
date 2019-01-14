package com.crazecoder.flutterbugly;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.support.annotation.RequiresApi;
import android.support.v4.app.ActivityCompat;
import android.util.Log;

import com.tencent.bugly.Bugly;
import com.tencent.bugly.beta.Beta;
import com.tencent.bugly.beta.UpgradeInfo;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterBuglyPlugin
 */
public class FlutterBuglyPlugin implements MethodCallHandler {
    private Activity activity;

    private static final String[] PERMISSIONS_BUGLY = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.ACCESS_NETWORK_STATE,
            Manifest.permission.ACCESS_WIFI_STATE,
            Manifest.permission.READ_LOGS,
            Manifest.permission.REQUEST_INSTALL_PACKAGES,
    };

    public FlutterBuglyPlugin(Activity activity) {
        this.activity = activity;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            ActivityCompat.requestPermissions(activity,
                    PERMISSIONS_BUGLY,
                    0);
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_bugly");
        channel.setMethodCallHandler(new FlutterBuglyPlugin(registrar.activity()));
    }

    @Override
    public void onMethodCall(final MethodCall call, final Result result) {
        if (call.method.equals("initBugly")) {
            if (call.hasArgument("appId")) {
                if (call.hasArgument("enableHotfix")) {
                    Beta.enableHotfix = call.argument("enableHotfix");
                }
                if (call.hasArgument("autoCheckUpgrade")) {
                    Beta.autoCheckUpgrade = call.argument("autoCheckUpgrade");
                }
                if (call.hasArgument("autoDownloadOnWifi")) {
                    Beta.autoDownloadOnWifi = call.argument("autoDownloadOnWifi");
                }
                if (call.hasArgument("initDelay")) {
                    int delay = call.argument("initDelay");
                    Beta.initDelay = delay * 1000;
                }
                if (call.hasArgument("enableNotification")) {
                    Beta.enableNotification = call.argument("enableNotification");
                }
                if (call.hasArgument("upgradeCheckPeriod")) {
                    int period = call.argument("upgradeCheckPeriod");
                    Beta.upgradeCheckPeriod = period * 1000;
                }
                if (call.hasArgument("showInterruptedStrategy")) {
                    Beta.showInterruptedStrategy = call.argument("showInterruptedStrategy");
                }
                if (call.hasArgument("canShowApkInfo")) {
                    Beta.canShowApkInfo = call.argument("canShowApkInfo");
                }
                Bugly.init(activity.getApplicationContext(), call.argument("appId").toString(), BuildConfig.DEBUG);
                result.success("Bugly 初始化成功");

            } else {
                result.success("Bugly key不能为空");
            }
        } else if (call.method.equals("checkUpgrade")) {
            boolean isManual = false;
            boolean isSilence = false;
            if (call.hasArgument("isManual")) {
                isManual = call.argument("isManual");
            }
            if (call.hasArgument("isSilence")) {
                isSilence = call.argument("isSilence");
            }
            Beta.checkUpgrade(isManual, isSilence);
            result.success(null);
        } else if (call.method.equals("upgradeListener")) {
            UpgradeInfo strategy = Beta.getUpgradeInfo();
            result.success(JsonUtil.toJson(MapUtil.deepToMap(strategy)));
        } else {
            result.notImplemented();
        }

    }

}
