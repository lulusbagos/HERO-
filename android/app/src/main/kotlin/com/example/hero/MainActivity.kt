package com.example.hero

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationManager
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "hero/location_security"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"getSecureLocation" -> handleSecureLocation(result)
					else -> result.notImplemented()
				}
			}
	}

	private fun handleSecureLocation(result: MethodChannel.Result) {
		val hasFineLocation = ContextCompat.checkSelfPermission(
			this,
			Manifest.permission.ACCESS_FINE_LOCATION
		) == PackageManager.PERMISSION_GRANTED

		if (!hasFineLocation) {
			result.error("PERMISSION", "Location permission is required.", null)
			return
		}

		val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager

		val bestLocation = listOf(
			LocationManager.GPS_PROVIDER,
			LocationManager.NETWORK_PROVIDER,
			LocationManager.PASSIVE_PROVIDER
		)
			.filter { provider -> locationManager.isProviderEnabled(provider) }
			.mapNotNull { provider ->
				try {
					locationManager.getLastKnownLocation(provider)
				} catch (_: SecurityException) {
					null
				}
			}
			.maxByOrNull { location -> location.time }

		if (bestLocation == null) {
			result.error("NO_FIX", "Unable to read GPS coordinates.", null)
			return
		}

		val now = System.currentTimeMillis()
		val ageSeconds = (now - bestLocation.time).toDouble() / 1000.0

		val payload = hashMapOf<String, Any>(
			"latitude" to bestLocation.latitude,
			"longitude" to bestLocation.longitude,
			"accuracy" to bestLocation.accuracy.toDouble(),
			"speed" to bestLocation.speed.toDouble(),
			"timestamp" to bestLocation.time.toDouble(),
			"isMock" to isMock(bestLocation),
			"ageSeconds" to ageSeconds
		)

		result.success(payload)
	}

	private fun isMock(location: Location): Boolean {
		return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
			location.isMock
		} else {
			@Suppress("DEPRECATION")
			location.isFromMockProvider
		}
	}
}
