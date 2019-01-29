package com.crazecoder.flutterbugly;

import android.Manifest;
import android.app.Activity;
import android.os.Build;
import android.text.TextUtils;

import com.tencent.bugly.Bugly;
import com.tencent.bugly.beta.Beta;
import com.tencent.bugly.beta.UpgradeInfo;
import com.tencent.bugly.crashreport.CrashReport;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.content.PermissionChecker;
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
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!hasPermissions()) {
                ActivityCompat.requestPermissions(activity,
                        PERMISSIONS_BUGLY,
                        0);
            }
        }
    }
    private boolean hasPermissions() {
        for (String permission:PERMISSIONS_BUGLY){
            if(!hasPermission(permission)){
                return false;
            }
        }
        return true;
    }
    private boolean hasPermission(String permission) {
        return ContextCompat.checkSelfPermission(activity,permission) == PermissionChecker.PERMISSION_GRANTED;
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
                Beta.canShowUpgradeActs.add(activity.getClass());
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
        } else if (call.method.equals("postCatchedException")) {
            String message = "";
            String detail = null;
            if (call.hasArgument("crash_message")) {
                message = call.argument("crash_message");
            }
            if (call.hasArgument("crash_detail")) {
                detail = call.argument("crash_detail");
            }
            if (TextUtils.isEmpty(detail)) return;
            String[] details = detail.split("#");
            List<StackTraceElement> elements = new ArrayList<>();
            for (String s : details) {
                if (!TextUtils.isEmpty(s)) {
                    String methodName = null;
                    String fileName = null;
                    int lineNum = -1;
                    String[] contents = s.split(" \\(");
                    if (contents.length > 0) {
                        methodName = contents[0];
                        String packageContent = contents[1].replace(")", "");
                        String[] packageContentArray = packageContent.split("\\.dart:");
                        if (packageContentArray.length > 0) {
                            if (packageContentArray.length == 1) {
                                fileName = packageContentArray[0];
                            } else {
                                fileName = packageContentArray[0] + ".dart";
                                Pattern patternTrace = Pattern.compile("[1-9]\\d*");
                                Matcher m = patternTrace.matcher(packageContentArray[1]);
                                if (m.find()) {
                                    String lineNumStr = m.group();
                                    lineNum = Integer.parseInt(lineNumStr);
                                }
                            }
                        }
                    }
                    StackTraceElement element = new StackTraceElement("Dart", methodName, fileName, lineNum);
                    elements.add(element);
                }
            }
            StackTraceElement[] elementsArray = new StackTraceElement[elements.size()];
            Throwable throwable = new Throwable(message);
            throwable.setStackTrace(elements.toArray(elementsArray));
            CrashReport.postCatchedException(throwable);
            result.success(null);
        } else {
            result.notImplemented();
        }

    }

}
