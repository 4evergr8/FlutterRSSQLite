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

  Future<void> _runScript() async {
    try {
      final code = _codeController.text.trim();
      if (code.isEmpty) {
        _showError("代码不能为空");
        return;
      }
      await Nodejs.startWithScript(code);
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
      appBar: AppBar(title: const Text("JS Runner")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "输入JS代码",
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _runScript,
                child: const Text("执行"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}