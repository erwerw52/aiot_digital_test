import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/digital_human_service.dart';

class DigitalHumanPage extends StatefulWidget {
  const DigitalHumanPage({super.key});

  @override
  State<DigitalHumanPage> createState() => _DigitalHumanPageState();
}

class _DigitalHumanPageState extends State<DigitalHumanPage> {
  final DigitalHumanService _service = DigitalHumanService();
  StreamSubscription? _eventSubscription;
  String _statusText = '數字人就緒';

  @override
  void initState() {
    super.initState();
    _listenToEvents();
  }

  void _listenToEvents() {
    _eventSubscription = _service.eventStream.listen((event) {
      final type = event['type'] as String?;

      switch (type) {
        case 'play_start':
          setState(() {
            _statusText = '正在播放...';
          });
          break;

        case 'play_end':
          setState(() {
            _statusText = '播放完成';
          });
          break;

        case 'play_error':
          final error = event['error'] as String? ?? '未知錯誤';
          setState(() {
            _statusText = '播放錯誤: $error';
          });
          break;
      }
    });
  }

  // 播放 WAV 音頻檔案
  void _playWavAudio() async {
    try {
      setState(() {
        _statusText = '正在載入音頻...';
      });

      // 從 assets 載入音頻數據
      final audioData = await rootBundle.load('assets/wav/orea.wav');
      final bytes = audioData.buffer.asUint8List();

      // 傳遞音頻數據給 Android 端播放
      await _service.playAudioBytes(bytes, 'orea.wav');

      setState(() {
        _statusText = '正在播放音頻: orea.wav';
      });
    } catch (e) {
      _showSnackBar('播放音頻失敗: $e');
      setState(() {
        _statusText = '播放失敗';
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIoT 數字人'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 數字人顯示區域
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black12,
              child: Stack(
                children: [
                  // 原生 Android 渲染視圖
                  const AndroidView(
                    viewType: 'ai.guiji.duix/digital_human_view',
                    creationParamsCodec: StandardMessageCodec(),
                  ),
                  // 狀態顯示
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _playWavAudio,
                            icon: const Icon(Icons.volume_up),
                            label: const Text('播放音頻'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 控制面板
        ],
      ),
    );
  }
}
