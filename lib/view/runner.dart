import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:node_flutter/node_flutter.dart';

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
  final TextEditingController _scriptController =
  TextEditingController(text: _defaultScript);

  final TextEditingController _resultController = TextEditingController();

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
      await Nodejs.start();

      _resultController.text = 'Node.js started';
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
          onTap: () =>
              Clipboard.setData(ClipboardData(text: message)),
          child: Text(message),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startNode,
                child: const Text("启动 Node.js"),
              ),
            ),
            const SizedBox(height: 12),
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
            Expanded(
              flex: 2,
              child: _editor(
                _resultController,
                "结果显示在这里",
                readOnly: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _editor(
      TextEditingController ctrl,
      String hint, {
        bool readOnly = false,
      }) =>
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