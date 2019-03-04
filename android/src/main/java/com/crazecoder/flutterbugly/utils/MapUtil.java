package com.crazecoder.flutterbugly.utils;


import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;

public class MapUtil {

    public static Map<String, Object> deepToMap(Object bean) {
        Map<String, Object> map = new LinkedHashMap<>();
        try {
            putValues(bean, map, null);
        } catch (IllegalAccessException x) {
            throw new IllegalArgumentException(x);
        }
        return map;
    }

    private static void putValues(Object bean,
                                  Map<String, Object> map,
                                  String prefix)
            throws IllegalAccessException {
        if (bean == null) return;
        Class<?> cls = bean.getClass();

        for (Field field : cls.getDeclaredFields()) {
            if (field.isSynthetic() || Modifier.isStatic(field.getModifiers()))
                continue;
            field.setAccessible(true);

            Object value = field.get(bean);
            String key;
            if (prefix == null) {
                key = field.getName();
            } else {
                key = prefix + "." + field.getName();
            }

            if (isValue(value)) {
                map.put(key, value);
            } else {
                putValues(value, map, key);
            }
        }
    }

    private static final Set<Class<?>> VALUE_CLASSES =
            Collections.unmodifiableSet(new HashSet<>(Arrays.asList(
                    Object.class, String.class, Boolean.class,
                    Character.class, Byte.class, Short.class,
                    Integer.class, Long.class, Float.class,
                    Double.class
                    // etc.
            )));

    private static boolean isValue(Object value) {
        return value == null
                || value instanceof Enum<?>
                || VALUE_CLASSES.contains(value.getClass());
    }
}

