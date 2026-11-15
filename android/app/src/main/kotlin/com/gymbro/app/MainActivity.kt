package com.gymbro.app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(), SensorEventListener {
    private val CHANNEL = "com.gymbro.app/device_info"
    private var sensorManager: SensorManager? = null
    private var hingeSensor: Sensor? = null
    private var currentHingeAngle: Float? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        initHingeSensor()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    try {
                        val info = getDeviceCapabilities()
                        result.success(info)
                    } catch (e: Exception) {
                        result.error("DEVICE_INFO_ERROR", e.message, null)
                    }
                }
                "getFoldableCapabilities" -> {
                    try {
                        val capabilities = getFoldableCapabilities()
                        result.success(capabilities)
                    } catch (e: Exception) {
                        result.error("FOLDABLE_INFO_ERROR", e.message, null)
                    }
                }
                "getHingeAngle" -> {
                    result.success(currentHingeAngle?.toDouble())
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                            }
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        // Fallback to general battery settings
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("BATTERY_SETTING_ERROR", e2.message, null)
                        }
                    }
                }
                "openAutostartSettings" -> {
                    val opened = openManufacturerAutostartSettings()
                    result.success(opened)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getDeviceCapabilities(): Map<String, Any?> {
        val manufacturer = Build.MANUFACTURER ?: ""
        val isXiaomi = manufacturer.equals("Xiaomi", ignoreCase = true) ||
                       manufacturer.equals("Redmi", ignoreCase = true) ||
                       manufacturer.equals("POCO", ignoreCase = true)
        val isSamsung = manufacturer.equals("Samsung", ignoreCase = true)
        val isPixel = manufacturer.equals("Google", ignoreCase = true)

        val miuiVersion = getSystemProperty("ro.miui.ui.version.name")
        val miuiCode = getSystemProperty("ro.miui.ui.version.code")
        val hyperOsProp = getSystemProperty("ro.hyperos.version")
        val buildIncremental = Build.VERSION.INCREMENTAL ?: ""

        val isHyperOs = isXiaomi && (
            hyperOsProp != null ||
            (miuiCode != null && miuiCode.toIntOrNull() ?: 0 >= 14) ||
            buildIncremental.contains("OS1.", ignoreCase = true) ||
            buildIncremental.contains("OS2.", ignoreCase = true)
        )

        val oneUiVersion = getSamsungOneUiVersion()

        val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
        val isIgnoringBatteryOptimizations = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && powerManager != null) {
            powerManager.isIgnoringBatteryOptimizations(packageName)
        } else {
            true
        }

        val notificationsEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()

        val canScheduleExactAlarms = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager
            alarmManager?.canScheduleExactAlarms() ?: false
        } else {
            true
        }

        return mapOf(
            "manufacturer" to manufacturer,
            "model" to (Build.MODEL ?: ""),
            "brand" to (Build.BRAND ?: ""),
            "device" to (Build.DEVICE ?: ""),
            "androidVersion" to (Build.VERSION.RELEASE ?: ""),
            "sdkInt" to Build.VERSION.SDK_INT,
            "isXiaomi" to isXiaomi,
            "isHyperOs" to isHyperOs,
            "miuiVersion" to miuiVersion,
            "hyperOsVersion" to (hyperOsProp ?: if (isHyperOs) buildIncremental else null),
            "isSamsung" to isSamsung,
            "oneUiVersion" to oneUiVersion,
            "isPixel" to isPixel,
            "isIgnoringBatteryOptimizations" to isIgnoringBatteryOptimizations,
            "areNotificationsEnabled" to notificationsEnabled,
            "canScheduleExactAlarms" to canScheduleExactAlarms
        )
    }

    private fun getSamsungOneUiVersion(): String? {
        val semPlatform = getSystemProperty("ro.build.version.oneui")
            ?: getSystemProperty("ro.build.version.sep")
        if (semPlatform != null) return semPlatform

        return try {
            val semField = Build.VERSION::class.java.getDeclaredField("SEM_PLATFORM_INT")
            semField.isAccessible = true
            val versionInt = semField.getInt(null)
            val major = versionInt / 10000
            val minor = (versionInt % 10000) / 100
            "One UI $major.$minor"
        } catch (e: Exception) {
            null
        }
    }

    private fun getSystemProperty(propName: String): String? {
        return try {
            val clazz = Class.forName("android.os.SystemProperties")
            val getMethod = clazz.getMethod("get", String::class.java)
            val value = getMethod.invoke(null, propName) as? String
            if (!value.isNullOrBlank()) value else null
        } catch (e: Exception) {
            null
        }
    }

    private fun openManufacturerAutostartSettings(): Boolean {
        val intents = arrayOf(
            // Xiaomi / HyperOS / MIUI
            Intent().setComponent(android.content.ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")),
            Intent().setComponent(android.content.ComponentName("com.miui.securitycenter", "com.miui.powercenter.PowerSettings")),
            // Samsung
            Intent().setComponent(android.content.ComponentName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity")),
            Intent().setComponent(android.content.ComponentName("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity")),
            // Generic App Info fallback
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        )

        for (intent in intents) {
            try {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                return true
            } catch (e: Exception) {
                // Try next
            }
        }
        return false
    }

    private fun initHingeSensor() {
        try {
            sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
            if (sensorManager != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                // Sensor.TYPE_HINGE_ANGLE is 36
                hingeSensor = sensorManager?.getDefaultSensor(36)
                if (hingeSensor != null) {
                    sensorManager?.registerListener(this, hingeSensor, SensorManager.SENSOR_DELAY_NORMAL)
                }
            }
        } catch (e: Exception) {
            // Silently ignore if sensor is not accessible
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event != null && event.sensor.type == 36 && event.values.isNotEmpty()) {
            currentHingeAngle = event.values[0]
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        // No-op
    }

    override fun onDestroy() {
        try {
            sensorManager?.unregisterListener(this)
        } catch (e: Exception) {
            // Ignore
        }
        super.onDestroy()
    }

    private fun getFoldableCapabilities(): Map<String, Any?> {
        val pm = packageManager
        val hasHingeSensorFeature = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            pm.hasSystemFeature("android.hardware.sensor.hinge_angle")
        } else false

        val hasSecFoldableDual = pm.hasSystemFeature("com.sec.feature.foldable_dual_display")
        val hasSecFoldableSingle = pm.hasSystemFeature("com.sec.feature.foldable_single_display")
        val hasHingeAngleSensor = hingeSensor != null

        val model = (Build.MODEL ?: "").uppercase()
        val device = (Build.DEVICE ?: "").uppercase()
        val brand = (Build.BRAND ?: "").uppercase()

        // Samsung Galaxy Z Fold family (SM-F9xx and regional W-series models)
        val isSamsungFold = model.contains("SM-F9") || model.contains("SM-W20") ||
                model.contains("SM-W21") || model.contains("SM-W22") ||
                model.contains("SM-W23") || model.contains("SM-W24") || model.contains("SM-W25")

        // Samsung Galaxy Z Flip (SM-F700..SM-F741)
        val isSamsungFlip = model.contains("SM-F7")

        // Google Pixel Fold / Pixel 9 Pro Fold
        val isPixelFold = model.contains("PIXEL FOLD") || model.contains("PIXEL 9 PRO FOLD") ||
                device.contains("FELIX") || device.contains("COMET")

        // Xiaomi MIX Fold / MIX Flip
        val isXiaomiFold = model.contains("MIX FOLD") || model.contains("MIX FLIP") ||
                device.contains("CETUS") || device.contains("ZIZHAN") ||
                device.contains("BABYLON") || device.contains("GOKU")

        // OnePlus Open / Oppo Find N series
        val isOnePlusOpen = model.contains("CPH2551") || model.contains("ONEPLUS OPEN") ||
                model.contains("FIND N")

        // Motorola Razr foldables
        val isMotoRazr = model.contains("RAZR") || model.contains("XT2071") ||
                model.contains("XT2321") || model.contains("XT2453")

        val matchedModel = isSamsungFold || isSamsungFlip || isPixelFold ||
                isXiaomiFold || isOnePlusOpen || isMotoRazr

        val isFoldableHardware = hasHingeSensorFeature || hasSecFoldableDual ||
                hasSecFoldableSingle || hasHingeAngleSensor || matchedModel

        val foldType = when {
            isSamsungFlip || (isMotoRazr && !model.contains("FOLD")) || hasSecFoldableSingle -> "clamshell"
            isSamsungFold || isPixelFold || isXiaomiFold || isOnePlusOpen || hasSecFoldableDual -> "book"
            isFoldableHardware -> "book"
            else -> "none"
        }

        val hardwareFeatures = mutableListOf<String>()
        if (hasHingeSensorFeature) hardwareFeatures.add("android.hardware.sensor.hinge_angle")
        if (hasSecFoldableDual) hardwareFeatures.add("com.sec.feature.foldable_dual_display")
        if (hasSecFoldableSingle) hardwareFeatures.add("com.sec.feature.foldable_single_display")
        if (hasHingeAngleSensor) hardwareFeatures.add("Sensor.TYPE_HINGE_ANGLE")
        if (matchedModel) hardwareFeatures.add("OEM_FOLDABLE_MODEL_MATCH")

        return mapOf(
            "isFoldableHardware" to isFoldableHardware,
            "foldType" to foldType,
            "hasHingeSensor" to (hasHingeAngleSensor || hasHingeSensorFeature),
            "hingeAngle" to currentHingeAngle?.toDouble(),
            "hardwareFeatures" to hardwareFeatures,
            "deviceModel" to model,
            "deviceBrand" to brand
        )
    }
}
