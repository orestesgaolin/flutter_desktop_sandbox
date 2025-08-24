import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sandbox/theme.dart';
import 'package:sandbox/shortcuts/intents.dart';
import 'package:sandbox/shortcuts/key_recorder.dart';
import 'package:sandbox/shortcuts/shortcut_model.dart';
import 'package:sandbox/shortcuts/shortcuts_provider.dart';
import 'package:sandbox/widgets/button.dart';
import 'package:sandbox/widgets/dropdown.dart';
import 'package:sandbox/widgets/page.dart';

/// A page for managing custom shortcuts
class ShortcutsManagerPage extends StatefulWidget {
  const ShortcutsManagerPage({super.key});

  @override
  State<ShortcutsManagerPage> createState() => _ShortcutsManagerPageState();
}

class _ShortcutsManagerPageState extends State<ShortcutsManagerPage> {
  CustomShortcut? _editingShortcut;
  LogicalKeySet? _selectedKeys;
  IntentId? _selectedIntentId;
  bool _isEditing = false;
  late ShortcutsProvider _shortcutsProvider;

  @override
  void initState() {
    super.initState();
    _shortcutsProvider = context.read<ShortcutsProvider>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startAddShortcut() {
    setState(() {
      _editingShortcut = null;
      _selectedKeys = null;
      _selectedIntentId = null;
      _isEditing = true;
    });
  }

  void _startEditShortcut(CustomShortcut shortcut) {
    setState(() {
      _editingShortcut = shortcut;
      _selectedKeys = shortcut.keys;
      _selectedIntentId = shortcut.intentId;
      _isEditing = true;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _editingShortcut = null;
      _selectedKeys = null;
      _selectedIntentId = null;
    });
  }

  void _saveShortcut() {
    if (_selectedKeys == null || _selectedIntentId == null) {
      return; // Both must be selected
    }

    if (_editingShortcut == null) {
      // Adding new shortcut
      final name = _getIntentName(_selectedIntentId!);
      _shortcutsProvider.addShortcut(
        CustomShortcut(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          keys: _selectedKeys!,
          intentId: _selectedIntentId!,
        ),
      );
    } else {
      // Updating existing shortcut
      final name = _getIntentName(_selectedIntentId!);
      _shortcutsProvider.updateShortcut(
        _editingShortcut!.id,
        CustomShortcut(
          id: _editingShortcut!.id,
          name: name,
          keys: _selectedKeys!,
          intentId: _selectedIntentId!,
        ),
      );
    }

    setState(() {
      _isEditing = false;
      _editingShortcut = null;
      _selectedKeys = null;
      _selectedIntentId = null;
    });
  }

  void _deleteShortcut(String id) {
    _shortcutsProvider.deleteShortcut(id);
    setState(() {});
  }

  void _onKeysRecorded(LogicalKeySet keys) {
    setState(() {
      _selectedKeys = keys;
    });
  }

  void _clearKeys() {
    setState(() {
      _selectedKeys = null;
    });
  }

  void _clearIntent() {
    setState(() {
      _selectedIntentId = null;
    });
  }

  String _getIntentName(IntentId intentId) {
    final intent = findById(intentId);
    return intent.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      scrollable: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Keyboard Shortcuts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 80), // Balance for back button
            ],
          ),
          const SizedBox(height: 32),

          if (_isEditing)
            _buildShortcutEditor()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Add New Shortcut',
                  onPressed: _startAddShortcut,
                ),
              ],
            ),

          const SizedBox(height: 24),

          if (!_isEditing)
            Expanded(
              child: _shortcutsProvider.shortcuts.isEmpty
                  ? Center(
                      child: Text(
                        'No shortcuts defined yet.\nClick "Add New Shortcut" to create one.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _shortcutsProvider.shortcuts.length,
                      itemBuilder: (context, index) {
                        final shortcut = _shortcutsProvider.shortcuts[index];
                        return _buildShortcutItem(shortcut);
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildShortcutEditor() {
    return Actions(
      actions: {
        DismissIntent: CallbackAction<Intent>(
          onInvoke: (intent) {
            _cancelEdit();
            return null;
          },
        ),
      },
      child: Shortcuts(
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFDDDDDD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingShortcut == null ? 'Add New Shortcut' : 'Edit Shortcut',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Select Action',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildIntentSelector(),
              const SizedBox(height: 24),

              Text(
                'Define Keyboard Shortcut',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: KeyRecorder(
                      onKeysRecorded: _onKeysRecorded,
                      initialKeys: _selectedKeys,
                    ),
                  ),
                  if (_selectedKeys != null) ...[
                    const SizedBox(width: 12),
                    AppButton(
                      onPressed: _clearKeys,
                      label: 'Clear',
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    onPressed: _cancelEdit,
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Save',
                    onPressed: _selectedKeys != null && _selectedIntentId != null ? _saveShortcut : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntentSelector() {
    return Row(
      children: [
        Expanded(
          child: AppDropdown<IntentId>(
            header: Text(
              _selectedIntentId == null ? 'Select an action' : _getIntentName(_selectedIntentId!),
              style: TextStyle(
                color: _selectedIntentId == null ? Color(0xFF888888) : Colors.black,
              ),
            ),
            itemBuilder: (value) => Text(_getIntentName(value)),
            value: _selectedIntentId,
            onChanged: (IntentId? value) {
              setState(() {
                _selectedIntentId = value;
              });
            },
            items: IntentId.values,
          ),
        ),
        if (_selectedIntentId != null) ...[
          const SizedBox(width: 12),
          AppButton(onPressed: _clearIntent, label: 'Clear'),
        ],
      ],
    );
  }

  Widget _buildShortcutItem(CustomShortcut shortcut) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.of(context).cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortcut.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    shortcut.keysDescription,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              AppButton(
                onPressed: () => _startEditShortcut(shortcut),
                label: 'Edit',
              ),
              const SizedBox(width: 8),
              AppButton(
                onPressed: () => _deleteShortcut(shortcut.id),
                label: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
