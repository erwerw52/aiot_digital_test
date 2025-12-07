import 'package:aiot_digital_test/digital/digital_human_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/digital_human_service.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  final DigitalHumanService _service = DigitalHumanService();
  String _statusMessage = '正在檢查資源...';
  double _progress = 0.0;
  StreamSubscription? _eventSubscription;

  // Duix 數字人模型下載 URL
  // 基礎配置是必須的，包含必要的資源文件
  final String baseConfigUrl = 'https://github.com/GuijiAI/duix.ai/releases/download/v1.0.0/gj_dh_res.zip';
  final String modelUrl = 'https://github.com/duixcom/Duix.mobile/releases/download/v2.0.1/Lily.zip';
  final String modelName = 'Lily';  // 使用解壓後的目錄名稱（不含 .zip）

  @override
  void initState() {
    super.initState();
    _initDigitalHuman();
  }

  Future<void> _initDigitalHuman() async {
    // 監聽事件
    _eventSubscription = _service.eventStream.listen((event) {
      final type = event['type'] as String?;
      
      switch (type) {
        case 'download_progress':
          final current = event['current'] as int? ?? 0;
          final total = event['total'] as int? ?? 1;
          final category = event['category'] as String? ?? '';
          setState(() {
            _progress = current / total;
            _statusMessage = '正在下載 $category: ${(_progress * 100).toStringAsFixed(1)}%';
          });
          break;
          
        case 'unzip_progress':
          final current = event['current'] as int? ?? 0;
          final total = event['total'] as int? ?? 1;
          final category = event['category'] as String? ?? '';
          setState(() {
            _progress = current / total;
            _statusMessage = '正在解壓 $category: ${(_progress * 100).toStringAsFixed(1)}%';
          });
          break;
          
        case 'download_complete':
          final category = event['category'] as String? ?? '';
          setState(() {
            _statusMessage = '$category 下載完成';
          });
          break;
          
        case 'init_ready':
          setState(() {
            _statusMessage = '初始化完成';
          });
          _navigateToDigitalHumanPage();
          break;
          
        case 'init_error':
          final error = event['error'] as String? ?? '未知錯誤';
          setState(() {
            _statusMessage = '初始化失敗: $error';
          });
          _showErrorDialog(error);
          break;
          
        case 'download_fail':
          final error = event['error'] as String? ?? '未知錯誤';
          setState(() {
            _statusMessage = '下載失敗: $error';
          });
          _showErrorDialog(error);
          break;
      }
    });

    try {
      // 1. 檢查基礎配置（必須的資源文件）
      setState(() {
        _statusMessage = '正在檢查基礎配置...';
        _progress = 0.1;
      });
      
      bool hasBaseConfig = await _service.checkBaseConfig();
      if (!hasBaseConfig) {
        setState(() {
          _statusMessage = '正在下載基礎配置 (gj_dh_res)...';
        });
        await _service.downloadBaseConfig(baseConfigUrl);
      }

      // 2. 檢查模型
      setState(() {
        _statusMessage = '正在檢查模型...';
        _progress = 0.3;
      });
      
      bool hasModel = await _service.checkModel(modelName);
      if (!hasModel) {
        setState(() {
          _statusMessage = '正在下載模型...';
        });
        await _service.downloadModel(modelUrl);
      }

      // 3. 初始化數字人
      setState(() {
        _statusMessage = '正在初始化數字人...';
        _progress = 0.8;
      });
      
      bool success = await _service.initDigitalHuman(modelName);
      
      if (!success) {
        setState(() {
          _statusMessage = '初始化失敗';
        });
        _showErrorDialog('數字人初始化失敗，請檢查模型檔案是否完整');
      }
      // 成功的話會在 init_ready 事件中跳轉
    } catch (e) {
      setState(() {
        _statusMessage = '錯誤: $e';
      });
      _showErrorDialog(e.toString());
    }
  }

  void _navigateToDigitalHumanPage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DigitalHumanPage()),
        );
      }
    });
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('錯誤'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initDigitalHuman(); // 重試
            },
            child: const Text('重試'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('關閉'),
          ),
        ],
      ),
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AIoT 數字人',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              if (_progress > 0) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
