import 'package:flutter/material.dart';
import 'package:zenit/core/layout/app_bar.dart';
import 'package:zenit/core/theme/app_colors.dart';
import 'package:zenit/core/theme/app_sizes.dart';
import 'package:zenit/core/widgets/button.dart';
import 'package:zenit/features/statistics/models/statistics_model.dart';
import 'package:zenit/features/statistics/services/statistics_service.dart';
import 'package:zenit/features/statistics/widgets/date_range_selector.dart';
import 'package:zenit/features/statistics/widgets/statistics_legend.dart';
import 'package:zenit/features/statistics/widgets/statistics_pie_chart.dart';

class StatisticContent extends StatefulWidget {
  const StatisticContent({super.key});

  @override
  State<StatisticContent> createState() => _StatisticContentState();
}

class _StatisticContentState extends State<StatisticContent> {
  final StatisticsService _statisticsService = StatisticsService();
  
  // Date range state
  late DateTime _startDate;
  late DateTime _endDate;
  
  // Data state
  Future<StatisticsResponseModel>? _statisticsFuture;

  @override
  void initState() {
    super.initState();
    // Mặc định: từ đầu năm đến hiện tại
    _startDate = DateTime(DateTime.now().year, 1, 1);
    _endDate = DateTime.now();
    _loadStatistics();
  }

  /// Load dữ liệu thống kê từ API
  void _loadStatistics() {
    setState(() {
      _statisticsFuture = _statisticsService.getStatistics(
        from: _startDate,
        to: _endDate,
      );
    });
  }

  /// Hiển thị date picker cho start date
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2025),
      lastDate: _endDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.light.primaryMain,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.light.neutralTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _loadStatistics();
    }
  }

  /// Hiển thị date picker cho end date
  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.light.primaryMain,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.light.neutralTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _loadStatistics();
    }
  }

  /// Export báo cáo
  Future<void> _exportReport() async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _statisticsService.exportReport(
        from: _startDate,
        to: _endDate,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading
        _showSuccessSnackBar('Xuất báo cáo thành công!');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showErrorSnackBar('Xuất báo cáo thất bại: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.light.successIcon,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.light.errorIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light.neutralBackground,
      appBar: CommonAppBar(
        title: 'Thống kê',
        showSecondaryText: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadStatistics();
          await _statisticsFuture;
        },
        color: AppColors.light.primaryMain,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chon ngay
              DateRangeSelector(
                startDate: _startDate,
                endDate: _endDate,
                onStartDateTap: _pickStartDate,
                onEndDateTap: _pickEndDate,
              ),
              
              const SizedBox(height: AppSizes.l),

              // Statistics chart
              FutureBuilder<StatisticsResponseModel>(
                future: _statisticsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  if (!snapshot.hasData || snapshot.data!.items.isEmpty) {
                    return _buildEmptyState();
                  }

                  final statistics = snapshot.data!;
                  return _buildStatisticsContent(statistics);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: CircularProgressIndicator(
          color: AppColors.light.primaryMain,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.light.errorIcon,
            ),
            const SizedBox(height: AppSizes.m),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.w600,
                color: AppColors.light.neutralTextPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.textS,
                color: AppColors.light.neutralTextSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.l),
            ElevatedButton.icon(
              onPressed: _loadStatistics,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.light.primaryMain,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.light.neutralTextDisable,
            ),
            const SizedBox(height: AppSizes.m),
            Text(
              'Chưa có dữ liệu',
              style: TextStyle(
                fontSize: AppSizes.textL,
                fontWeight: FontWeight.w600,
                color: AppColors.light.neutralTextPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.s),
            Text(
              'Không có giao dịch nào trong khoảng thời gian này',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppSizes.textS,
                color: AppColors.light.neutralTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsContent(StatisticsResponseModel statistics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chart Container
        Container(
          padding: const EdgeInsets.all(AppSizes.l),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusSmall),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(43, 0, 0, 0),
                blurRadius: 5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Pie Chart
              StatisticsPieChart(groups: statistics.items),
              
              const SizedBox(height: AppSizes.l),
              
              // Legend
              StatisticsLegend(groups: statistics.items),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.l),
        // Export Button
        AppButton(
          text: 'Xuất báo cáo',
          icon: Icons.download_rounded,
          onPressed: _exportReport,
          backgroundColor: AppColors.light.primaryMain,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.l, vertical: AppSizes.m),
        )

      ],
    );
  }
}
