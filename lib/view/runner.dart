import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:node_flutter/node_flutter.dart';

class ScriptRunnerScreen extends StatefulWidget {
  const ScriptRunnerScreen({super.key});

  @override
  State<ScriptRunnerScreen> createState() => _ScriptRunnerScreenState();
}

class _ScriptRunnerScreenState extends State<ScriptRunnerScreen> {
  final TextEditingController _codeController = TextEditingController();

  String _result = "";
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    Nodejs.onMessageReceived.listen((event) {
      final tag = event['channelName'];
      final msg = event['message'];

      if (tag == 'ok') {
        setState(() {
          _loading = false;
          _result = msg.toString();
        });
      }

      if (tag == 'error') {
        setState(() {
          _loading = false;
          _result = "ERROR:\n$msg";
        });
      }
    });
  }

  void _run() {
    setState(() {
      _loading = true;
      _result = "";
    });

    Nodejs.sendMessage(
      "run",
      jsonEncode({
        "code": _codeController.text,
        "input": ""
      }),
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
            Expanded(
              flex: 2,
              child: TextField(
                controller: _codeController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "输入JS代码（必须 ctx.result = xxx）",
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _run,
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
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}