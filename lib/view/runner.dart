import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:node_flutter/node_flutter.dart';

const String _defaultMainJs = """
const bridge = require('flutter-bridge');

bridge.on('run', (msg) => {
  try {
    const fn = new Function('return (' + msg + ')')();
    const result = fn();
    if (result && typeof result.then === 'function') {
      result
        .then(r => bridge.send('ok', String(r ?? '')))
        .catch(e => bridge.send('error', String(e?.message ?? e)));
    } else {
      bridge.send('ok', String(result ?? ''));
    }
  } catch(e) {
    bridge.send('error', String(e?.message ?? e));
  }
});
""";

const String _defaultScript = """
() => {
  return "Hello from Node.js! " + new Date().toISOString();
}
""";

class ScriptRunnerScreen extends StatefulWidget {
  const ScriptRunnerScreen({super.key});

  @override
  State<ScriptRunnerScreen> createState() => _ScriptRunnerScreenState();
}

class _ScriptRunnerScreenState extends State<ScriptRunnerScreen> {
  final TextEditingController _mainJsController =
  TextEditingController(text: _defaultMainJs);
  final TextEditingController _scriptController =
  TextEditingController(text: _defaultScript);
  final TextEditingController _resultController = TextEditingController();

  bool _nodeReady = false;

  @override
  void initState() {
    super.initState();
    Nodejs.onMessageReceived.listen((event) {
      if (!mounted) return;
      final tag = event['channelName'];
      final msg = event['message']?.toString() ?? '';
      if (tag == 'ok') {
        _resultController.text = msg;
      } else if (tag == 'error') {
        _resultController.text = 'Error:\n$msg';
      }
    });
  }

  Future<void> _startNode() async {
    try {
      final code = _mainJsController.text.trim();
      if (code.isEmpty) {
        _showError("main.js 不能为空");
        return;
      }
      await Nodejs.startWithScript(code);
      setState(() => _nodeReady = true);
      _resultController.text = 'Node.js 已启动';
    } catch (e) {
      _showError("启动失败: $e");
    }
  }

  void _runScript() {
    try {

      final script = _scriptController.text.trim();
      if (script.isEmpty) {
        _showError("脚本不能为空");
        return;
      }
      _resultController.text = '运行中...';
      Nodejs.sendMessage('run', script);
    } catch (e) {
      _showError("执行失败: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: GestureDetector(
          onTap: () => Clipboard.setData(ClipboardData(text: message)),
          child: Text(message),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainJsController.dispose();
    _scriptController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JS Runner")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _label("main.js（启动脚本）"),
            Expanded(
              flex: 3,
              child: _editor(_mainJsController, "main.js 内容"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNode,
                child: Text(_nodeReady ? "重新启动" : "启动 Node.js"),
              ),
            ),
            const SizedBox(height: 12),
            _label("执行脚本"),
            Expanded(
              flex: 2,
              child: _editor(_scriptController, "要执行的代码"),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _runScript,
                child: const Text("执行"),
              ),
            ),
            const SizedBox(height: 12),
            _label("结果"),
            Expanded(
              flex: 2,
              child: _editor(_resultController, "结果显示在这里", readOnly: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ),
  );

  Widget _editor(TextEditingController ctrl, String hint,
      {bool readOnly = false}) =>
      TextField(
        controller: ctrl,
        maxLines: null,
        expands: true,
        readOnly: readOnly,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: hint,
          filled: readOnly,
          fillColor: Colors.grey.withOpacity(0.08),
        ),
      );
}