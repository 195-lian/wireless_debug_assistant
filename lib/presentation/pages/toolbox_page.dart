import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class ToolboxPage extends StatefulWidget {
  const ToolboxPage({super.key});

  @override
  State<ToolboxPage> createState() => _ToolboxPageState();
}

class _ToolboxPageState extends State<ToolboxPage> {
  int _selectedTool = 0;

  final List<_ToolItem> _tools = [
    _ToolItem(icon: Icons.swap_horiz, label: '编码转换', page: const _EncodingTool()),
    _ToolItem(icon: Icons.verified, label: '校验计算', page: const _ChecksumTool()),
    _ToolItem(icon: Icons.data_object, label: 'JSON 格式化', page: const _JsonTool()),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _selectedTool,
          onDestinationSelected: (index) => setState(() => _selectedTool = index),
          labelType: NavigationRailLabelType.all,
          backgroundColor: AppColors.bgSecondary,
          selectedIconTheme: const IconThemeData(color: AppColors.accent),
          selectedLabelTextStyle: const TextStyle(color: AppColors.accent),
          unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
          unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary),
          destinations: _tools
              .map((t) => NavigationRailDestination(icon: Icon(t.icon), label: Text(t.label)))
              .toList(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _tools[_selectedTool].page),
      ],
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final Widget page;

  _ToolItem({required this.icon, required this.label, required this.page});
}

class _EncodingTool extends StatefulWidget {
  const _EncodingTool();

  @override
  State<_EncodingTool> createState() => _EncodingToolState();
}

class _EncodingToolState extends State<_EncodingTool> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  String _mode = 'hex';

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text;
    if (input.isEmpty) return;

    try {
      switch (_mode) {
        case 'hex':
          final bytes = utf8.encode(input);
          _outputController.text = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
        case 'base64':
          _outputController.text = base64Encode(utf8.encode(input));
        case 'url':
          _outputController.text = Uri.encodeComponent(input);
        case 'ascii':
          final bytes = utf8.encode(input);
          _outputController.text = bytes.join(' ');
      }
    } catch (e) {
      _outputController.text = 'Error: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'hex', label: Text('HEX')),
              ButtonSegment(value: 'base64', label: Text('Base64')),
              ButtonSegment(value: 'url', label: Text('URL')),
              ButtonSegment(value: 'ascii', label: Text('ASCII')),
            ],
            selected: {_mode},
            onSelectionChanged: (set) => setState(() => _mode = set.first),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: '输入',
                hintText: '输入待转换的文本',
              ),
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _convert,
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('转换'),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () {
                  final temp = _inputController.text;
                  _inputController.text = _outputController.text;
                  _outputController.text = temp;
                },
                icon: const Icon(Icons.swap_vert),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _outputController,
              decoration: const InputDecoration(
                labelText: '输出',
                suffixIcon: Icon(Icons.copy),
              ),
              maxLines: null,
              expands: true,
              readOnly: true,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecksumTool extends StatefulWidget {
  const _ChecksumTool();

  @override
  State<_ChecksumTool> createState() => _ChecksumToolState();
}

class _ChecksumToolState extends State<_ChecksumTool> {
  final _inputController = TextEditingController();
  String _result = '';

  void _calculate() {
    final input = _inputController.text;
    if (input.isEmpty) return;

    try {
      final bytes = utf8.encode(input);
      int sum = 0;
      int xor = 0;
      for (final b in bytes) {
        sum += b;
        xor ^= b;
      }

      _result = '''
Checksum (Sum): 0x${(sum & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0')}
Checksum (XOR): 0x${(xor & 0xFF).toRadixString(16).toUpperCase().padLeft(2, '0')}
Length: ${bytes.length} bytes
      '''.trim();
    } catch (e) {
      _result = 'Error: $e';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: '输入数据',
                hintText: '输入要计算校验的文本或 HEX',
              ),
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('计算校验'),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: SelectableText(
              _result.isEmpty ? '点击按钮计算校验值' : _result,
              style: TextStyle(
                color: _result.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JsonTool extends StatefulWidget {
  const _JsonTool();

  @override
  State<_JsonTool> createState() => _JsonToolState();
}

class _JsonToolState extends State<_JsonTool> {
  final _inputController = TextEditingController();
  String _output = '';
  String? _error;

  void _format() {
    try {
      final input = _inputController.text.trim();
      if (input.isEmpty) return;
      final dynamic parsed = jsonDecode(input);
      _output = const JsonEncoder.withIndent('  ').convert(parsed);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _output = '';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'JSON 输入',
                hintText: '粘贴 JSON 文本',
              ),
              maxLines: null,
              expands: true,
              style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _format,
              icon: const Icon(Icons.format_indent_increase),
              label: const Text('格式化'),
            ),
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
            ),
          if (_output.isNotEmpty)
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _output,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
