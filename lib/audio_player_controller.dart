import 'package:just_audio/just_audio.dart';

class AudioPlayerController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Future<void> initAudio() async {
    await _audioPlayer.setAsset('assets/Malmo Sunrise.mp3');
    await _audioPlayer.setLoopMode(LoopMode.all); // 設定循環播放
    await _audioPlayer.setVolume(0.1); // 設定音量為 10%
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
