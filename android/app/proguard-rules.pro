# Keep FFmpeg Kit JNI bindings (R8 strips them in release and crashes on launch).
-keep class com.antonkarpenko.ffmpegkit.** { *; }
-keepclassmembers class com.antonkarpenko.ffmpegkit.** { *; }
-keepclasseswithmembernames class * {
    native <methods>;
}
-dontwarn com.antonkarpenko.ffmpegkit.**
