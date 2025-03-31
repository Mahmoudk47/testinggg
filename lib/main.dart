import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(ButtonManagementApp());
}

class ButtonManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Button Management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ButtonManagementScreen(),
    );
  }
}

class ButtonManagementScreen extends StatefulWidget {
  @override
  _ButtonManagementScreenState createState() => _ButtonManagementScreenState();
}

class _ButtonManagementScreenState extends State<ButtonManagementScreen> {
  List<ButtonData> buttons = [];
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadButtons();
  }

  Future<void> _loadButtons() async {
    prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('buttons');
    if (data != null) {
      setState(() {
        buttons =
            (json.decode(data) as List)
                .map((item) => ButtonData.fromJson(item))
                .toList();
      });
    }
  }

  void _saveButtons() {
    prefs.setString(
      'buttons',
      json.encode(buttons.map((b) => b.toJson()).toList()),
    );
  }

  void _addButton() {
    showDialog(
      context: context,
      builder: (context) {
        return ButtonEditDialog(
          onSave: (label, count, color) {
            setState(() {
              buttons.add(ButtonData(label: label, count: count, color: color));
              _saveButtons();
            });
          },
        );
      },
    );
  }

  void _editButton(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return ButtonEditDialog(
          button: buttons[index],
          onSave: (label, count, color) {
            setState(() {
              buttons[index] = ButtonData(
                label: label,
                count: count,
                color: color,
              );
              _saveButtons();
            });
          },
          onDelete: () {
            setState(() {
              buttons.removeAt(index);
              _saveButtons();
            });
          },
        );
      },
    );
  }

  void _decreaseCount(int index) {
    setState(() {
      if (buttons[index].count > 0) {
        buttons[index].count--;
        _saveButtons();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Button Management')),
      body:
          buttons.isEmpty
              ? Center(child: Text('Add First Button'))
              : GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: buttons.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () => _editButton(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: buttons[index].color,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          if (buttons[index].count == 0)
                            BoxShadow(
                              color: Colors.greenAccent,
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _decreaseCount(index),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                buttons[index].label,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${buttons[index].count}',
                                style: TextStyle(
                                  fontSize: 24,
                                  color:
                                      buttons[index].count == 0
                                          ? Colors.green
                                          : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addButton,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ButtonData {
  String label;
  int count;
  Color color;

  ButtonData({required this.label, required this.count, required this.color});

  Map<String, dynamic> toJson() => {
    'label': label,
    'count': count,
    'color': color.value,
  };

  factory ButtonData.fromJson(Map<String, dynamic> json) => ButtonData(
    label: json['label'],
    count: json['count'],
    color: Color(json['color']),
  );
}

class ButtonEditDialog extends StatefulWidget {
  final ButtonData? button;
  final Function(String, int, Color) onSave;
  final VoidCallback? onDelete;

  ButtonEditDialog({this.button, required this.onSave, this.onDelete});

  @override
  _ButtonEditDialogState createState() => _ButtonEditDialogState();
}

class _ButtonEditDialogState extends State<ButtonEditDialog> {
  late TextEditingController _labelController;
  late int _count;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.button?.label ?? '');
    _count = widget.button?.count ?? 0;
    _color = widget.button?.color ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.button == null ? 'New Button' : 'Edit Button'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _labelController,
            decoration: InputDecoration(labelText: 'Label'),
          ),
          Slider(
            value: _count.toDouble(),
            min: 0,
            max: 999,
            divisions: 999,
            label: _count.toString(),
            onChanged: (value) => setState(() => _count = value.toInt()),
          ),
          SizedBox(height: 16),
          DropdownButton<Color>(
            value: _color,
            items: [
              DropdownMenuItem(
                value: Colors.blue,
                child: Text('Blue', style: TextStyle(color: Colors.blue)),
              ),
              DropdownMenuItem(
                value: Colors.red,
                child: Text('Red', style: TextStyle(color: Colors.red)),
              ),
              DropdownMenuItem(
                value: Colors.green,
                child: Text('Green', style: TextStyle(color: Colors.green)),
              ),
              DropdownMenuItem(
                value: Colors.yellow,
                child: Text('Yellow', style: TextStyle(color: Colors.yellow)),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _color = value);
              }
            },
            hint: Text('Select Color'),
          ),
        ],
      ),
      actions: [
        if (widget.onDelete != null)
          TextButton(onPressed: widget.onDelete, child: Text('Delete')),
        TextButton(
          onPressed: () => widget.onSave(_labelController.text, _count, _color),
          child: Text('Save'),
        ),
      ],
    );
  }
}
