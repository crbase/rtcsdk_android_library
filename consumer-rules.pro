############RTCSDK混淆配置  begin############
-dontshrink
-dontoptimize
-ignorewarnings
-dontskipnonpubliclibraryclassmembers

-keep class * { native <methods>; }

-keep class com.rtc.sdk.** { *; }
-keep class com.rtc.sdk.model.** { *; }
-keep class com.rtc.tool.** { *; }
-keep class com.rtc.screencapture.** { *; }
-keep class com.rtc.usbcamera.** { *; }
-keep class org.crmedia.** { *; }
-keep class org.crmedia.clearvoice.** { *; }
-keep class org.crmedia.crvedemo.** { *; }

############RTCSDK混淆配置  end############