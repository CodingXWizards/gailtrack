import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class HazardAlertSoundPlayer {
  static final HazardAlertSoundPlayer _instance = HazardAlertSoundPlayer._internal();
  factory HazardAlertSoundPlayer() => _instance;

  HazardAlertSoundPlayer._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playAlertSound({
    required String soundFilePath,
    required int duration,
    bool loop = true,
  }) async {
    try {
      // Method 1: Load from asset bytes
      ByteData soundData = await rootBundle.load(soundFilePath);
      Uint8List soundBytes = soundData.buffer.asUint8List();

      // Set audio source from bytes
      await _audioPlayer.setSourceBytes(soundBytes);

      // Set to loop if specified
      if (loop) {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      }

      // Play audio
      await _audioPlayer.play(BytesSource(soundBytes));

      // Stop after specified duration
      Future.delayed(Duration(seconds: duration), () {
        _audioPlayer.stop();
      });
    } catch (e) {
      // Fallback method: Try alternative sound loading
      try {
        await _audioPlayer.play(AssetSource(soundFilePath));

        if (loop) {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        }

        // Stop after duration
        Future.delayed(Duration(seconds: duration), () {
          _audioPlayer.stop();
        });
      } catch (alternativeError) {
        print('Error playing sound: $alternativeError');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}