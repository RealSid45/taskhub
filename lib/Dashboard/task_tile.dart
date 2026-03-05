import 'package:flutter/material.dart';
import 'task_model.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.82,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _handleToggle() async {
    await _checkController.reverse();
    await _checkController.forward();
    widget.onToggle();
  }

  Future<void> _handleDelete() async {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2A42) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3D4F6B)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE05252).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE05252),
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Delete Task',
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${widget.task.title}"',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF8A97B0)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF8A97B0)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF2A3447)
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE05252),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) widget.onDelete();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.task.completed;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? const Color(0xFF1E2A42) : Colors.white;
    final borderColor = completed
        ? cs.primary.withOpacity(0.25)
        : isDark
        ? const Color(0xFF2A3447).withOpacity(0.6)
        : Colors.grey.shade200;
    final checkBorderColor = completed
        ? cs.primary
        : isDark
        ? const Color(0xFF3D4F6B)
        : Colors.grey.shade400;
    final dateColor = isDark
        ? const Color(0xFF3D4F6B).withOpacity(0.8)
        : Colors.grey.shade400;
    final titleColor = completed
        ? (isDark ? const Color(0xFF8A97B0) : Colors.grey.shade400)
        : cs.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.12 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _handleToggle,
            onLongPress: widget.onEdit,
            borderRadius: BorderRadius.circular(14),
            splashColor: cs.primary.withOpacity(0.06),
            highlightColor: cs.primary.withOpacity(0.03),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _checkController,
                    child: GestureDetector(
                      onTap: _handleToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: completed ? cs.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: checkBorderColor,
                            width: 1.5,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: completed
                              ? Icon(
                                  Icons.check_rounded,
                                  key: const ValueKey('check'),
                                  size: 15,
                                  color: cs.onPrimary,
                                )
                              : const SizedBox.shrink(key: ValueKey('empty')),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            decoration: completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: isDark
                                ? const Color(0xFF8A97B0)
                                : Colors.grey.shade400,
                            decorationThickness: 1.5,
                          ),
                          child: Text(
                            widget.task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: dateColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(widget.task.createdAt),
                              style: TextStyle(
                                color: dateColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(scale: anim, child: child),
                    ),
                    child: completed
                        ? Container(
                            key: const ValueKey('done'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Done',
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('none')),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _handleDelete,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE05252).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE05252),
                        size: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
