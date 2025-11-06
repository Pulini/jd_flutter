# 华为HMS SDK 混淆规则
-keep class com.huawei.hms.** { *; }
-keep interface com.huawei.hms.** { *; }
-keep enum com.huawei.hms.** { *; }

# 保留华为HMS相关的类和方法不被混淆
-keep class com.huawei.hms.mlsdk.** { *; }
-keep class com.huawei.hms.mlkit.** { *; }
-keep class com.huawei.hms.livenessdetection.** { *; }
-keep class com.huawei.hms.faceverify.** { *; }

# 保留自定义Activity不被混淆
-keep class com.jd.pzx.jd_flutter.LivenFaceVerificationActivity { *; }

# 保留与人脸验证相关的类不被混淆
-keep class com.huawei.hms.mlsdk.common.MLFrame { *; }
-keep class com.huawei.hms.mlsdk.faceverify.** { *; }
-keep class com.huawei.hms.mlsdk.livenessdetection.** { *; }

# 保留Bitmap相关类不被混淆
-keep class android.graphics.Bitmap { *; }
-keep class android.graphics.BitmapFactory { *; }

# 保留极光推送相关类不被混淆
-dontwarn cn.jpush.**
-keep class cn.jpush.** { *; }