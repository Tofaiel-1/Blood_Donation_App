# Keep Firebase model classes' required members
-keepclassmembers class com.google.firebase.** { *; }
-keep class com.google.firebase.** { *; }

# Keep Flutter classes used via reflection
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }

# Allow proguard to remove logging
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
