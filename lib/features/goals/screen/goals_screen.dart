import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/base_layout.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_confirm_dialog.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/core/widgets/app_flash.dart';
import 'package:zenit/features/goals/forms/add_edit_goal_form.dart';
import 'package:zenit/features/goals/forms/view_edit_goal_form.dart';
import 'package:zenit/features/goals/models/goal_model.dart';
import 'package:zenit/features/goals/providers/goals_provider.dart';
import 'package:zenit/features/goals/widgets/goal_list_item.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  static const double _cardRadius = 24;
  static const int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GoalsProvider>().loadGoals();
    });
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return BaseLayout(
      appBar: CommonAppBar(
        title: isVietnamese ? 'Quản lý mục tiêu' : 'Goals management',
        showReturnIcon: true,
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<GoalsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && !provider.hasData) {
            return _buildErrorState(context, provider);
          }

          return Stack(
            children: [
              Column(
                children: [
                    _buildSummary(context, provider),
                    const SizedBox(height: AppSizes.l),
                    _buildToolbar(context, provider),
                    const SizedBox(height: AppSizes.m),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: provider.refreshGoals,
                      child: provider.goals.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 96),
                              itemCount: (() {
                                final total = provider.goals.length;
                                final totalPages =
                                    (total + _pageSize - 1) ~/ _pageSize;
                                final current = _currentPage.clamp(
                                  1,
                                  totalPages == 0 ? 1 : totalPages,
                                );
                                final start = (current - 1) * _pageSize;
                                final remaining = total - start;
                                final visible = remaining < 0
                                    ? 0
                                    : (remaining < _pageSize ? remaining : _pageSize);
                                return visible + (visible > 0 ? 1 : 0);
                              })(),
                              itemBuilder: (context, index) {
                                final total = provider.goals.length;
                                final totalPages =
                                    (total + _pageSize - 1) ~/ _pageSize;
                                final current = _currentPage.clamp(
                                  1,
                                  totalPages == 0 ? 1 : totalPages,
                                );
                                final start = (current - 1) * _pageSize;
                                final remaining = total - start;
                                final visible = remaining < 0
                                    ? 0
                                    : (remaining < _pageSize ? remaining : _pageSize);
                                if (index == visible) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: AppSizes.s),
                                    child: _buildPaginationSectionForGoals(
                                      colors,
                                      provider.goals.length,
                                    ),
                                  );
                                }
                                final item = provider.goals[start + index];
                                final animationDelayMs = index < 8
                                    ? index * 40
                                    : 320;
                                return Animate(
                                  delay: Duration(
                                    milliseconds: animationDelayMs,
                                  ),
                                  effects: [
                                    FadeEffect(
                                      duration: 280.ms,
                                      curve: Curves.easeOut,
                                    ),
                                    SlideEffect(
                                      begin: const Offset(0, 0.08),
                                      end: const Offset(0, 0),
                                      duration: 320.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ],
                                  child: GoalListItem(
                                    goal: item,
                                    onTap: () => _openViewGoalDrawer(item),
                                    onDelete: () => _handleDelete(item),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  
                ],
              ),
              Positioned(
                right: AppSizes.l,
                bottom: AppSizes.l + (AppSizes.m * 5),
                child: FloatingActionButton(
                  onPressed: _showAddGoalDrawer,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, size: 30, weight: 900, fill: 1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, GoalsProvider provider) {
    final isVietnamese = _isVietnamese(context);

    return Center(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.errorContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isVietnamese ? 'Đã xảy ra lỗi' : 'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                provider.errorMessage ?? '',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSizes.l),
              FilledButton.tonal(
                onPressed: provider.loadGoals,
                child: Text(isVietnamese ? 'Thử lại' : 'Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, GoalsProvider provider) {
    final isVietnamese = _isVietnamese(context);
    final formatter = NumberFormat.currency(
      locale: isVietnamese ? 'vi_VN' : 'en_US',
      symbol: isVietnamese ? 'đ' : 'VND ',
      decimalDigits: 0,
    );
    final currentAmountText = formatter.format(provider.totalCurrentAmount);
    final targetAmountText = formatter.format(provider.totalTargetAmount);
    final progressPercent = (provider.amountProgress * 100).round();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSizes.l),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(_cardRadius),
            border: Border.all(
              color: Theme.of(context)
                  .extension<AppColorExtension>()!
                  .neutralBorder
                  .withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVietnamese ? 'Tiến độ mục tiêu' : 'Goal progress',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.m),
              Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: const Color(0xFFE7EEF8),
                  border: Border.all(color: const Color(0xFFCAD8EA)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 14,
                    value: provider.amountProgress,
                    backgroundColor: const Color(0xFFE7EEF8),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF2F80ED)),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.s),
              Text(
                '$currentAmountText / $targetAmountText • $progressPercent%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.m),
        _buildProgressSummary(
          context,
          provider.completionRate,
          provider.completedGoalsCount,
        ),
      ],
    );
  }

  Widget _buildProgressSummary(
    BuildContext context,
    double completionRate,
    int completedCount,
  ) {
    final isVietnamese = _isVietnamese(context);
    final percent = (completionRate * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s),
      child: Center(
        child: Text(
          '${isVietnamese ? 'Tỉ lệ hoàn thành' : 'Completion rate'}: $percent% • ${isVietnamese ? 'Đã hoàn thành' : 'Completed'}: $completedCount',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
            fontWeight: FontWeight.w500,
            fontFamily: 'GoogleSansFlex',
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, GoalsProvider provider) {
    final isVietnamese = _isVietnamese(context);
    final selectedStatus = provider.selectedStatusFilter;
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    const activeChipColor = Color(0xFFD2E4FF);

    return Column(
      children: [
        const SizedBox.shrink(),
        const SizedBox(height: AppSizes.m),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatusChip(
                context,
                label: isVietnamese ? 'Tất cả' : 'All',
                selected: selectedStatus == null,
                onSelected: () => provider.setStatusFilter(null),
                activeChipColor: activeChipColor,
              ),
              const SizedBox(width: AppSizes.m),
              _buildStatusChip(
                context,
                label: isVietnamese ? 'Đang thực hiện' : 'Ongoing',
                selected: selectedStatus == GoalStatus.ongoing,
                onSelected: () => provider.setStatusFilter(GoalStatus.ongoing),
                activeChipColor: activeChipColor,
              ),
              const SizedBox(width: AppSizes.m),
              _buildStatusChip(
                context,
                label: isVietnamese ? 'Hoàn thành' : 'Completed',
                selected: selectedStatus == GoalStatus.completed,
                onSelected: () =>
                    provider.setStatusFilter(GoalStatus.completed),
                activeChipColor: activeChipColor,
              ),
              const SizedBox(width: AppSizes.m),
              _buildStatusChip(
                context,
                label: isVietnamese ? 'Tạm dừng' : 'Paused',
                selected: selectedStatus == GoalStatus.paused,
                onSelected: () => provider.setStatusFilter(GoalStatus.paused),
                activeChipColor: activeChipColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationSectionForGoals(
    AppColorExtension colors,
    int totalItems,
  ) {
    final totalPages = totalItems == 0
        ? 1
        : (totalItems + _pageSize - 1) ~/ _pageSize;
    final current = _currentPage.clamp(1, totalPages);
    final pageStart = totalItems == 0 ? 0 : ((current - 1) * _pageSize) + 1;
    final visible = totalItems == 0
        ? 0
        : ((pageStart + _pageSize - 1) > totalItems
              ? (totalItems - pageStart + 1)
              : _pageSize);
    final pageEnd = visible == 0 ? 0 : pageStart + visible - 1;
    final progress = totalPages <= 1 ? 1.0 : current / totalPages;

    final canPrev = current > 1;
    final canNext = current < totalPages;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.m,
        vertical: AppSizes.s,
      ),
      decoration: BoxDecoration(
        color: colors.neutralSurface,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
        border: Border.all(color: colors.neutralBorder.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _textByLocale(
                    vi: 'Trang $current/$totalPages — Hiển thị $pageStart-$pageEnd/$totalItems',
                    en: 'Page $current/$totalPages — Showing $pageStart-$pageEnd/$totalItems',
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.neutralTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: canPrev
                        ? () {
                            setState(() {
                              _currentPage = (_currentPage - 1).clamp(
                                1,
                                totalPages,
                              );
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_left_rounded,
                      size: AppSizes.iconM,
                    ),
                    color: canPrev
                        ? colors.primaryMain
                        : colors.neutralTextDisable,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSizes.s),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.s,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primaryMain.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$current / $totalPages',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.primaryMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: canNext
                        ? () {
                            setState(() {
                              _currentPage = (_currentPage + 1).clamp(
                                1,
                                totalPages,
                              );
                            });
                          }
                        : null,
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      size: AppSizes.iconM,
                    ),
                    color: canNext
                        ? colors.primaryMain
                        : colors.neutralTextDisable,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.s),
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: colors.neutralBorder.withValues(alpha: 0.35),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primaryMain),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required Color activeChipColor,
  }) {
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      side: BorderSide(
        color: colors.neutralBorder.withValues(alpha: 0.72),
        width: 1,
      ),
      shape: const StadiumBorder(),
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      selectedColor: activeChipColor,
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: colors.neutralTextPrimary,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isVietnamese = _isVietnamese(context);
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 40,
            color: colors.neutralTextSecondary,
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            isVietnamese ? 'Chưa có mục tiêu nào' : 'No goals yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colors.neutralTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDrawer() {
    final isVietnamese = _isVietnamese(context);
    final formController = AddEditGoalFormController();

    AppDrawer.showAsBottomSheet(
      context: context,
      title: isVietnamese ? 'Thêm mục tiêu' : 'Add goal',
      showDragHandle: true,
      headerActions: [
        GestureDetector(
          onTap: () async {
            await formController.submit();
          },
          child: Container(
            padding: const EdgeInsets.all(AppSizes.s),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.neutralBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
            ),
            child: Icon(
              Symbols.check_rounded,
              size: AppSizes.iconL,
              color: Theme.of(
                context,
              ).extension<AppColorExtension>()!.primaryActive,
            ),
          ),
        ),
      ],
      body: AddEditGoalForm(
        controller: formController,
        onSubmit: (data) async {
          final provider = context.read<GoalsProvider>();
          final success = await provider.addGoal(
            name: data.name,
            targetAmount: data.targetAmount,
            currentAmount: data.currentAmount,
            backgroundColor: data.backgroundColor,
            icon: data.icon,
            dueDate: data.dueDate,
            note: data.note,
            status: data.status,
          );

          if (!mounted) return;

          if (success) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            AppFlash.success(
              context,
              isVietnamese ? 'Đã thêm mục tiêu' : 'Goal added',
            );
          } else {
            AppFlash.error(
              context,
              provider.errorMessage ??
                  (isVietnamese
                      ? 'Không thể thêm mục tiêu'
                      : 'Cannot add goal'),
            );
          }
        },
      ),
    );
  }

  void _openViewGoalDrawer(GoalModel goal) {
    final isVietnamese = _isVietnamese(context);
    final controller = ViewEditGoalFormController();

    final future = AppDrawer.showAsBottomSheet(
      context: context,
      title: isVietnamese ? 'Chi tiết mục tiêu' : 'Goal details',
      showDragHandle: true,
      headerActions: [
        ValueListenableBuilder<bool>(
          valueListenable: controller.isSaving,
          builder: (context, isSaving, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: controller.isEditing,
              builder: (context, isEditing, __) {
                if (isSaving) {
                  return const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                return IconButton(
                  onPressed: () {
                    if (isEditing) {
                      controller.saveChanges();
                    } else {
                      controller.startEditing();
                    }
                  },
                  icon: Icon(
                    isEditing ? Symbols.check_rounded : Symbols.edit_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  tooltip: isEditing
                      ? (isVietnamese ? 'Lưu thay đổi' : 'Save changes')
                      : (isVietnamese ? 'Chỉnh sửa' : 'Edit'),
                );
              },
            );
          },
        ),
      ],
      body: ViewEditGoalForm(
        initialGoal: goal,
        controller: controller,
        onSubmit: (data) async {
          final provider = context.read<GoalsProvider>();
          final success = await provider.updateGoal(
            id: goal.id,
            name: data.name,
            targetAmount: data.targetAmount,
            currentAmount: data.currentAmount,
            backgroundColor: data.backgroundColor,
            icon: data.icon,
            dueDate: data.dueDate,
            note: data.note,
            status: data.status,
          );

          if (!mounted) {
            return success;
          }

          if (success) {
            AppFlash.success(
              context,
              isVietnamese ? 'Đã cập nhật mục tiêu' : 'Goal updated',
            );
          } else {
            AppFlash.error(
              context,
              provider.errorMessage ??
                  (isVietnamese
                      ? 'Không thể cập nhật mục tiêu'
                      : 'Cannot update goal'),
            );
          }

          return success;
        },
      ),
    );

    future.whenComplete(controller.dispose);
  }

  Future<void> _handleDelete(GoalModel goal) async {
    final isVietnamese = _isVietnamese(context);

    final confirm = await AppConfirmDialog.show(
      context: context,
      title: isVietnamese ? 'Xác nhận' : 'Confirmation',
      message: isVietnamese
          ? 'Bạn có chắc muốn xoá mục tiêu này không?'
          : 'Are you sure you want to delete this goal?',
      confirmText: isVietnamese ? 'Xoá' : 'Delete',
      isDestructive: true,
    );

    if (!confirm || !mounted) {
      return;
    }

    final provider = context.read<GoalsProvider>();
    final success = await provider.deleteGoal(goal.id);

    if (!mounted) return;

    if (success) {
      AppFlash.success(
        context,
        isVietnamese ? 'Đã xoá mục tiêu' : 'Goal deleted',
      );
    } else {
      AppFlash.error(
        context,
        provider.errorMessage ??
            (isVietnamese ? 'Xoá thất bại' : 'Delete failed'),
      );
    }
  }

  bool _isVietnamese(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'vi';
  }

  String _textByLocale({required String vi, required String en}) {
    return _isVietnamese(context) ? vi : en;
  }
}
