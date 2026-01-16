package com.mirimomekiku.wavvy

import android.media.audiofx.BassBoost
import android.media.audiofx.PresetReverb
import android.media.audiofx.Virtualizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.mirimomekiku.wavvy/audio_effects"
    
    // Effects
    private var bassBoost: BassBoost? = null
    private var virtualizer: Virtualizer? = null
    private var presetReverb: PresetReverb? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initEffects" -> {
                    val sessionId = call.argument<Int>("sessionId") ?: 0
                    initAudioEffects(sessionId)
                    result.success(null)
                }
                "setBassBoost" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    setBassBoostStrength(strength)
                    result.success(null)
                }
                "setVirtualizer" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    setVirtualizerStrength(strength)
                    result.success(null)
                }
                "setReverb" -> {
                    val preset = call.argument<String>("preset") ?: "None"
                    setReverbPreset(preset)
                    result.success(null)
                }
                "releaseEffects" -> {
                    releaseAudioEffects()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun initAudioEffects(sessionId: Int) {
        // Release existing first to avoid leaks
        releaseAudioEffects()

        try {
            bassBoost = BassBoost(0, sessionId)
            bassBoost?.enabled = false // Start disabled

            virtualizer = Virtualizer(0, sessionId)
            virtualizer?.enabled = false

            presetReverb = PresetReverb(0, sessionId)
            presetReverb?.enabled = false
        } catch (e: Exception) {
            println("Error initializing audio effects: ${e.message}")
        }
    }

    private fun setBassBoostStrength(strength: Int) {
        bassBoost?.let {
            if (strength > 0) {
                it.enabled = true
                it.setStrength(strength.toShort())
            } else {
                it.enabled = false
            }
        }
    }

    private fun setVirtualizerStrength(strength: Int) {
        virtualizer?.let {
            if (strength > 0) {
                it.enabled = true
                it.setStrength(strength.toShort())
            } else {
                it.enabled = false
            }
        }
    }

    private fun setReverbPreset(presetName: String) {
        presetReverb?.let {
            if (presetName == "None") {
                it.enabled = false
                return
            }
            
            it.enabled = true
            val preset = when (presetName) {
                "SmallRoom" -> PresetReverb.PRESET_SMALLROOM
                "MediumRoom" -> PresetReverb.PRESET_MEDIUMROOM
                "LargeRoom" -> PresetReverb.PRESET_LARGEROOM
                "MediumHall" -> PresetReverb.PRESET_MEDIUMHALL
                "LargeHall" -> PresetReverb.PRESET_LARGEHALL
                "Plate" -> PresetReverb.PRESET_PLATE
                else -> PresetReverb.PRESET_NONE
            }
            it.preset = preset
        }
    }

    private fun releaseAudioEffects() {
        bassBoost?.release()
        bassBoost = null
        virtualizer?.release()
        virtualizer = null
        presetReverb?.release()
        presetReverb = null
    }
}
