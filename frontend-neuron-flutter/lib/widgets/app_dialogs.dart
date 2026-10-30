import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/task_model.dart';
import '../models/document_model.dart';
import '../models/connection_model.dart';
import '../providers/tasks_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/connections_provider.dart';

class AppDialogs {
  AppDialogs._();

  static Future<void> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmLabel = 'Confirm',
    bool isDestructive = false,
  }) async {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
          content: Text(message, style: const TextStyle(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }

  // --- Task Sheet ---
  static Future<void> showTaskSheet(
    BuildContext context, {
    TaskModel? existingTask,
  }) async {
    final titleController = TextEditingController(text: existingTask?.title ?? '');
    final descController = TextEditingController(text: existingTask?.description ?? '');
    var selectedPriority = existingTask?.priority ?? TaskPriority.medium;
    var selectedSection = existingTask?.section ?? TaskSection.today;
    DateTime? selectedDate = existingTask?.dueDate ?? (existingTask == null ? DateTime.now() : null);

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingTask == null ? 'Create New Task' : 'Edit Task',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Task Title *',
                          hintText: 'e.g., Complete presentation slides',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Task title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Add context, links, or notes...',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<TaskPriority>(
                        segments: const [
                          ButtonSegment(value: TaskPriority.low, label: Text('Low')),
                          ButtonSegment(value: TaskPriority.medium, label: Text('Medium')),
                          ButtonSegment(value: TaskPriority.high, label: Text('High')),
                        ],
                        selected: {selectedPriority},
                        onSelectionChanged: (val) {
                          setState(() => selectedPriority = val.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Section', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<TaskSection>(
                        segments: const [
                          ButtonSegment(value: TaskSection.today, label: Text('Today')),
                          ButtonSegment(value: TaskSection.upcoming, label: Text('Upcoming')),
                        ],
                        selected: {selectedSection == TaskSection.completed ? TaskSection.today : selectedSection},
                        onSelectionChanged: (val) {
                          setState(() => selectedSection = val.first);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? 'No due date'
                                : 'Due: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: Text(selectedDate == null ? 'Set Date' : 'Change'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final provider = context.read<TasksProvider>();
                            if (existingTask == null) {
                              provider.addTask(
                                title: titleController.text,
                                description: descController.text,
                                priority: selectedPriority,
                                section: selectedSection,
                                dueDate: selectedDate,
                              );
                            } else {
                              provider.updateTask(
                                id: existingTask.id,
                                title: titleController.text,
                                description: descController.text,
                                priority: selectedPriority,
                                section: selectedSection,
                                dueDate: selectedDate,
                              );
                            }
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existingTask == null
                                      ? 'Task created successfully'
                                      : 'Task updated successfully',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            existingTask == null ? 'Create Task' : 'Save Changes',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Document Sheet ---
  static Future<void> showDocumentSheet(
    BuildContext context, {
    DocumentModel? existingDoc,
  }) async {
    final titleController = TextEditingController(text: existingDoc?.title ?? '');
    final contentController = TextEditingController(text: existingDoc?.content ?? '');
    final tagsController = TextEditingController(text: existingDoc?.tags.join(', ') ?? '');
    var selectedType = existingDoc?.type ?? 'Document';
    var selectedSource = existingDoc?.source ?? 'Local';

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingDoc == null ? 'Add Knowledge Document' : 'Edit Document',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          hintText: 'e.g., Deep Learning Architecture Notes',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedType,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: const [
                                DropdownMenuItem(value: 'Document', child: Text('Document')),
                                DropdownMenuItem(value: 'Note', child: Text('Note')),
                                DropdownMenuItem(value: 'Code', child: Text('Code')),
                                DropdownMenuItem(value: 'Project', child: Text('Project')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedType = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedSource,
                              decoration: const InputDecoration(labelText: 'Source'),
                              items: const [
                                DropdownMenuItem(value: 'Local', child: Text('Local')),
                                DropdownMenuItem(value: 'Google Drive', child: Text('Google Drive')),
                                DropdownMenuItem(value: 'Notion', child: Text('Notion')),
                                DropdownMenuItem(value: 'GitHub', child: Text('GitHub')),
                                DropdownMenuItem(value: 'Gmail', child: Text('Gmail')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => selectedSource = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (comma separated)',
                          hintText: 'e.g., AI, Research, Flutter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: contentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Content / Notes *',
                          hintText: 'Write or paste knowledge content...',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Content is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final tags = tagsController.text
                                .split(',')
                                .map((t) => t.trim())
                                .where((t) => t.isNotEmpty)
                                .toList();

                            final provider = context.read<DocumentsProvider>();
                            if (existingDoc == null) {
                              provider.addDocument(
                                title: titleController.text,
                                content: contentController.text,
                                type: selectedType,
                                source: selectedSource,
                                tags: tags,
                              );
                            } else {
                              provider.updateDocument(
                                id: existingDoc.id,
                                title: titleController.text,
                                content: contentController.text,
                                type: selectedType,
                                source: selectedSource,
                                tags: tags,
                              );
                            }
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existingDoc == null
                                      ? 'Document added to Knowledge Base'
                                      : 'Document updated successfully',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            existingDoc == null ? 'Add to Knowledge Base' : 'Save Changes',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Document Detail Sheet ---
  static Future<void> showDocumentDetail(BuildContext context, DocumentModel doc) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (sheetCtx, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doc.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        doc.source,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.secondaryText(ctx),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Edit Document',
                        onPressed: () {
                          Navigator.pop(ctx);
                          showDocumentSheet(context, existingDoc: doc);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                        tooltip: 'Delete Document',
                        onPressed: () {
                          Navigator.pop(ctx);
                          showConfirmDialog(
                            context,
                            title: 'Delete Document?',
                            message: 'Are you sure you want to delete "${doc.title}"? This action cannot be undone.',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                            onConfirm: () {
                              context.read<DocumentsProvider>().deleteDocument(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Document deleted')),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    doc.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Modified: ${doc.modifiedAt.day}/${doc.modifiedAt.month}/${doc.modifiedAt.year} ${doc.modifiedAt.hour}:${doc.modifiedAt.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(ctx)),
                  ),
                  const SizedBox(height: 16),
                  if (doc.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: doc.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.cardElevated(ctx),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border(ctx)),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(ctx)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    doc.content,
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- Connection Setup Dialog ---
  static Future<void> showConnectionSetupDialog(
    BuildContext context,
    ConnectionModel conn,
  ) async {
    final accountController = TextEditingController(
      text: conn.accountDetail.isNotEmpty ? conn.accountDetail : 'dipen.tiwari@example.com',
    );

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: conn.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(conn.icon, size: 18, color: conn.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Connect ${conn.name}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conn.description,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.primaryLight),
                          SizedBox(width: 6),
                          Text(
                            'OAuth & API Requirements',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        conn.setupNotes,
                        style: const TextStyle(fontSize: 11, height: 1.4),
                      ),
                      const SizedBox(height: 8),
                      const Text('Required Scopes:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ...conn.requiredScopes.map(
                        (s) => Text('• $s', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: accountController,
                  decoration: const InputDecoration(
                    labelText: 'User Account / Email',
                    hintText: 'user@example.com',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can connect using realistic Demo Mode for immediate local testing, or register a live OAuth credential.',
                  style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(ctx)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            OutlinedButton(
              onPressed: () {
                context.read<ConnectionsProvider>().connectDemo(conn.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connected ${conn.name} in Demo Mode (Simulated Data)'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: const Text('Connect (Demo Mode)'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ConnectionsProvider>().connectLive(conn.id, accountController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Connected ${conn.name} (Live Authorized)'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Connect Live'),
            ),
          ],
        );
      },
    );
  }
}
