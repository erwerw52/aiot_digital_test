import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 數字人服務類，負責與 Android 原生端的 DUIX SDK 通訊
class DigitalHumanService {
  static const MethodChannel _channel = MethodChannel('ai.guiji.duix/digital_human');
  static const EventChannel _eventChannel = EventChannel('ai.guiji.duix/digital_human_events');

  /// 檢查基礎配置是否已下載
  Future<bool> checkBaseConfig() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkBaseConfig');
      return result ?? false;
    } catch (e) {
      debugPrint('檢查基礎配置失敗: $e');
      return false;
    }
  }

  /// 檢查模型是否已下載
  Future<bool> checkModel(String modelName) async {
    try {
      final result = await _channel.invokeMethod<bool>('checkModel', {'modelName': modelName});
      return result ?? false;
    } catch (e) {
      debugPrint('檢查模型失敗: $e');
      return false;
    }
  }

  /// 下載基礎配置
  Future<void> downloadBaseConfig(String url) async {
    try {
      await _channel.invokeMethod('downloadBaseConfig', {'url': url});
    } catch (e) {
      debugPrint('下載基礎配置失敗: $e');
      rethrow;
    }
  }

  /// 下載模型
  Future<void> downloadModel(String modelUrl) async {
    try {
      await _channel.invokeMethod('downloadModel', {'modelUrl': modelUrl});
    } catch (e) {
      debugPrint('下載模型失敗: $e');
      rethrow;
    }
  }

  /// 初始化數字人
  Future<bool> initDigitalHuman(String modelName) async {
    try {
      final result = await _channel.invokeMethod<bool>('initDigitalHuman', {'modelName': modelName});
      return result ?? false;
    } catch (e) {
      debugPrint('初始化數字人失敗: $e');
      return false;
    }
  }

  /// 釋放數字人資源
  Future<void> release() async {
    try {
      await _channel.invokeMethod('release');
    } catch (e) {
      debugPrint('釋放資源失敗: $e');
    }
  }

  /// 播放音頻（WAV 格式）
  Future<void> playAudio(String wavPath) async {
    try {
      await _channel.invokeMethod('playAudio', {'wavPath': wavPath});
    } catch (e) {
      debugPrint('播放音頻失敗: $e');
      rethrow;
    }
  }
  /// 播放音頻字節數據
  Future<void> playAudioBytes(Uint8List audioBytes, String fileName) async {
    try {
      await _channel.invokeMethod('playAudioBytes', {
        'audioBytes': audioBytes,
        'fileName': fileName,
      });
    } catch (e) {
      debugPrint('播放音頻字節失敗: $e');
      rethrow;
    }
  }
  /// 停止音頻播放
  Future<void> stopAudio() async {
    try {
      await _channel.invokeMethod('stopAudio');
    } catch (e) {
      debugPrint('停止音頻失敗: $e');
    }
  }

  /// 播放指定動作
  Future<void> startMotion(String motionName, bool immediate) async {
    try {
      await _channel.invokeMethod('startMotion', {
        'motionName': motionName,
        'immediate': immediate,
      });
    } catch (e) {
      debugPrint('播放動作失敗: $e');
      rethrow;
    }
  }

  /// 隨機播放動作
  Future<void> startRandomMotion(bool immediate) async {
    try {
      await _channel.invokeMethod('startRandomMotion', {'immediate': immediate});
    } catch (e) {
      debugPrint('隨機播放動作失敗: $e');
      rethrow;
    }
  }

  /// 獲取可用動作列表
  Future<List<String>> getAvailableMotions() async {
    try {
      final result = await _channel.invokeMethod<List>('getAvailableMotions');
      return result?.cast<String>() ?? [];
    } catch (e) {
      debugPrint('獲取可用動作失敗: $e');
      return [];
    }
  }

  /// 檢查數字人是否已準備好
  Future<bool> isReady() async {
    try {
      final result = await _channel.invokeMethod<bool>('isReady');
      return result ?? false;
    } catch (e) {
      debugPrint('檢查就緒狀態失敗: $e');
      return false;
    }
  }

  /// 設置音量（0.0 - 1.0）
  Future<void> setVolume(double volume) async {
    try {
      await _channel.invokeMethod('setVolume', {'volume': volume});
    } catch (e) {
      debugPrint('設置音量失敗: $e');
    }
  }

  /// 開始推送音頻流
  Future<void> startPush() async {
    try {
      await _channel.invokeMethod('startPush');
    } catch (e) {
      debugPrint('開始推送失敗: $e');
    }
  }

  /// 推送 PCM 音頻數據
  Future<void> pushPcm(Uint8List pcmData) async {
    try {
      await _channel.invokeMethod('pushPcm', {'pcmData': pcmData});
    } catch (e) {
      debugPrint('推送音頻數據失敗: $e');
    }
  }

  /// 停止推送音頻流
  Future<void> stopPush() async {
    try {
      await _channel.invokeMethod('stopPush');
    } catch (e) {
      debugPrint('停止推送失敗: $e');
    }
  }

  /// 監聽數字人事件（下載進度、初始化狀態、播放狀態等）
  Stream<Map<String, dynamic>> get eventStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }
}
