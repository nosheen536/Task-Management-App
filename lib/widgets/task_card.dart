
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';
import '../viewModels/task_viewmodel.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool selected;
  const TaskCard({super.key, required this.task, this.selected = false});

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High Priority':
        return Colors.redAccent;
      case 'Medium Priority':
        return Colors.orange;
      case 'Low Priority':
        return Colors.green;
      case 'Urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Overdue':
        return Colors.red;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => _ThemedConfirmDialog(
            title: 'Delete Task',
            content: 'Are you sure you want to delete this task?',
            confirmText: 'Delete',
            confirmColor: Colors.red,
          ),
        );
      },
      onDismissed: (_) async {
        await taskVM.deleteTask(task.id, userId);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.redAccent,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => _showTaskDetailsModal(context, task),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              // color: const Color(0x14FFFFFF),
               color: const Color.fromARGB(101, 40, 114, 145),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(31),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      activeColor: const Color.fromARGB(255, 4, 114, 101),
                      side: const BorderSide(color: Color.fromARGB(255, 192, 192, 192)),
                      onChanged: (value) async {
                        final newStatus = value! ? 'Completed' : 'Pending';
                        await taskVM.updateStatus(task.id, newStatus, value, userId);
                      },
                    ),
                     


                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${task.dueDate.toLocal()}'.split(' ')[0] + ' • ',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statusColor(task.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(task.priority),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showEditTaskModal(context, task),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Color.fromARGB(255, 242, 248, 247),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDetailsModal(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TaskDetailsModal(task: task),
    );
  }

  void _showEditTaskModal(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditTaskModal(task: task),
    );
  }
}

class _ThemedConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final Color confirmColor;
  const _ThemedConfirmDialog({
    required this.title,
    required this.content,
    required this.confirmText,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF19485C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Text(content, style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}


class _TaskDetailsModal extends StatelessWidget {
  final Task task;
  const _TaskDetailsModal({required this.task});

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final themeColor = const Color(0xFF19485C);
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(39),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    task.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 12),
                  _detailHeading('Description'),
                  Text(
                    task.description.isNotEmpty ? task.description : 'No description',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  if (task.note != null && task.note!.isNotEmpty) ...[
                    _detailHeading('Note'),
                    Text(task.note!, style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.left),
                    const SizedBox(height: 16),
                  ],
                  _detailHeading('Deadline'),
                  Text(
                    '${task.dueDate.day.toString().padLeft(2, '0')}-${task.dueDate.month.toString().padLeft(2, '0')}-${task.dueDate.year}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 16),
                  _detailHeading('Priority'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      task.priority,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _detailHeading('Status'),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusColor(task.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          task.status,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          // Buttons (side by side)
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      
      Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48, 
              child: _modalButton(
                context: context,
                color: Colors.teal,
                icon: Icons.edit,
                text: 'Edit',
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _EditTaskModal(task: task),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48, 
              child: _modalButton(
                context: context,
                color: Colors.red,
                icon: Icons.delete,
                text: 'Delete',
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (_) => _ThemedConfirmDialog(
                      title: 'Delete Task',
                      content: 'Are you sure you want to delete this task?',
                      confirmText: 'Delete',
                      confirmColor: Colors.red,
                    ),
                  );
                  if (confirm == true) {
                    try {
                      await taskVM.deleteTask(task.id, userId);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task deleted successfully!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting task: $e')),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      // Bottom: Mark as Done button (full width)
      SizedBox(
        width: double.infinity, 
        height: 48, 
        child: _modalButton(
          context: context,
          color: Colors.green,
          icon: Icons.check_circle,
          text: 'Mark as Done',
          onPressed: () async {
            try {
              await taskVM.updateStatus(task.id, 'Completed', true, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task marked as completed!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating task: $e')),
              );
            }
          },
        ),
      ),
    ],
  ),
)
        ],
      ),
    );
  }

  Widget _detailHeading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
  );

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High Priority':
        return Colors.redAccent;
      case 'Medium Priority':
        return Colors.orange;
      case 'Low Priority':
        return Colors.green;
      case 'Urgent':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Overdue':
        return Colors.red;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _modalButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
       width: 160,
                    height: 45,
      // width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        onPressed: onPressed,
      ),
    );
  }
}

class _EditTaskModal extends StatefulWidget {
  final Task task;
  const _EditTaskModal({required this.task});

  @override
  State<_EditTaskModal> createState() => _EditTaskModalState();
}

