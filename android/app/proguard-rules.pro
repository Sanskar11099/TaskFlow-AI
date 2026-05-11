# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }

# Google Fonts - keep font-related classes
-keep class com.google.android.gms.fonts.** { *; }

# Prevent R8 from stripping interface information
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
