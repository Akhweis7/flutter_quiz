import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/kanban_controller.dart';
import '../models/models.dart';

class KanbanPage extends StatelessWidget {
  const KanbanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final kanban = Get.put(KanbanController());

    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Obx(
          () => Text(
            'Hello, ${auth.currentUser.value?.username ?? 'User'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: kanban.fetchTasks,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: auth.logout,
          ),
        ],
      ),
      body: Obx(() {
        if (kanban.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (kanban.tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.dashboard_outlined,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                const Text('No columns yet',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddColumnDialog(kanban),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Column'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          itemCount: kanban.tasks.length + 1,
          itemBuilder: (_, i) {
            if (i == kanban.tasks.length) {
              return _AddColumnButton(onTap: () => _showAddColumnDialog(kanban));
            }
            return _KanbanColumn(
              task: kanban.tasks[i],
              kanban: kanban,
            );
          },
        );
      }),
    );
  }

  void _showAddColumnDialog(KanbanController kanban) {
    final textCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('New Column'),
        content: TextField(
          controller: textCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Column title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = textCtrl.text.trim();
              if (title.isNotEmpty) {
                kanban.addTask(title);
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ── Column widget ──────────────────────────────────────────────────────────────

class _KanbanColumn extends StatelessWidget {
  const _KanbanColumn({required this.task, required this.kanban});

  final TaskItem task;
  final KanbanController kanban;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Obx(() {
                  final count = kanban.tasks
                          .firstWhereOrNull((t) => t.id == task.id)
                          ?.subtasks
                          .length ??
                      0;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Colors.red),
                  tooltip: 'Delete column',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDeleteColumn(),
                ),
              ],
            ),
          ),
          // Cards list
          Expanded(
            child: Obx(() {
              final subtasks = kanban.tasks
                      .firstWhereOrNull((t) => t.id == task.id)
                      ?.subtasks ??
                  [];
              if (subtasks.isEmpty) {
                return const Center(
                  child: Text(
                    'No cards',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: subtasks.length,
                itemBuilder: (_, i) => _SubtaskCard(
                  subtask: subtasks[i],
                  taskId: task.id!,
                  kanban: kanban,
                ),
              );
            }),
          ),
          // Add card button
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: OutlinedButton.icon(
              onPressed: () => _showAddCardDialog(),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Card'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteColumn() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Column'),
        content: Text('Delete "${task.title}" and all its cards?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              kanban.deleteTask(task.id!);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('New Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isNotEmpty) {
                kanban.addSubtask(
                  task.id!,
                  Subtask(
                    title: title,
                    description: descCtrl.text.trim().isEmpty
                        ? null
                        : descCtrl.text.trim(),
                  ),
                );
                Get.back();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ── Card widget ────────────────────────────────────────────────────────────────

class _SubtaskCard extends StatelessWidget {
  const _SubtaskCard({
    required this.subtask,
    required this.taskId,
    required this.kanban,
  });

  final Subtask subtask;
  final String taskId;
  final KanbanController kanban;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtask.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(),
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
            if (subtask.description != null &&
                subtask.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtask.description!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (subtask.duedate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 11, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${subtask.duedate!.day}/${subtask.duedate!.month}/${subtask.duedate!.year}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.orange),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Delete "${subtask.title}"?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              kanban.deleteSubtask(taskId, subtask.id!);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Add column button ──────────────────────────────────────────────────────────

class _AddColumnButton extends StatelessWidget {
  const _AddColumnButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.deepPurple.shade200, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 36, color: Colors.deepPurple.shade300),
            const SizedBox(height: 8),
            Text(
              'Add Column',
              style: TextStyle(
                color: Colors.deepPurple.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
