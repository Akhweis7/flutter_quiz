import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class KanbanController extends GetxController {
  final _auth = Get.find<AuthController>();

  final RxList<TaskItem> tasks = <TaskItem>[].obs;
  final RxBool isLoading = false.obs;

  String get _token => _auth.token.value;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  // ── Tasks (columns) ────────────────────────────────────────────────────────

  Future<void> fetchTasks() async {
    isLoading.value = true;
    try {
      final res = await ApiService.get('/Tasks', token: _token);
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        tasks.value =
            list.map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        _snack('Error', 'Failed to load tasks (${res.statusCode})');
      }
    } catch (e) {
      _snack('Network Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addTask(String title) async {
    try {
      final res = await ApiService.post(
        '/Tasks',
        {'title': title},
        token: _token,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final task = TaskItem.fromJson(
          jsonDecode(res.body) as Map<String, dynamic>,
        );
        tasks.add(task);
      } else {
        _snack('Error', 'Failed to add column (${res.statusCode})');
      }
    } catch (e) {
      _snack('Network Error', e.toString());
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final res = await ApiService.delete('/Tasks/$taskId', token: _token);
      if (res.statusCode == 200 || res.statusCode == 204) {
        tasks.removeWhere((t) => t.id == taskId);
      } else {
        _snack('Error', 'Failed to delete column (${res.statusCode})');
      }
    } catch (e) {
      _snack('Network Error', e.toString());
    }
  }

  // ── Subtasks (cards) ───────────────────────────────────────────────────────

  Future<void> addSubtask(String taskId, Subtask subtask) async {
    try {
      final res = await ApiService.post(
        '/Tasks/$taskId/subtasks',
        subtask.toJson(),
        token: _token,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Re-fetch that task to get the server-assigned id on the new subtask
        final taskRes = await ApiService.get('/Tasks/$taskId', token: _token);
        if (taskRes.statusCode == 200) {
          final index = tasks.indexWhere((t) => t.id == taskId);
          if (index != -1) {
            tasks[index] = TaskItem.fromJson(
              jsonDecode(taskRes.body) as Map<String, dynamic>,
            );
            tasks.refresh();
          }
        }
      } else {
        _snack('Error', 'Failed to add card (${res.statusCode})');
      }
    } catch (e) {
      _snack('Network Error', e.toString());
    }
  }

  Future<void> deleteSubtask(String taskId, String subtaskId) async {
    try {
      final res = await ApiService.delete(
        '/Tasks/$taskId/subtasks/$subtaskId',
        token: _token,
      );
      if (res.statusCode == 200 || res.statusCode == 204) {
        final index = tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          tasks[index].subtasks.removeWhere((s) => s.id == subtaskId);
          tasks.refresh();
        }
      } else {
        _snack('Error', 'Failed to delete card (${res.statusCode})');
      }
    } catch (e) {
      _snack('Network Error', e.toString());
    }
  }

  void _snack(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
