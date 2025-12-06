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

  // 播放隨機動作示範
  void _playRandomMotion() async {
    try {
      await _service.startRandomMotion(true);
      setState(() {
        _statusText = '正在播放隨機動作';
      });
    } catch (e) {
      _showSnackBar('播放動作失敗: $e');
    }
  }

  // 播放指定動作示範
  void _playMotion(String motionName) async {
    try {
      await _service.startMotion(motionName, true);
      setState(() {
        _statusText = '正在播放動作: $motionName';
      });
    } catch (e) {
      _showSnackBar('播放動作失敗: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                ],
              ),
            ),
          ),
          // 控制面板
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '動作控制',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _playRandomMotion,
                        icon: const Icon(Icons.shuffle),
                        label: const Text('隨機動作'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _playMotion('打招呼'),
                        icon: const Icon(Icons.waving_hand),
                        label: const Text('打招呼'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _playMotion('點頭'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('點頭'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
