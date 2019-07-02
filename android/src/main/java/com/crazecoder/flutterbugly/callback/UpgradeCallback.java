package com.crazecoder.flutterbugly.callback;

import com.tencent.bugly.beta.UpgradeInfo;

public interface UpgradeCallback {
    void onUpgrade(UpgradeInfo strategy);
}