class _EditTaskModalState extends State<_EditTaskModal> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _noteController;
  late DateTime _dueDate;
  late String _priority;
  late String _status;
  bool _editTitle = false;
  bool _editDesc = false;
  bool _editNote = false;
  // bool _editDate = false;
  bool _editPriority = false;
  bool _editStatus = false;

  final List<String> _priorityOptions = [
    'Low Priority', 'Medium Priority', 'High Priority', 'Urgent'
  ];
  final List<String> _statusOptions = [
    'Pending', 'In Progress', 'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _noteController = TextEditingController(text: widget.task.note ?? '');
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
    _status = widget.task.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = Provider.of<TaskViewModel>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final themeColor = const Color(0xFF19485C);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: themeColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(39),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _editField(
                    label: 'Title',
                    controller: _titleController,
                    isEditing: _editTitle,
                    onEdit: () => setState(() => _editTitle = true),
                    onDone: () => setState(() => _editTitle = false),
                  ),
                  const SizedBox(height: 16),
                  _editField(
                    label: 'Description',
                    controller: _descController,
                    isEditing: _editDesc,
                    onEdit: () => setState(() => _editDesc = true),
                    onDone: () => setState(() => _editDesc = false),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _editField(
                    label: 'Note',
                    controller: _noteController,
                    isEditing: _editNote,
                    onEdit: () => setState(() => _editNote = true),
                    onDone: () => setState(() => _editNote = false),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  _editDateField(context),
                  const SizedBox(height: 16),
                  _editDropdownField(
                    label: 'Priority',
                    value: _priority,
                    options: _priorityOptions,
                    isEditing: _editPriority,
                    onEdit: () => setState(() => _editPriority = true),
                    onChanged: (v) => setState(() { _priority = v!; _editPriority = false; }),
                  ),
                  const SizedBox(height: 16),
                  _editDropdownField(
                    label: 'Status',
                    value: _status,
                    options: _statusOptions,
                    isEditing: _editStatus,
                    onEdit: () => setState(() => _editStatus = true),
                    onChanged: (v) => setState(() { _status = v!; _editStatus = false; }),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          Container(
  padding: const EdgeInsets.all(24),
  child: SizedBox(
    width: 160,
    height: 45,
    child: _modalButton(
      context: context,
      color: Colors.teal,
      icon: Icons.save,
      text: 'Save Changes',
      onPressed: () async {
        final confirm = await showDialog(
          context: context,
          builder: (_) => _ThemedConfirmDialog(
            title: 'Save Changes',
            content: 'Are you sure you want to save these changes?',
            confirmText: 'Save',
            confirmColor: Colors.teal,
          ),
        );
        if (confirm == true) {
          try {
            final updatedTask = widget.task.copyWith(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              note: _noteController.text.trim(),
              dueDate: _dueDate,
              priority: _priority,
              status: _status,
            );
            await taskVM.updateTask(updatedTask, userId);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task updated successfully!')),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating task: $e')),
            );
          }
        }
      },
    ),
  ),
),

        ],
      ),
    );
  }

  Widget _editField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onDone,
    int maxLines = 1,
  }) {
    return Row(
      crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: isEditing,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        isEditing
            ? IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: onDone,
              )
            : IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: onEdit,
              ),
      ],
    );
  }

  Widget _editDateField(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: '${_dueDate.day.toString().padLeft(2, '0')}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.year}'),
            enabled: false,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Deadline',
              labelStyle: const TextStyle(color: Colors.white),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white70),
          onPressed: () async {
            final pickedDate = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: _dueDate,
            );
            if (pickedDate != null) {
              setState(() {
                _dueDate = DateTime(
                  pickedDate.year, pickedDate.month, pickedDate.day,
                  _dueDate.hour, _dueDate.minute,
                );
              });
            }
          },
        ),
      ],
    );
  }

  Widget _editDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required bool isEditing,
    required VoidCallback onEdit,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: IgnorePointer(
            ignoring: !isEditing,
            child: DropdownButtonFormField<String>(
              value: value,
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: onChanged,
              dropdownColor: const Color(0xFF19485C),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        isEditing
            ? IconButton(
                icon: const Icon(Icons.check, color: Colors.white),
                onPressed: () => setState(() => isEditing = false),
              )
            : IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: onEdit,
              ),
      ],
    );
  }

  Widget _modalButton({
    required BuildContext context,
    required Color color,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        onPressed: onPressed,
      ),
    );
  }
}
