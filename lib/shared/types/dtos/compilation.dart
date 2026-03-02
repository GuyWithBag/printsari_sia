import 'package:printsari_sia/shared/types/types.dart';

// TODO: WIP

// ============================================================================
// FINANCIAL METRICS DTOs
// ============================================================================

class DailyMetrics {
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;
  final int transactionCount;
  final double profitMargin; // Percentage

  DailyMetrics({
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
    required this.transactionCount,
    required this.profitMargin,
  });

  factory DailyMetrics.fromJson(Map<String, dynamic> json) {
    return DailyMetrics(
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      profitMargin: (json['profit_margin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
      'transaction_count': transactionCount,
      'profit_margin': profitMargin,
    };
  }
}

class WeeklyMetrics {
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;
  final double dailyAverage;

  WeeklyMetrics({
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
    required this.dailyAverage,
  });

  factory WeeklyMetrics.fromJson(Map<String, dynamic> json) {
    return WeeklyMetrics(
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      dailyAverage: (json['daily_average'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
      'daily_average': dailyAverage,
    };
  }
}

class MonthlyMetrics {
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;
  final double dailyAverage;
  final int transactionCount;
  final double profitMargin; // Percentage

  MonthlyMetrics({
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
    required this.dailyAverage,
    required this.transactionCount,
    required this.profitMargin,
  });

  factory MonthlyMetrics.fromJson(Map<String, dynamic> json) {
    return MonthlyMetrics(
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      dailyAverage: (json['daily_average'] as num).toDouble(),
      transactionCount: json['transaction_count'] as int,
      profitMargin: (json['profit_margin'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
      'daily_average': dailyAverage,
      'transaction_count': transactionCount,
      'profit_margin': profitMargin,
    };
  }
}

class TrendDataPoint {
  final String date; // Formatted date string for display
  final double revenue;
  final double storeRevenue;
  final double printingRevenue;
  final double expenses;
  final double profit;

  TrendDataPoint({
    required this.date,
    required this.revenue,
    required this.storeRevenue,
    required this.printingRevenue,
    required this.expenses,
    required this.profit,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      storeRevenue: (json['store_revenue'] as num).toDouble(),
      printingRevenue: (json['printing_revenue'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'revenue': revenue,
      'store_revenue': storeRevenue,
      'printing_revenue': printingRevenue,
      'expenses': expenses,
      'profit': profit,
    };
  }
}

enum DepartmentName {
  store('Store'),
  printing('Printing');

  final String value;
  const DepartmentName(this.value);

  static DepartmentName fromString(String value) {
    return DepartmentName.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid DepartmentName: $value'),
    );
  }
}

class DepartmentRevenue {
  final String name; // 'Store' or 'Printing'
  final double value;
  final double percentage;
  final String color;

  DepartmentRevenue({
    required this.name,
    required this.value,
    required this.percentage,
    required this.color,
  });

  // Convenience getter for type-safe department name
  DepartmentName get departmentName => DepartmentName.fromString(name);

  factory DepartmentRevenue.fromJson(Map<String, dynamic> json) {
    return DepartmentRevenue(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
      color: json['color'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'percentage': percentage,
      'color': color,
    };
  }
}

class ExpenseByCategory {
  final String category;
  final double amount;
  final double percentage;

  ExpenseByCategory({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory ExpenseByCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseByCategory(
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'amount': amount, 'percentage': percentage};
  }
}

class FinancialReport {
  final int id;
  final int periodId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional joined data
  final ReportPeriod? period;
  final List<DailyMetrics>? dailyMetrics;
  final List<WeeklyMetrics>? weeklyMetrics;
  final List<MonthlyMetrics>? monthlyMetrics;
  final List<TrendDataPoint>? trendDataPoints;
  final List<DepartmentRevenue>? departmentRevenues;
  final List<ExpenseByCategory>? expensesByCategory;

  FinancialReport({
    required this.id,
    required this.periodId,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.period,
    this.dailyMetrics,
    this.weeklyMetrics,
    this.monthlyMetrics,
    this.trendDataPoints,
    this.departmentRevenues,
    this.expensesByCategory,
  });

  factory FinancialReport.fromJson(Map<String, dynamic> json) {
    return FinancialReport(
      id: json['id'] as int,
      periodId: json['period_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      period: json['report_periods'] != null
          ? ReportPeriod.fromJson(
              json['report_periods'] as Map<String, dynamic>,
            )
          : null,
      dailyMetrics: json['daily_metrics'] != null
          ? (json['daily_metrics'] as List)
                .map(
                  (item) => DailyMetrics.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      weeklyMetrics: json['weekly_metrics'] != null
          ? (json['weekly_metrics'] as List)
                .map(
                  (item) =>
                      WeeklyMetrics.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      monthlyMetrics: json['monthly_metrics'] != null
          ? (json['monthly_metrics'] as List)
                .map(
                  (item) =>
                      MonthlyMetrics.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      trendDataPoints: json['trend_data_points'] != null
          ? (json['trend_data_points'] as List)
                .map(
                  (item) =>
                      TrendDataPoint.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      departmentRevenues: json['department_revenues'] != null
          ? (json['department_revenues'] as List)
                .map(
                  (item) =>
                      DepartmentRevenue.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      expensesByCategory: json['expenses_by_category'] != null
          ? (json['expenses_by_category'] as List)
                .map(
                  (item) =>
                      ExpenseByCategory.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period_id': periodId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'period_id': periodId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    };
  }
}
