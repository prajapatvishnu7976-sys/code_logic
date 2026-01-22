# Razorpay Fix
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Google Play Services & Ads Fix
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Firebase Fix
-keep class com.google.firebase.** { *; }

# Flutter Native Splash Fix (Anti-Stuck)
-keep class net.jonhanson.flutter_native_splash.** { *; }