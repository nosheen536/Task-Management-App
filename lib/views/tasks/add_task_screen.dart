import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewModels/task_viewmodel.dart';
import '../../models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  static const routeName = '/addTask';
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  String description = '';
  String note = '';
  String priority = 'Low Priority';
  String status = 'Pending';
  DateTime dueDate = DateTime.now();

  final int maxDescriptionChars = 400;
  final int maxNoteChars = 300;

  int _descriptionCharCount = 0;
  int _noteCharCount = 0;

  final Map<String, Color> priorityColors = {
    'Low Priority': Colors.green,
    'Medium Priority': Colors.orange,
    'High Priority': Colors.red,
    'Urgent': Colors.purple
  };

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final themeColor = const Color(0xFF19485C);

    final isFormValid = _descriptionCharCount <= maxDescriptionChars &&
        _noteCharCount <= maxNoteChars;

    return Scaffold(
      backgroundColor: themeColor,
      appBar: AppBar(
        title: const Text('Add Task', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => title = v!,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                style: const TextStyle(color: Colors.white),
                maxLines: 6,
                onChanged: (value) {
                  setState(() {
                    _descriptionCharCount = value.length;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  helperText: '$_descriptionCharCount / $maxDescriptionChars characters',
                  helperStyle: TextStyle(
                    color: _descriptionCharCount > maxDescriptionChars ? Colors.redAccent : Colors.white70,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if ((value?.length ?? 0) > maxDescriptionChars) {
                    return 'Description must be $maxDescriptionChars characters or less.';
                  }
                  return null;
                },
                onSaved: (v) => description = v ?? '',
              ),
              const SizedBox(height: 12),

              // Note
              TextFormField(
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                onChanged: (value) {
                  setState(() {
                    _noteCharCount = value.length;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  helperText: '$_noteCharCount / $maxNoteChars characters',
                  helperStyle: TextStyle(
                    color: _noteCharCount > maxNoteChars ? Colors.redAccent : Colors.white70,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if ((value?.length ?? 0) > maxNoteChars) {
                    return 'Note must be $maxNoteChars characters or less.';
                  }
                  return null;
                },
                onSaved: (v) => note = v ?? '',
              ),
              const SizedBox(height: 16),

              const Text('Status', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    label: 'Pending 🌱',
                    selected: status == 'Pending',
                    onTap: () => setState(() => status = 'Pending'),
                  ),
                  _StatusChip(
                    label: 'In Progress 🌼',
                    selected: status == 'In Progress',
                    onTap: () => setState(() => status = 'In Progress'),
                  ),
                  _StatusChip(
                    label: 'Completed 🌸',
                    selected: status == 'Completed',
                    onTap: () => setState(() => status = 'Completed'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                dropdownColor: themeColor,
                style: const TextStyle(color: Colors.white),
                value: priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  labelStyle: const TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: priorityColors.keys.map((p) =>
                  DropdownMenuItem(
                    value: p,
                    child: Row(
                      children: [
                        Icon(Icons.circle, color: priorityColors[p], size: 12),
                        const SizedBox(width: 8),
                        Text(p, style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  )).toList(),
                onChanged: (v) => setState(() => priority = v!),
              ),
              const SizedBox(height: 16),

              ListTile(
                tileColor: Colors.white24,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                title: Text(
                  'Deadline: ${dueDate.toLocal()}'.split('.')[0],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.white),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    initialDate: dueDate,
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(dueDate),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        dueDate = DateTime(
                          pickedDate.year, pickedDate.month, pickedDate.day,
                          pickedTime.hour, pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              Center(
                child: SizedBox(
                  width: 160,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFormValid ? Colors.teal : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: isFormValid
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              final task = Task(
                                id: '',
                                title: title,
                                description: description,
                                note: note,
                                dueDate: dueDate,
                                priority: priority,
                                status: status,
                                isCompleted: status == 'Completed',
                                createdAt: DateTime.now(),
                              );
                              await taskVM.addTask(task, userId);
                              Navigator.pop(context);
                            }
                          }
                        : null,
                    child: const Text('Add Task', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.teal : Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
