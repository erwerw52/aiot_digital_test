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

  /// 監聽數字人事件（下載進度、初始化狀態、播放狀態等）
  Stream<Map<String, dynamic>> get eventStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
  }

  /// 獲取數字人視圖的 native view id
  Future<int?> getDigitalHumanViewId() async {
    try {
      final result = await _channel.invokeMethod<int>('getViewId');
      return result;
    } catch (e) {
      debugPrint('獲取視圖ID失敗: $e');
      return null;
    }
  }
}
