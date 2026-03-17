# Flutter ProGuard/R8 Rules

# Google ML Kit Text Recognition script builders (to suppress missing class warnings)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# General ML Kit suppressions
-dontwarn com.google.android.gms.**
-dontwarn com.google.mlkit.**
-keep class com.google.mlkit.** { *; }

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Core suppressions
-dontwarn com.google.android.play.core.**
