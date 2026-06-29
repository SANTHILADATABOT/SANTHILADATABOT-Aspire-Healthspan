# Flutter default rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Huawei HMS rules
-dontwarn com.huawei.**
-keep class com.huawei.** { *; }

# BouncyCastle rules
-dontwarn org.bouncycastle.**
-keep class org.bouncycastle.** { *; }

# Gson rules
-keep class com.google.gson.** { *; }

# OkHttp rules
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Cling SDK rules
-keep class com.hicling.clingsdk.** { *; }

# Google Play Core and Flutter Deferred Components rules
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Additional missing classes from the error log
-dontwarn com.huawei.android.os.BuildEx$VERSION
-dontwarn com.huawei.hianalytics.**
-dontwarn com.huawei.libcore.io.**
