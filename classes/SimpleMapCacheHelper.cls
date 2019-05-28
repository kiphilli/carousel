/**
 * @author anthony.beran@slalom.com
 * @date 6/25/18
 * @version 1.0
 * @description SimpleMapCacheHelper - A simplistic caching class for use when you need to execute an identical SOQL query in a loop
 */

public with sharing class SimpleMapCacheHelper {
    private static Map<String, String> cacheMap;

    static {
        SimpleMapCacheHelper.cacheMap = new Map<String, String>();
    }

    public static void set(String key, String value) {
        SimpleMapCacheHelper.cacheMap.put(key, value);
    }

    public static String get(String key) {
        return SimpleMapCacheHelper.cacheMap.get(key);
    }
}