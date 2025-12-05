import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/layout/main_layout.dart';
import 'package:zenit/core/services/auth_service.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/theme/app_theme.dart';
import 'package:zenit/core/widgets/app_drawer.dart';
import 'package:zenit/features/home_childs/transaction/forms/add_transaction_form.dart';
import 'package:zenit/features/home_childs/transaction/services/transaction_service.dart';
import 'package:zenit/features/main/models/action_item.dart';
import 'package:zenit/features/main/models/home_action_item.dart';
import 'package:zenit/features/main/widgets/home/home_action_grid.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final AuthService _authService = AuthService();
  final TransactionService _transactionService = TransactionService();
  
  String _userName = '';
  bool _isAuthenticated = false;
  bool _isLoading = true;

  /// List of action items for the HomeActionGrid
  final List<HomeActionItem> _actionItems = [
    // Expense - Light blue with white icon containing arrows
    HomeActionItem(
      title: 'Transaction',
      icon: Icons.swap_horiz_rounded,
      backgroundColor: AppColors.light.secondaryMain,
      iconColor: AppColors.light.primaryMain,
      type: ActionType.transaction,
    ),
    // Quick import - Primary blue with white icon
    HomeActionItem(
      title: 'Quick import',
      icon: Icons.library_add_rounded,
      backgroundColor: AppColors.light.primaryMain,
      iconColor: Colors.white,
      type: ActionType.quickImport,
      useGradient: true,
      gradientColors: [
        AppColors.light.primaryMain,
        AppColors.light.primaryActive,
      ],
    ),
    // Goals - Light blue with flag icon
    HomeActionItem(
      title: 'Goals',
      icon: Icons.flag_rounded,
      backgroundColor: AppColors.light.secondaryMain,
      iconColor: AppColors.light.primaryMain,
      type: ActionType.goals,
    ),
    // More action - Primary blue with grid icon
    HomeActionItem(
      title: 'More actions',
      icon: Icons.apps_rounded,
      backgroundColor: AppColors.light.primaryMain,
      iconColor: Colors.white,
      type: ActionType.moreActions,
      useGradient: true,
      gradientColors: [
        AppColors.light.primaryMain,
        AppColors.light.primaryActive,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() => _isLoading = true);
    
    final isAuth = await _authService.isAuthenticated();
    
    if (isAuth) {
      final response = await _authService.getUserInfo();
      
      if (response != null && response.statusCode == 200) {
        setState(() {
          _isAuthenticated = true;
          _userName = response.data['username'] ?? 'User';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  /// Handle action item tap using switch-case
  void _handleActionTap(HomeActionItem item) {
    switch (item.type) {
      case ActionType.transaction:
        _navigateToTransaction();
        break;
      case ActionType.quickImport:
        _navigateToQuickImport();
        break;
      case ActionType.goals:
        _navigateToGoals();
        break;
      case ActionType.moreActions:
        _showMoreActions();
        break;
    }
  }

  // Navigation methods - implement actual navigation logic here
  void _navigateToTransaction() {
    TransactionFormData? Function()? getFormData;
    
    AppDrawer.showAsBottomSheet(
      context: context,
      title: "Add transaction",
      showCloseButton: false,
      showDragHandle: true,
      headerActions: [
        IconButton(
          onPressed: () => _handleCreateTransaction(getFormData),
          icon: Icon(
            Icons.check_circle_outline_rounded,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
      ],
      body: AddTransactionForm(
        onFormReady: (getData) {
          getFormData = getData;
        },
      ),
    );
  }

  /// Business logic: Tạo transaction mới
  Future<void> _handleCreateTransaction(
    TransactionFormData? Function()? getFormData,
  ) async {
    if (getFormData == null) return;

    final formData = getFormData();
    if (formData == null) return; // Validation failed

    try {
      await _transactionService.createTransaction(
        title: formData.title,
        note: formData.note,
        amount: formData.amount,
        transactionDate: formData.transactionDate,
        categoryId: formData.categoryId,
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction added successfully!'),
            backgroundColor: Theme.of(context).extension<AppColorExtension>()!.successIcon,
          ),
        );
        // TODO: Refresh transaction list nếu cần
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).extension<AppColorExtension>()!.errorIcon,
          ),
        );
      }
    }
  }


  void _navigateToQuickImport() {
    // TODO: Navigate to Quick Import screen
    _showSnackBar('Navigate to Quick Import');
  }

  void _navigateToGoals() {
    // TODO: Navigate to Goals screen
    _showSnackBar('Navigate to Goals');
  }
  void _showMoreActions() {
    // TODO: Show more actions bottom sheet or screen
    _showSnackBar('Show More Actions');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return MainLayout(
      appBar: CommonAppBar(
        title: _isAuthenticated 
            ? 'Welcome back, $_userName' 
            : 'Home - Bạn chưa đăng nhập',
        showSecondaryText: _isAuthenticated,
        secondaryText: _isAuthenticated ? "Have a nice day!" : null,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.l),
            // Action Grid Section
            HomeActionGrid(
              items: _actionItems,
              onItemTap: _handleActionTap,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}
