import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:node_flutter/node_flutter.dart';

class ScriptRunnerScreen extends StatefulWidget {
  const ScriptRunnerScreen({super.key});

  @override
  State<ScriptRunnerScreen> createState() => _ScriptRunnerScreenState();
}

class _ScriptRunnerScreenState extends State<ScriptRunnerScreen> {
  final TextEditingController _codeController = TextEditingController();

  String _result = "";
  String _nodeStatus = "未启动";
  bool _loading = false;
  bool _nodeReady = false;

  @override
  void initState() {
    super.initState();

    Nodejs.onMessageReceived.listen((event) {
      try {
        final tag = event['channelName'];
        final msg = event['message'];

        if (!mounted) return;

        if (tag == 'ok') {
          setState(() {
            _loading = false;
            _result = msg?.toString() ?? "";
          });
          return;
        }

        if (tag == 'error') {
          setState(() {
            _loading = false;
            _result = "Node Error:\n${msg?.toString() ?? ""}";
          });
          return;
        }

      } catch (e) {
        _showError("消息解析失败: $e");
      }
    });
  }

  Future<void> _startNode() async {
    try {
      setState(() {
        _nodeStatus = "启动中...";
      });

      await Nodejs.start();

      setState(() {
        _nodeReady = true;
        _nodeStatus = "已启动";
      });

    } catch (e) {
      setState(() {
        _nodeStatus = "启动失败";
      });

      _showError("Node启动失败: $e");
    }
  }

  void _runScript() {
    try {
      if (!_nodeReady) {
        _showError("Node未启动");
        return;
      }

      final code = _codeController.text.trim();

      if (code.isEmpty) {
        _showError("代码不能为空");
        return;
      }

      setState(() {
        _loading = true;
        _result = "";
      });

      Nodejs.sendMessage(
        "run",
        jsonEncode({
          "code": code,
          "input": ""
        }),
      );

    } catch (e) {
      setState(() {
        _loading = false;
      });

      _showError("执行失败: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: message));
          },
          child: Text(message),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("JS Runner"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text("Node状态: $_nodeStatus"),
                const SizedBox(width: 10),

                ElevatedButton(
                  onPressed: _nodeReady ? null : _startNode,
                  child: const Text("启动Node"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              flex: 2,
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "输入JS代码（ctx.result = xxx）",
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _runScript,
                child: Text(_loading ? "运行中..." : "执行"),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_result.isEmpty ? "无结果" : _result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
