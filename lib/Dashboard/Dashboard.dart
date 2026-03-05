import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Providers/themeProvider.dart';
import '../Services/supabaseServices.dart';
import 'task_model.dart';
import 'task_tile.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseService _service;
  TaskProvider(this._service);

  List<Task> _tasks = [];
  bool isLoading = false;
  String? error;

  List<Task> get tasks => List.unmodifiable(_tasks);

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.completed).length;
  int get pendingCount => _tasks.where((t) => !t.completed).length;

  List<Task> filtered(String filter) {
    switch (filter) {
      case 'pending':
        return _tasks.where((t) => !t.completed).toList();
      case 'completed':
        return _tasks.where((t) => t.completed).toList();
      default:
        return List.unmodifiable(_tasks);
    }
  }

  Future<void> fetchTasks() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _tasks = await _service.fetchTasks();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    final task = await _service.addTask(title);
    _tasks.insert(0, task);
    notifyListeners();
  }

  Future<void> toggleTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    final updated = task.copyWith(completed: !task.completed);
    _tasks[index] = updated;
    notifyListeners();

    try {
      await _service.toggleTask(task.id, updated.completed);
    } catch (e) {
      _tasks[index] = task;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    _tasks.removeAt(index);
    notifyListeners();

    try {
      await _service.deleteTask(task.id);
    } catch (e) {
      _tasks.insert(index, task);
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> editTask(Task task, String newTitle) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    final updated = task.copyWith(title: newTitle);
    _tasks[index] = updated;
    notifyListeners();

    try {
      await _service.editTask(task.id, newTitle);
    } catch (e) {
      _tasks[index] = task;
      error = e.toString();
      notifyListeners();
    }
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late final TaskProvider _taskProvider;
  final TextEditingController _taskController = TextEditingController();

  bool _isAdding = false;
  String _activeFilter = 'all';

  late final AnimationController _entryController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _statsFade;
  late final Animation<Offset> _statsSlide;
  late final Animation<double> _inputFade;
  late final Animation<Offset> _inputSlide;
  late final Animation<double> _filterFade;
  late final Animation<Offset> _filterSlide;
  late final Animation<double> _listFade;

  @override
  void initState() {
    super.initState();

    _taskProvider = TaskProvider(SupabaseService());

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.27, curve: Curves.easeOut),
      ),
    );
    _headerSlide =
        Tween<Offset>(begin: const Offset(0, -0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.27, curve: Curves.easeOut),
          ),
        );

    _statsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.18, 0.45, curve: Curves.easeOut),
      ),
    );
    _statsSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.18, 0.45, curve: Curves.easeOut),
          ),
        );

    _inputFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.32, 0.58, curve: Curves.easeOut),
      ),
    );
    _inputSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.32, 0.58, curve: Curves.easeOut),
          ),
        );

    _filterFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.45, 0.68, curve: Curves.easeOut),
      ),
    );
    _filterSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.45, 0.68, curve: Curves.easeOut),
          ),
        );

    _listFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.58, 0.82, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
      _taskProvider.fetchTasks();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _taskController.dispose();
    _taskProvider.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;
    setState(() => _isAdding = true);
    try {
      await _taskProvider.addTask(title);
      _taskController.clear();
    } catch (e) {
      _showSnack('Failed to add task: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> _showEditSheet(Task task) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => _EditTaskSheet(
        initialTitle: task.title,
        onSubmit: (newTitle) async {
          Navigator.pop(ctx);
          try {
            await _taskProvider.editTask(task, newTitle);
          } catch (e) {
            _showSnack('Failed to update task: $e', isError: true);
          }
        },
      ),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError
                    ? Colors.white
                    : isDark
                    ? const Color(0xFFF5C842)
                    : cs.primary,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: TextStyle(
                    color: isError ? Colors.white : cs.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? const Color(0xFFCF4444)
              : isDark
              ? const Color(0xFF2A3447)
              : Colors.white,
          behavior: SnackBarBehavior.floating,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getUserName() {
    final user = Supabase.instance.client.auth.currentUser;
    final fullName = (user?.userMetadata?['full_name'] as String? ?? '').trim();
    if (fullName.isNotEmpty) return fullName;
    return user?.email?.split('@').first ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _taskProvider,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _FadeSlide(
                fade: _headerFade,
                slide: _headerSlide,
                child: _buildHeader(),
              ),
              _FadeSlide(
                fade: _statsFade,
                slide: _statsSlide,
                child: _buildStatsRow(),
              ),
              _FadeSlide(
                fade: _inputFade,
                slide: _inputSlide,
                child: _buildAddTaskField(),
              ),
              _FadeSlide(
                fade: _filterFade,
                slide: _filterSlide,
                child: _buildFilterTabs(),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _listFade,
                  child: _buildTaskList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    color: subColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getUserName(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Day',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: 'Task',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final isDarkMode = themeProvider.isDark;
              return IconButton(
                tooltip: 'Toggle Theme',
                onPressed: themeProvider.toggleTheme,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => RotationTransition(
                    turns: animation,
                    child: FadeTransition(opacity: animation, child: child),
                  ),
                  child: Icon(
                    isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    key: ValueKey(isDarkMode),
                    color: subColor,
                    size: 21,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: subColor, size: 20),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        final progress = provider.totalCount == 0
            ? 0.0
            : provider.completedCount / provider.totalCount;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Total',
                    value: '${provider.totalCount}',
                    icon: Icons.list_alt_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    label: 'Pending',
                    value: '${provider.pendingCount}',
                    icon: Icons.pending_actions_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProgressCard(
                    progress: progress,
                    completed: provider.completedCount,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddTaskField() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _taskController,
              style: TextStyle(color: cs.onSurface, fontSize: 15),
              onSubmitted: (_) => _addTask(),
              decoration: InputDecoration(
                hintText: 'Add a new task...',
                hintStyle: TextStyle(color: subColor, fontSize: 14),
                prefixIcon: Icon(
                  Icons.add_task_rounded,
                  color: subColor,
                  size: 20,
                ),
                filled: true,
                fillColor: cs.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            height: 50,
            child: ElevatedButton(
              onPressed: _isAdding ? null : _addTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.primary.withOpacity(0.5),
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isAdding
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.add_rounded, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    const filters = ['all', 'pending', 'completed'];
    const labels = {'all': 'All', 'pending': 'Pending', 'completed': 'Done'};

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: filters.map((f) {
          final isActive = _activeFilter == f;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeFilter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: f != 'completed' ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[f]!,
                  style: TextStyle(
                    color: isActive ? cs.onPrimary : subColor,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    final cs = Theme.of(context).colorScheme;

    return Consumer<TaskProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: cs.primary,
              strokeWidth: 2.5,
            ),
          );
        }

        final filtered = provider.filtered(_activeFilter);
        if (filtered.isEmpty) return _buildEmptyState();

        return RefreshIndicator(
          color: cs.primary,
          backgroundColor: cs.surface,
          onRefresh: provider.fetchTasks,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final task = filtered[index];
              return _StaggeredItem(
                delay: Duration(milliseconds: 40 * index),
                child: TaskTile(
                  task: task,
                  onToggle: () => provider.toggleTask(task),
                  onDelete: () => provider.deleteTask(task),
                  onEdit: () => _showEditSheet(task),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark
        ? const Color(0xFF3D4F6B)
        : const Color(0xFFD1D5DB);
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    final isCompleted = _activeFilter == 'completed';
    final isPending = _activeFilter == 'pending';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline_rounded
                  : Icons.inbox_outlined,
              color: iconColor,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              isCompleted
                  ? 'No completed tasks yet'
                  : isPending
                  ? 'No pending tasks'
                  : 'No tasks yet',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isCompleted
                  ? 'Complete a task and it will appear here.'
                  : isPending
                  ? 'All your tasks are done. Well done.'
                  : 'Type a task above and tap + to add it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subColor, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final int completed;

  const _ProgressCard({required this.progress, required this.completed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subColor = isDark ? const Color(0xFF8A97B0) : const Color(0xFF6B7280);
    final trackColor = isDark
        ? const Color(0xFF3D4F6B)
        : const Color(0xFFE5E7EB);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: cs.primary, size: 20),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Done',
            style: TextStyle(
              color: subColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: trackColor,
              valueColor: AlwaysStoppedAnimation(cs.primary),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> fade;
  final Animation<Offset> slide;
  final Widget child;

  const _FadeSlide({
    required this.fade,
    required this.slide,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _StaggeredItem({required this.child, this.delay = Duration.zero});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _EditTaskSheet extends StatefulWidget {
  final String initialTitle;
  final Future<void> Function(String newTitle) onSubmit;

  const _EditTaskSheet({required this.initialTitle, required this.onSubmit});

  @override
  State<_EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<_EditTaskSheet> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onSubmit(_ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2A42) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3D4F6B)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Edit Task',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _ctrl,
                  autofocus: true,
                  style: TextStyle(color: cs.onSurface, fontSize: 15),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: 'Task title',
                    hintStyle: TextStyle(
                      color: isDark
                          ? const Color(0xFF8A97B0)
                          : const Color(0xFF6B7280),
                    ),
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE05252),
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title cannot be empty'
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    disabledBackgroundColor: cs.primary.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
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
