package com.crazecoder.flutterbugly.utils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

/**
 * Note of this class.
 *
 * @author crazecoder
 * @since 2018/12/28
 */
public class JsonUtil {
    public static String toJson(Map<String, Object> map) {
        JSONObject jsonObject = new JSONObject();
        try {
            for (Map.Entry<String, Object> entry : map.entrySet()) {
                jsonObject.put(entry.getKey(), entry.getValue());
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return jsonObject.toString();
    }
}
