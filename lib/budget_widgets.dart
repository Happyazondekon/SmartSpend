import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartspend/services/auth_service.dart';
import 'models/transaction.dart';
import 'budget_logic.dart';
import 'faq_chatbot.dart';
import 'package:smartspend/screens/profile_screen.dart';
import '../models/financial_goal.dart';
import '../screens/financial_goals_screen.dart';
import 'models/user_data.dart';
import 'services/premium_service.dart';
import 'design_system.dart';

class BudgetWidgets {
  final BuildContext context;
  final BudgetLogic budgetLogic;
  final List<IconData> availableIcons;
  final List<Color> availableColors;
  final PremiumService _premiumService = PremiumService();

  BudgetWidgets({
    required this.context,
    required this.budgetLogic,
    required this.availableIcons,
    required this.availableColors,
  });

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ===================================================================
  // ====================== ONGLET BUDGET =============================
  // ===================================================================

  Widget buildBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkyViewHeader(),
          const SizedBox(height: 24),
          _buildAvailableBalanceCard(),
          const SizedBox(height: 16),
          _buildMonthlyIncomeCard(),
          const SizedBox(height: 16),
          _buildTotalBudgetProgress(),
          const SizedBox(height: 24),
          _buildCoreAllocationsSection(),
          const SizedBox(height: 24),
          _buildWeeklyInsightsCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSkyViewHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT ALLOCATION',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppDesign.primary(_isDark),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'The ',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppDesign.textPrimary(_isDark),
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Sky View',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppDesign.primary(_isDark),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Of Wealth.',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppDesign.textPrimary(_isDark),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Financial sovereignty begins with precision.\nEvery ${budgetLogic.getCurrency()} accounted for, every goal within reach.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppDesign.textSecondary(_isDark),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableBalanceCard() {
    final salary = budgetLogic.getSalary();
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();
    
    double totalSpent = 0;
    budget.forEach((key, value) {
      totalSpent += value['spent'] as double;
    });
    final availableBalance = salary - totalSpent;

    return SmartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  color: AppDesign.primary(_isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AVAILABLE BALANCE',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.textSecondary(_isDark),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(availableBalance),
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: availableBalance >= 0 
                      ? AppDesign.textPrimary(_isDark)
                      : AppDesign.error,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  currency,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyIncomeCard() {
    final salary = budgetLogic.getSalary();
    final currency = budgetLogic.getCurrency();

    return SmartCard(
      onTap: _showSalaryEditDialog,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppDesign.primary(_isDark).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: AppDesign.primary(_isDark),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Income',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppDesign.textSecondary(_isDark),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatCurrency(salary),
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppDesign.textPrimary(_isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currency,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppDesign.textSecondary(_isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                color: AppDesign.textSecondary(_isDark),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBudgetProgress() {
    final salary = budgetLogic.getSalary();
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();
    
    double totalSpent = 0;
    budget.forEach((key, value) {
      totalSpent += value['spent'] as double;
    });
    
    final progress = salary > 0 ? (totalSpent / salary).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return BudgetProgressCard(
      title: 'Total Budget Progress',
      subtitle: 'You have used $percentage% of your monthly plan',
      spent: totalSpent,
      total: salary,
      currency: currency,
      color: AppDesign.primary(_isDark),
    );
  }

  Widget _buildCoreAllocationsSection() {
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Core Allocations',
          trailing: TextButton.icon(
            onPressed: showAddCategoryDialog,
            icon: Icon(Icons.add, size: 18, color: AppDesign.primary(_isDark)),
            label: Text(
              'Add Category',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppDesign.primary(_isDark),
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        if (budget.isEmpty)
          _buildEmptyAllocationsState()
        else
          ...budget.entries.map((entry) {
            final spent = entry.value['spent'] as double;
            final allocated = entry.value['amount'] as double;
            final icon = entry.value['icon'] as IconData;
            final color = entry.value['color'] as Color;
            final percent = entry.value['percent'] as double;
            
            return AllocationCard(
              name: entry.key,
              subtitle: '${(percent * 100).toStringAsFixed(0)}% of income',
              spent: spent,
              allocated: allocated,
              currency: currency,
              icon: icon,
              color: color,
              onEdit: () => showEditCategoryDialog(entry.key),
              onDelete: () => budgetLogic.deleteCategory(entry.key),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEmptyAllocationsState() {
    return SmartCard(
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 48,
            color: AppDesign.textSecondary(_isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'No allocations yet',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppDesign.textPrimary(_isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first budget category to start tracking',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppDesign.textSecondary(_isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsightsCard() {
    final budget = budgetLogic.getBudget();
    final salary = budgetLogic.getSalary();
    
    double totalSpent = 0;
    budget.forEach((key, value) {
      totalSpent += value['spent'] as double;
    });
    
    final savingsRate = salary > 0 ? ((salary - totalSpent) / salary * 100).clamp(0, 100) : 0;
    
    String insightMessage;
    if (savingsRate >= 30) {
      insightMessage = 'Excellent! You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income. Keep up the great work!';
    } else if (savingsRate >= 15) {
      insightMessage = 'Good progress! You\'re on track with ${savingsRate.toStringAsFixed(0)}% savings this month.';
    } else if (savingsRate > 0) {
      insightMessage = 'Consider reviewing your spending. Current savings rate: ${savingsRate.toStringAsFixed(0)}%';
    } else {
      insightMessage = 'You\'re spending more than your income. Review your budget allocations.';
    }

    return InsightCard(
      title: 'Weekly Insights',
      content: insightMessage,
      actionLabel: 'View Full Stats',
      onAction: () {
        // Navigate to stats tab
      },
      gradientStart: AppDesign.primary(_isDark),
      gradientEnd: AppDesign.accent(_isDark),
    );
  }

  void _showSalaryEditDialog() {
    final controller = TextEditingController(
      text: budgetLogic.getSalary() > 0 ? budgetLogic.getSalary().toStringAsFixed(0) : '',
    );
    String selectedCurrency = budgetLogic.getCurrency();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Set Monthly Income',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Your monthly income',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                suffix: DropdownButton<String>(
                  value: selectedCurrency,
                  underline: const SizedBox(),
                  items: ['XOF', 'USD', 'EUR', 'GBP', 'CAD', 'NGN', 'GHS', 'AUD', 'JPY', 'CNY']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    selectedCurrency = value!;
                    (context as Element).markNeedsBuild();
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newSalary = double.tryParse(controller.text) ?? 0;
              budgetLogic.setSalary(newSalary);
              budgetLogic.setCurrency(selectedCurrency);
              budgetLogic.calculateBudget();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return NumberFormat('#,###', 'en_US').format(amount.toInt());
    }
    return amount.toStringAsFixed(0);
  }

  // ===================================================================
  // ====================== ONGLET STATISTIQUES ======================
  // ===================================================================

  Widget buildStatsTab() {
    final filteredTransactions = budgetLogic.getFilteredTransactions();
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();
    final selectedMonth = budgetLogic.getSelectedMonth();
    
    double totalSpent = filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);
    
    // Calculate daily average
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final currentDay = selectedMonth.month == DateTime.now().month 
        ? DateTime.now().day 
        : daysInMonth;
    final dailyAvg = currentDay > 0 ? totalSpent / currentDay : 0.0;
    
    // Find peak day
    Map<int, double> dailySpending = {};
    for (var t in filteredTransactions) {
      final day = t.date.day;
      dailySpending[day] = (dailySpending[day] ?? 0) + t.amount;
    }
    int peakDay = 1;
    double peakAmount = 0;
    dailySpending.forEach((day, amount) {
      if (amount > peakAmount) {
        peakDay = day;
        peakAmount = amount;
      }
    });
    
    // Find top category
    MapEntry<String, Map<String, dynamic>>? topCategory;
    double maxSpent = 0;
    budget.forEach((key, value) {
      final spent = value['spent'] as double;
      if (spent > maxSpent) {
        maxSpent = spent;
        topCategory = MapEntry(key, value);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppDesign.textPrimary(_isDark),
                    height: 1.1,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Intelligence ',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppDesign.primary(_isDark),
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
                        text: 'Breakdown',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppDesign.textPrimary(_isDark),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your spending DNA for the period of ${DateFormat('MMMM yyyy').format(selectedMonth)}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Total Spending Circle
          Center(
            child: SmartCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressWidget(
                    progress: budgetLogic.getSalary() > 0 
                        ? totalSpent / budgetLogic.getSalary()
                        : 0,
                    value: _formatCurrency(totalSpent),
                    subtitle: 'TOTAL SPENDING',
                    currency: currency,
                    size: 160,
                    color: AppDesign.primary(_isDark),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('Daily Avg', '${dailyAvg.toStringAsFixed(0)}\n$currency'),
                      Container(width: 1, height: 40, color: AppDesign.surfaceElevated(_isDark)),
                      _buildStatColumn('Peak Day', '${_getDayName(peakDay)}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top Category Card
          if (topCategory != null && maxSpent > 0)
            _buildTopCategoryCard(topCategory!, totalSpent, currency),
          
          const SizedBox(height: 16),
          
          // AI Insights Section
          _buildAIInsightsSection(totalSpent, currency),
          
          const SizedBox(height: 24),
          
          // Category Breakdown
          SectionHeader(
            title: 'Category Breakdown',
            actionLabel: 'VIEW ALL',
            onAction: () {},
          ),
          
          ...budget.entries
              .where((e) => e.value['spent'] > 0)
              .map((entry) => _buildCategoryBreakdownItem(
                entry.key,
                entry.value['spent'] as double,
                entry.value['icon'] as IconData,
                entry.value['color'] as Color,
                filteredTransactions.where((t) => t.category == entry.key).length,
                totalSpent,
                currency,
              ))
              .toList(),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppDesign.primary(_isDark),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppDesign.textPrimary(_isDark),
          ),
        ),
      ],
    );
  }
  
  String _getDayName(int day) {
    final date = DateTime(budgetLogic.getSelectedMonth().year, budgetLogic.getSelectedMonth().month, day);
    return DateFormat('EEE, d').format(date);
  }
  
  Widget _buildTopCategoryCard(MapEntry<String, Map<String, dynamic>> category, double totalSpent, String currency) {
    final spent = category.value['spent'] as double;
    final allocated = category.value['amount'] as double;
    final icon = category.value['icon'] as IconData;
    final color = category.value['color'] as Color;
    final percentage = totalSpent > 0 ? (spent / totalSpent * 100).toInt() : 0;
    final budgetUtilization = allocated > 0 ? (spent / allocated * 100).toInt() : 0;

    return SmartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppDesign.primary(_isDark).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Top Category',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppDesign.primary(_isDark),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            category.key,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppDesign.textPrimary(_isDark),
            ),
          ),
          Text(
            '$spent $currency • $percentage% of wallet',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppDesign.textSecondary(_isDark),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Utilization',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppDesign.textSecondary(_isDark),
                ),
              ),
              Text(
                '$budgetUtilization%',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: budgetUtilization > 90 ? AppDesign.warning : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppDesign.surfaceElevated(_isDark),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) => AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 8,
                  width: constraints.maxWidth * (budgetUtilization / 100).clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          if (budgetUtilization > 80)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: AppDesign.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nearing your limit for this category. ${(allocated - spent).toStringAsFixed(0)} $currency remaining.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppDesign.textSecondary(_isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildAIInsightsSection(double totalSpent, String currency) {
    final salary = budgetLogic.getSalary();
    final savingsRate = salary > 0 ? ((salary - totalSpent) / salary * 100) : 0;
    
    return SmartCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppDesign.primary(_isDark), size: 20),
              const SizedBox(width: 8),
              Text(
                'AI INSIGHTS',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.textSecondary(_isDark),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            Icons.analytics_outlined,
            'Spending Analysis',
            savingsRate >= 20 
                ? 'Great job! You\'re saving ${savingsRate.toStringAsFixed(0)}% of your income.'
                : 'Consider reducing non-essential spending to increase savings.',
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            Icons.savings_outlined,
            'Savings Goal',
            'On track to save ${(salary - totalSpent).toStringAsFixed(0)} $currency by month end.',
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                showElegantFAQChatBot(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppDesign.primary(_isDark),
                side: BorderSide(color: AppDesign.primary(_isDark)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                'Review Full Report',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInsightItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppDesign.primary(_isDark).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppDesign.primary(_isDark), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.textPrimary(_isDark),
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppDesign.textSecondary(_isDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryBreakdownItem(String name, double spent, IconData icon, Color color, int transactionCount, double totalSpent, String currency) {
    final percentage = totalSpent > 0 ? (spent / totalSpent * 100).toInt() : 0;
    
    return SmartCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppDesign.textPrimary(_isDark),
                  ),
                ),
                Text(
                  '$transactionCount Transactions',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${spent.toStringAsFixed(0)} $currency',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.textPrimary(_isDark),
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppDesign.textSecondary(_isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // =================== ONGLET TRANSACTIONS =========================
  // ===================================================================

  Widget buildTransactionsTab() {
    final filteredTransactions = budgetLogic.getFilteredTransactions();
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();
    final selectedMonth = budgetLogic.getSelectedMonth();
    
    double totalSpent = filteredTransactions.fold(0.0, (sum, item) => sum + item.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec mois
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT PERIOD',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppDesign.primary(_isDark),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: budgetLogic.showMonthPicker,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMMM').format(selectedMonth),
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppDesign.textPrimary(_isDark),
                              height: 1,
                            ),
                          ),
                          Text(
                            selectedMonth.year.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: AppDesign.textPrimary(_isDark),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Spent',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppDesign.textSecondary(_isDark),
                          ),
                        ),
                        Text(
                          '$currency${_formatCurrency(totalSpent)}',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppDesign.primary(_isDark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Spending Velocity Chart
          _buildSpendingVelocityCard(filteredTransactions),
          
          const SizedBox(height: 16),
          
          // Goal Progress Card (si objectifs existent)
          _buildGoalProgressHighlight(),
          
          const SizedBox(height: 24),
          
          // Recent Activity Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppDesign.textPrimary(_isDark),
                  ),
                ),
                TextButton(
                  onPressed: () => budgetLogic.exportTransactions(),
                  child: Text(
                    'Export CSV',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppDesign.primary(_isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Transaction List
          if (filteredTransactions.isEmpty)
            _buildEmptyTransactionsState()
          else
            ...filteredTransactions.take(20).map((transaction) {
              final categoryData = budget[transaction.category];
              return TransactionItem(
                title: transaction.description,
                subtitle: '${DateFormat('MMM dd, HH:mm').format(transaction.date)} • ${transaction.category}',
                amount: transaction.amount,
                currency: currency,
                icon: categoryData?['icon'] ?? Icons.receipt_outlined,
                color: categoryData?['color'] ?? AppDesign.primary(_isDark),
                onTap: () => showTransactionOptionsDialog(transaction),
              );
            }).toList(),
          
          if (filteredTransactions.length > 20)
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppDesign.textSecondary(_isDark),
                    side: BorderSide(color: AppDesign.textMuted(_isDark)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Load Previous Transactions'),
                ),
              ),
            ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }
  
  Widget _buildSpendingVelocityCard(List<Transaction> transactions) {
    // Group by week
    Map<int, double> weeklySpending = {1: 0, 2: 0, 3: 0, 4: 0};
    for (var t in transactions) {
      final week = ((t.date.day - 1) ~/ 7) + 1;
      if (week >= 1 && week <= 4) {
        weeklySpending[week] = (weeklySpending[week] ?? 0) + t.amount;
      }
    }
    
    final maxSpending = weeklySpending.values.fold(0.0, (a, b) => a > b ? a : b);

    return SmartCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending Velocity',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppDesign.textPrimary(_isDark),
                ),
              ),
              Text(
                'Daily outflow intensity',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppDesign.textSecondary(_isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final week = index + 1;
                final spending = weeklySpending[week] ?? 0;
                final height = maxSpending > 0 ? (spending / maxSpending * 80) : 10;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 40,
                      height: height.clamp(10.0, 80.0).toDouble(),
                      decoration: BoxDecoration(
                        color: AppDesign.primary(_isDark).withOpacity(
                          spending == maxSpending ? 1.0 : 0.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'WEEK 0$week',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppDesign.textSecondary(_isDark),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalProgressHighlight() {
    return StreamBuilder<UserData?>(
      stream: budgetLogic.getUserDataStream(),
      builder: (context, snapshot) {
        final goals = snapshot.data?.financialGoals ?? [];
        final activeGoals = goals.where((g) => !g.isCompleted).toList();
        
        if (activeGoals.isEmpty) return const SizedBox();
        
        // Get the goal with highest progress
        activeGoals.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
        final topGoal = activeGoals.first;
        final progress = topGoal.progressPercentage / 100;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppDesign.primary(_isDark).withOpacity(0.2),
                AppDesign.accent(_isDark).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
            border: Border.all(
              color: AppDesign.primary(_isDark).withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        topGoal.icon,
                        color: AppDesign.textPrimary(_isDark),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  topGoal.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppDesign.textPrimary(_isDark),
                  ),
                ),
                Text(
                  'Almost there! ${topGoal.progressPercentage.toStringAsFixed(0)}% funded.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${budgetLogic.getCurrency()}${_formatCurrency(topGoal.currentAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppDesign.primary(_isDark),
                      ),
                    ),
                    Text(
                      'TARGET ${budgetLogic.getCurrency()}${_formatCurrency(topGoal.targetAmount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppDesign.textSecondary(_isDark),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) => AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 8,
                        width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyTransactionsState() {
    return SmartCard(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppDesign.textSecondary(_isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppDesign.textPrimary(_isDark),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first transaction to start tracking your spending.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppDesign.textSecondary(_isDark),
            ),
          ),
        ],
      ),
    );
  }

  // ===================================================================
  // ====================== COMPOSANTS COMMUNS ========================
  // ===================================================================

  Widget buildMonthSelectorHeader({bool showExport = true}) {
    final selectedMonth = budgetLogic.getSelectedMonth();
    final filteredTransactions = budgetLogic.getFilteredTransactions();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppDesign.surface(_isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: budgetLogic.showMonthPicker,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_month_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  DateFormat('MMMM yyyy', 'fr_FR').format(selectedMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (showExport && filteredTransactions.isNotEmpty)
            PopupMenuButton<String>(
              icon: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.ios_share_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              position: PopupMenuPosition.under,
              offset: Offset(0, 10),
              onSelected: (value) async {
                if (value == 'csv') {
                  budgetLogic.exportTransactions();
                } else if (value == 'pdf') {
                  await _handlePDFExport();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'csv',
                  child: Row(
                    children: [
                      Icon(Icons.table_chart_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      SizedBox(width: 12),
                      Text('Exporter en CSV'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined,
                          color: Theme.of(context).colorScheme.onSurface),
                      SizedBox(width: 12),
                      Expanded(child: Text('Exporter en PDF')),
                      _premiumService.buildPremiumBadge(),
                    ],
                  ),
                ),
              ],
              tooltip: 'Options d\'export',
            ),
        ],
      ),
    );
  }

  // Ajoutez cette nouvelle méthode dans BudgetWidgets
  Future<void> _handlePDFExport() async {
    try {
      final canExport = await _premiumService.canExportPDF();
      final isPremium = await _premiumService.isPremiumUser();

      if (canExport) {
        // Permettre l'export
        if (!isPremium) {
          await _premiumService.incrementPDFExports();
          final remaining = await _premiumService.getRemainingPDFExports();

          if (remaining == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Export réussi ! Plus d\'essais gratuits disponibles.'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Premium',
                  textColor: Colors.white,
                  onPressed: () => _showUpgradeDialog('export PDF'),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Export réussi ! $remaining essais restants.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }

        // Procéder à l'export
        await budgetLogic.exportTransactionsToPDF();

      } else {
        // Afficher le dialogue Premium
        final remaining = await _premiumService.getRemainingPDFExports();
        _premiumService.showPremiumDialog(
          context,
          feature: 'l\'export PDF',
          remainingUses: remaining,
          onUpgrade: () => _showUpgradeDialog('export PDF'),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'export PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Ajoutez cette nouvelle méthode dans BudgetWidgets
  Future<void> _showUpgradeDialog(String feature) async {
    final purchased = await _premiumService.simulatePurchase(context);

    if (purchased) {
      // Simuler l'achat réussi
      try {
        await _premiumService.upgradeToPremium();

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.star, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Bienvenue Premium !'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    size: 64,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Félicitations ! Vous avez maintenant accès à toutes les fonctionnalités Premium.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Vous pouvez maintenant utiliser $feature sans limite !',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Parfait !'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à niveau'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ===================================================================
  // ====================== DRAWER NAVIGATION =========================
  // ===================================================================

  Widget buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SmartSpend',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Votre assistant financier personnel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'NOTIFICATIONS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  _buildListTile(
                    title: 'Rappels quotidiens',
                    subtitle: 'Rappel du soir pour vos transactions',
                    icon: Icons.notifications_active_outlined,
                    isSwitch: true,
                    switchValue: budgetLogic.getNotificationsEnabled(),
                    onSwitchChanged: budgetLogic.toggleDailyReminders,
                  ),
                  const Divider(indent: 24, endIndent: 24, height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'GESTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  _buildListTile(
                    title: 'Objectifs financiers',
                    subtitle: 'Définir et suivre vos objectifs d\'épargne',
                    icon: Icons.track_changes_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FinancialGoalsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(indent: 24, endIndent: 24, height: 1, thickness: 1),
                  _buildListTile(
                    title: 'Assistant financier',
                    subtitle: 'Obtenez des conseils personnalisés',
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () async {
                      Navigator.pop(context);

                      try {
                        final canUse = await _premiumService.canUseChatbot();

                        if (canUse) {
                          // Ouvrir l'assistant - le compteur sera incrémenté uniquement 
                          // quand l'utilisateur posera vraiment une question
                          showElegantFAQChatBot(context);

                        } else {
                          // Afficher le dialogue Premium
                          final remaining = await _premiumService.getRemainingChatbotUses();
                          _premiumService.showPremiumDialog(
                            context,
                            feature: 'l\'assistant financier',
                            remainingUses: remaining,
                            onUpgrade: () => _showUpgradeDialog('assistant financier'),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de l\'accès à l\'assistant'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                  _buildListTile(
                    title: 'Mon Profil',
                    subtitle: 'Gérez vos informations de compte',
                    icon: Icons.person_outline_rounded,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          maintainState: true,
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24, top: 16),
              child: Text(
                'SmartSpend v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    bool isSwitch = false,
    bool? switchValue,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: isSwitch
          ? SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        secondary: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        )
            : null,
        value: switchValue ?? false,
        onChanged: onSwitchChanged,
        activeColor: Theme.of(context).colorScheme.primary,
        activeTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
      )
          : ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        )
            : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  // ===================================================================
  // ====================== DIALOGUES & POPUPS ========================
  // ===================================================================

  void showAddTransactionDialog() {
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();

    if(budget.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez d\'abord créer une catégorie.'))
      );
      return;
    }

    String selectedCategory = budget.keys.first;
    double amount = 0;
    String description = '';

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ajouter une transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: budget.keys.map((String category) => DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(budget[category]!['icon'], color: budget[category]!['color']),
                        SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  )).toList(),
                  onChanged: (String? value) => selectedCategory = value!,
                  decoration: InputDecoration(labelText: 'Catégorie'),
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Montant ($currency)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => amount = double.tryParse(value) ?? 0,
                ),
                SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop()
            ),
            ElevatedButton(
              child: Text('Ajouter'),
              onPressed: () {
                Navigator.of(context).pop();
                budgetLogic.addTransaction(selectedCategory, amount, description);
              },
            ),
          ],
        )
    );
  }

  void showTransactionOptionsDialog(Transaction transaction) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Options de la transaction'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('Modifier'),
                    onTap: () {
                      Navigator.of(context).pop();
                      showEditTransactionDialog(transaction);
                    }
                ),
                ListTile(
                    leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                    title: Text('Supprimer'),
                    onTap: () {
                      Navigator.of(context).pop();
                      budgetLogic.deleteTransaction(transaction);
                    }
                ),
              ]
          ),
          actions: [
            TextButton(
                child: Text('Fermer'),
                onPressed: () => Navigator.of(context).pop()
            )
          ],
        )
    );
  }

  void showEditTransactionDialog(Transaction transaction) {
    final currency = budgetLogic.getCurrency();
    double amount = transaction.amount;
    String description = transaction.description;

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Modifier la transaction'),
          content: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Catégorie: ${transaction.category}'),
                  SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: amount.toString()),
                    decoration: InputDecoration(labelText: 'Montant ($currency)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => amount = double.tryParse(value) ?? 0,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: TextEditingController(text: description),
                    decoration: InputDecoration(labelText: 'Description'),
                    onChanged: (value) => description = value,
                  ),
                ]
            ),
          ),
          actions: [
            TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop()
            ),
            ElevatedButton(
                child: Text('Modifier'),
                onPressed: () {
                  Navigator.of(context).pop();
                  budgetLogic.editTransaction(transaction, amount, description);
                }
            ),
          ],
        )
    );
  }

  // ===================================================================
  // ====================== ONGLET OBJECTIFS ==========================
  // ===================================================================

  Widget buildGoalsTab() {
    return StreamBuilder<UserData?>(
      stream: budgetLogic.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data;
        final currency = userData?.currency ?? budgetLogic.getCurrency();
        
        if (userData == null || userData.financialGoals.isEmpty) {
          return _buildGoalsEmptyState();
        }

        final goals = userData.financialGoals;
        final activeGoals = goals.where((g) => !g.isCompleted).toList();
        final completedGoals = goals.where((g) => g.isCompleted).toList();
        
        // Calculate overall progress
        final totalTargetAmount = goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
        final totalCurrentAmount = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
        final overallProgress = totalTargetAmount > 0 ? (totalCurrentAmount / totalTargetAmount) : 0.0;
        
        // Find top performer
        FinancialGoal? topPerformer;
        if (activeGoals.isNotEmpty) {
          activeGoals.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
          topPerformer = activeGoals.first;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goals',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppDesign.textPrimary(_isDark),
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Architecting your financial future.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppDesign.textSecondary(_isDark),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Global Milestone Card
              _buildGlobalMilestoneCard(overallProgress, goals.length, completedGoals.length),
              
              const SizedBox(height: 16),
              
              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMiniStatCard(
                        'Total Goals',
                        '${goals.length}',
                        Icons.flag_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniStatCard(
                        'Completed',
                        '${completedGoals.length}',
                        Icons.check_circle_outline,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Create New Goal Button
              CreateGoalButton(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FinancialGoalsScreen(openAddDialog: true),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Top Performance
              if (topPerformer != null)
                _buildTopPerformanceCard(topPerformer),
              
              const SizedBox(height: 24),
              
              // Active Journeys Section
              SectionHeader(
                title: 'Active Journeys',
                actionLabel: 'View All',
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FinancialGoalsScreen(),
                    ),
                  );
                },
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${activeGoals.length} goals currently in progress',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Goal Cards
              ...activeGoals.take(5).map((goal) => _buildModernGoalCard(goal, currency)),
              
              // Completed Goals
              if (completedGoals.isNotEmpty) ...[
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Completed',
                  trailing: Icon(
                    Icons.celebration,
                    color: AppDesign.success,
                    size: 20,
                  ),
                ),
                ...completedGoals.take(2).map((goal) => _buildModernGoalCard(goal, currency)),
              ],
              
              const SizedBox(height: 16),
              
              // Plan your next goal
              _buildPlanNextGoalCard(),
              
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildGlobalMilestoneCard(double progress, int totalGoals, int completedGoals) {
    final percentage = (progress * 100).toInt();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppDesign.primary(_isDark),
            AppDesign.accent(_isDark),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        boxShadow: AppDesign.buttonShadow(_isDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GLOBAL MILESTONE',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.8),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$percentage%',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' To Total Goal',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.8),
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) => AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    height: 8,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMiniStatCard(String label, String value, IconData icon) {
    return SmartCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppDesign.textPrimary(_isDark),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppDesign.primary(_isDark).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppDesign.primary(_isDark), size: 20),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTopPerformanceCard(FinancialGoal goal) {
    return SmartCard(
      elevated: true,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: goal.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(goal.icon, color: goal.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Performance',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppDesign.textPrimary(_isDark),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '+${goal.progressPercentage.toStringAsFixed(0)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppDesign.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernGoalCard(FinancialGoal goal, String currency) {
    final isCompleted = goal.isCompleted;
    
    // Determine category label
    String categoryLabel = 'GENERAL';
    if (goal.name.toLowerCase().contains('vacation') || goal.name.toLowerCase().contains('trip')) {
      categoryLabel = 'LEISURE';
    } else if (goal.name.toLowerCase().contains('emergency') || goal.name.toLowerCase().contains('security')) {
      categoryLabel = 'SECURITY';
    } else if (goal.name.toLowerCase().contains('car') || goal.name.toLowerCase().contains('vehicle')) {
      categoryLabel = 'VEHICLE';
    } else if (goal.name.toLowerCase().contains('house') || goal.name.toLowerCase().contains('home')) {
      categoryLabel = 'HOUSING';
    }
    
    return GoalCard(
      name: goal.name,
      description: goal.description.isNotEmpty ? goal.description : null,
      category: categoryLabel,
      currentAmount: goal.currentAmount,
      targetAmount: goal.targetAmount,
      currency: currency,
      icon: goal.icon,
      color: isCompleted ? AppDesign.success : goal.color,
      targetDate: goal.targetDate,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const FinancialGoalsScreen(),
          ),
        );
      },
    );
  }
  
  Widget _buildPlanNextGoalCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppDesign.surface(_isDark),
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        border: Border.all(
          color: _isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08),
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        // Dashed border effect simulated with dotted pattern
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const FinancialGoalsScreen(openAddDialog: true),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppDesign.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppDesign.surfaceElevated(_isDark),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    Icons.add,
                    color: AppDesign.textSecondary(_isDark),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Plan your next goal',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goals',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppDesign.textPrimary(_isDark),
                  ),
                ),
                Text(
                  'Architecting your financial future.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppDesign.textSecondary(_isDark),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 48),
          
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: AppDesign.textSecondary(_isDark),
          ),
          const SizedBox(height: 24),
          Text(
            'No goals yet',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppDesign.textPrimary(_isDark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set your first financial goal and start\nbuilding towards your dreams.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppDesign.textSecondary(_isDark),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          CreateGoalButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FinancialGoalsScreen(openAddDialog: true),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void showAddCategoryDialog() {
    final salary = budgetLogic.getSalary();
    final currency = budgetLogic.getCurrency();

    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez d\'abord définir vos revenus.'))
      );
      return;
    }

    String name = '';
    double percent = 0.0;
    bool isUsingPercent = true;
    int selectedIconIndex = 0;
    int selectedColorIndex = 0;

    final double totalUsedPercent = budgetLogic.getTotalBudgetPercentage() * 100;
    final double remainingPercent = 100 - totalUsedPercent;
    final double remainingAmount = salary * (remainingPercent / 100);

    final TextEditingController nameController = TextEditingController();
    final TextEditingController percentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double amount = isUsingPercent ? (percent * salary) / 100 : percent;

            return AlertDialog(
              title: Text('Nouvelle Catégorie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Budget restant:', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            '${remainingPercent.toStringAsFixed(1)}% (${remainingAmount.toStringAsFixed(0)} $currency)',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: remainingPercent < 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nom de la catégorie'),
                      onChanged: (value) => name = value,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: percentController,
                      decoration: InputDecoration(
                        labelText: isUsingPercent ? 'Pourcentage (%)' : 'Montant ($currency)',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                          tooltip: 'Changer en ${isUsingPercent ? "Montant" : "Pourcentage"}',
                          onPressed: () {
                            setState(() {
                              isUsingPercent = !isUsingPercent;
                              if (isUsingPercent) {
                                percent = salary > 0 ? (percent / salary * 100) : 0;
                              } else {
                                percent = (percent * salary) / 100;
                              }
                              percentController.text = percent.toStringAsFixed(2);
                            });
                          },
                        ),
                        helperText: isUsingPercent
                            ? 'Équivalent: ${amount.toStringAsFixed(0)} $currency'
                            : 'Équivalent: ${salary > 0 ? (amount / salary * 100).toStringAsFixed(1) : 0}%',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        percent = double.tryParse(value) ?? 0;
                        setState((){});
                      },
                    ),
                    SizedBox(height: 24),

                    // Sélecteur d'icônes
                    Text('Icône', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableIcons.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedIconIndex == index ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                  width: 2),
                            ),
                            child: Icon(
                              availableIcons[index],
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24),

                    // Sélecteur de couleurs
                    Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableColors.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedColorIndex = index),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: availableColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  width: selectedColorIndex == index ? 3 : 0),
                            ),
                            child: selectedColorIndex == index ? Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    child: Text('Annuler'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                ElevatedButton(
                  child: Text('Ajouter'),
                  onPressed: () {
                    final calculatedPercent = isUsingPercent ? percent : (percent / salary * 100);
                    if (name.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le nom ne peut pas être vide.')));
                      return;
                    }
                    if (calculatedPercent > remainingPercent + 0.01) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le montant dépasse le budget restant disponible !')));
                      return;
                    }
                    Navigator.of(context).pop();
                    budgetLogic.addCategory(name, calculatedPercent, availableIcons[selectedIconIndex], availableColors[selectedColorIndex]);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showEditCategoryDialog(String categoryName) {
    final budget = budgetLogic.getBudget();
    final salary = budgetLogic.getSalary();
    final currency = budgetLogic.getCurrency();

    Map<String, dynamic> currentCategory = budget[categoryName]!;
    String name = categoryName;
    double originalPercent = (currentCategory['percent'] as double) * 100;
    double percent = originalPercent;
    bool isUsingPercent = true;

    IconData currentIcon = currentCategory['icon'] as IconData;
    Color currentColor = currentCategory['color'] as Color;

    int selectedIconIndex = availableIcons.indexWhere((icon) => icon.codePoint == currentIcon.codePoint);
    if (selectedIconIndex == -1) selectedIconIndex = 0;

    int selectedColorIndex = availableColors.indexWhere((color) => color.value == currentColor.value);
    if (selectedColorIndex == -1) selectedColorIndex = 0;

    double totalUsedPercent = (budgetLogic.getTotalBudgetPercentage() * 100) - originalPercent;
    double remainingPercent = 100 - totalUsedPercent;

    final TextEditingController percentController = TextEditingController(text: percent.toString());
    final TextEditingController nameController = TextEditingController(text: name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            double amount = isUsingPercent ? (percent * salary) / 100 : percent;

            return AlertDialog(
              title: Text('Modifier la Catégorie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Budget total dispo.:', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            '${remainingPercent.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Nom de la catégorie'),
                      onChanged: (value) => name = value,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: percentController,
                      decoration: InputDecoration(
                        labelText: isUsingPercent ? 'Pourcentage (%)' : 'Montant ($currency)',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                          tooltip: 'Changer en ${isUsingPercent ? "Montant" : "Pourcentage"}',
                          onPressed: () {
                            setState(() {
                              isUsingPercent = !isUsingPercent;
                              if (isUsingPercent) {
                                percent = salary > 0 ? (percent / salary * 100) : 0;
                              } else {
                                percent = (percent * salary) / 100;
                              }
                              percentController.text = percent.toStringAsFixed(2);
                            });
                          },
                        ),
                        helperText: isUsingPercent
                            ? 'Équivalent: ${amount.toStringAsFixed(0)} $currency'
                            : 'Équivalent: ${salary > 0 ? (amount / salary * 100).toStringAsFixed(1) : 0}%',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        percent = double.tryParse(value) ?? 0;
                        setState((){});
                      },
                    ),
                    SizedBox(height: 24),

                    // Sélecteur d'icônes
                    Text('Icône', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableIcons.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedIconIndex = index),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: selectedIconIndex == index ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                  width: 2),
                            ),
                            child: Icon(
                              availableIcons[index],
                              color: selectedIconIndex == index ? Theme.of(context).colorScheme.onPrimaryContainer : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 24),

                    // Sélecteur de couleurs
                    Text('Couleur', style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(availableColors.length, (index) {
                        return InkWell(
                          onTap: () => setState(() => selectedColorIndex = index),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: availableColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.onBackground,
                                  width: selectedColorIndex == index ? 3 : 0),
                            ),
                            child: selectedColorIndex == index ? Icon(Icons.check, color: Colors.white) : null,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    child: Text('Annuler'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                ElevatedButton(
                  child: Text('Modifier'),
                  onPressed: () {
                    final calculatedPercent = isUsingPercent ? percent : (percent / salary * 100);
                    if (calculatedPercent > remainingPercent + 0.01) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Le montant dépasse le budget restant disponible !')));
                      return;
                    }
                    Navigator.of(context).pop();
                    budgetLogic.editCategory(categoryName, name, calculatedPercent, availableIcons[selectedIconIndex], availableColors[selectedColorIndex]);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}