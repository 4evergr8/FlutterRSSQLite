import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class NodeRunnerScreen extends StatefulWidget {
  const NodeRunnerScreen({super.key});

  @override
  State<NodeRunnerScreen> createState() => _NodeRunnerScreenState();
}

class _NodeRunnerScreenState extends State<NodeRunnerScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _paramController = TextEditingController();


  String _output = "";
  bool _running = false;

  Future<String> _getNodeDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final nodeDir = Directory('${dir.path}/node');
    if (!await nodeDir.exists()) {
      await nodeDir.create(recursive: true);
    }
    return nodeDir.path;
  }

  Future<void> _runNode() async {
    setState(() {
      _running = true;
      _output = "";
    });

    try {
      final nodeDir = await _getNodeDir();

      final jsFile = File('$nodeDir/index.js');
      await jsFile.writeAsString(_codeController.text);

      final param = _paramController.text;

      final result = await Process.run(
        'node',
        ['index.js', param],
        workingDirectory: nodeDir,
      );

      final stdout = result.stdout.toString();
      final stderr = result.stderr.toString();

      setState(() {
        _output = stdout + "\n" + stderr;
      });
    } catch (e) {
      setState(() {
        _output = e.toString();
      });
    } finally {
      setState(() {
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Node 运行器")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _codeController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "JS代码",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _paramController,
              decoration: const InputDecoration(
                labelText: "参数",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _running ? null : _runNode,
              child: Text(_running ? "运行中..." : "运行"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(_output),
              ),
            ),
          ],
        ),
      ),
    );
  }
}