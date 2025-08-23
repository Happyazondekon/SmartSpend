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

  // ===================================================================
  // ====================== ONGLET BUDGET =============================
  // ===================================================================

  Widget buildBudgetTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          _buildSalaryCard(),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Répartition du Budget", style: Theme.of(context).textTheme.titleLarge),
          ),
          SizedBox(height: 8),
          _buildBudgetList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final userName = AuthService().currentUser?.displayName ?? 'Utilisateur';

    return Container(
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message de bienvenue avec animation subtile
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ) ?? const TextStyle(),
            child: Text('Bienvenue,'),
          ),

          // Nom de l'utilisateur avec style distinctif
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ],
            ).createShader(bounds),
            child: Text(
              userName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Colors.white, // Nécessaire pour le ShaderMask
                height: 1.1,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Titre principal avec gradient subtil
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.onBackground,
                Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              ],
            ).createShader(bounds),
            child: Text(
              'Gérez vos finances',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                color: Colors.white, // Requis pour ShaderMask
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
          ),

          // Ligne décorative subtile
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 3,
            width: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: budgetLogic.getSalaryController(),
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.titleLarge,
              decoration: InputDecoration(
                labelText: 'Votre salaire mensuel net',
                prefixIcon: Icon(Icons.account_balance_wallet_outlined, color: Theme.of(context).colorScheme.primary),
                suffix: DropdownButton<String>(
                  value: budgetLogic.getCurrency(),
                  underline: Container(),
                  items: ['XOF', 'USD', 'EUR', 'GBP', 'CAD'].map((String value) =>
                      DropdownMenuItem<String>(value: value, child: Text(value))
                  ).toList(),
                  onChanged: (newValue) {
                    budgetLogic.setCurrency(newValue!);
                    budgetLogic.saveData();
                    budgetLogic.updateState();
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: budgetLogic.calculateBudget,
                    child: Text('Calculer & Mettre à jour')
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList() {
    final salary = budgetLogic.getSalary();
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();

    if (salary <= 0) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
              "Entrez votre salaire pour voir votre budget.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)
              )
          ),
        ),
      );
    }

    return Column(
      children: budget.entries.map((entry) {
        double spent = entry.value['spent'] as double;
        double allocated = entry.value['amount'] as double;
        double progress = allocated > 0 ? (spent / allocated) : 0.0;
        double remaining = allocated - spent;
        String recommendation = budgetLogic.getSpendingRecommendation(entry.key);

        Color progressColor = entry.value['color'];
        if(progress > 1) progressColor = Theme.of(context).colorScheme.error;
        else if (progress > 0.9) progressColor = Colors.orangeAccent;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: (entry.value['color'] as Color).withOpacity(0.15),
                      child: Icon(entry.value['icon'], color: entry.value['color']),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key, style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            'Alloué : ${allocated.toStringAsFixed(0)} $currency',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') showEditCategoryDialog(entry.key);
                        if (value == 'delete') budgetLogic.deleteCategory(entry.key);
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Modifier')
                            )
                        ),
                        PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                                leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                                title: Text('Supprimer', style: TextStyle(color: Theme.of(context).colorScheme.error))
                            )
                        ),
                      ],
                      icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dépensé : ${spent.toStringAsFixed(0)} $currency', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                        'Restant : ${remaining.toStringAsFixed(0)} $currency',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: remaining < 0 ? Theme.of(context).colorScheme.error : Colors.green
                        )
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                if (recommendation.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: progressColor
                        )
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ===================================================================
  // ====================== ONGLET STATISTIQUES ======================
  // ===================================================================

  Widget buildStatsTab() {
    final filteredTransactions = budgetLogic.getFilteredTransactions();
    final budget = budgetLogic.getBudget();
    double totalSpent = filteredTransactions.fold(0, (sum, item) => sum + item.amount);

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildMonthSelectorHeader(),
            SizedBox(height: 24),
            filteredTransactions.isEmpty
                ? Expanded(
              child: Center(
                  child: Text(
                    "Aucune dépense pour ce mois.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )
              ),
            )
                : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 60,
                              startDegreeOffset: -90,
                              pieTouchData: PieTouchData(touchCallback: (event, pieTouchResponse) {}),
                              sections: budget.entries
                                  .where((entry) => entry.value['spent'] > 0)
                                  .map((entry) {
                                final double value = entry.value['spent'];
                                return PieChartSectionData(
                                  color: entry.value['color'],
                                  value: value,
                                  title: '${(value / totalSpent * 100).toStringAsFixed(0)}%',
                                  radius: 50,
                                  titleStyle: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white
                                  ),
                                );
                              }).toList(),
                            )
                        ),
                      ),
                      SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: budget.entries
                            .where((entry) => entry.value['spent'] > 0)
                            .map((entry) => _buildLegendItem(entry.value['color'], entry.key))
                            .toList(),
                      ),
                    ],
                  ),
                )
            ),
          ],
        )
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3)
            )
        ),
        SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  // ===================================================================
  // =================== ONGLET TRANSACTIONS =========================
  // ===================================================================

  Widget buildTransactionsTab() {
    final filteredTransactions = budgetLogic.getFilteredTransactions();
    final budget = budgetLogic.getBudget();
    final currency = budgetLogic.getCurrency();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildMonthSelectorHeader(showExport: false),
        ),
        Expanded(
          child: filteredTransactions.isEmpty ?
          Center(child: Text('Aucune transaction pour ce mois')) :
          ListView.builder(
            padding: EdgeInsets.only(bottom: 80),
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              final categoryData = budget[transaction.category];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (categoryData?['color'] as Color?)?.withOpacity(0.15) ?? Colors.grey.withOpacity(0.1),
                    child: Icon(
                        categoryData?['icon'] ?? Icons.error_outline,
                        color: categoryData?['color'] ?? Colors.grey
                    ),
                  ),
                  title: Text(transaction.description, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(DateFormat('d MMMM yyyy', 'fr_FR').format(transaction.date)),
                  trailing: Text(
                    '${transaction.amount.toStringAsFixed(0)} $currency',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: categoryData?['color'] ?? Theme.of(context).colorScheme.onSurface
                    ),
                  ),
                  onTap: () => showTransactionOptionsDialog(transaction),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===================================================================
  // ====================== COMPOSANTS COMMUNS ========================
  // ===================================================================

  Widget buildMonthSelectorHeader({bool showExport = true}) {
    final selectedMonth = budgetLogic.getSelectedMonth();
    final filteredTransactions = budgetLogic.getFilteredTransactions();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        final isPremium = await _premiumService.isPremiumUser();

                        if (canUse) {
                          // Permettre l'utilisation
                          if (!isPremium) {
                            await _premiumService.incrementChatbotUses();
                            final remaining = await _premiumService.getRemainingChatbotUses();

                            if (remaining == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Plus d\'essais gratuits pour l\'assistant.'),
                                  backgroundColor: Colors.orange,
                                  action: SnackBarAction(
                                    label: 'Premium',
                                    textColor: Colors.white,
                                    onPressed: () => _showUpgradeDialog('assistant financier'),
                                  ),
                                ),
                              );
                            }
                          }

                          // Ouvrir l'assistant
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
        if (userData == null || userData.financialGoals.isEmpty) {
          return _buildGoalsEmptyState();
        }

        final goals = userData.financialGoals;
        final activeGoals = goals.where((g) => !g.isCompleted).toList();
        final completedGoals = goals.where((g) => g.isCompleted).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistiques rapides
              _buildGoalsOverviewCard(goals, userData.currency),

              const SizedBox(height: 24),

              // Objectifs actifs
              if (activeGoals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Objectifs en cours (${activeGoals.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FinancialGoalsScreen(),
                          ),
                        );
                      },
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...activeGoals.take(3).map((goal) => _buildGoalSummaryCard(goal, userData.currency)),
              ],

              // Objectifs terminés
              if (completedGoals.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Objectifs terminés (${completedGoals.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                ...completedGoals.take(2).map((goal) => _buildGoalSummaryCard(goal, userData.currency)),
              ],

              const SizedBox(height: 80), // Espace pour le FAB
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.track_changes_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun objectif défini',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Définissez vos objectifs financiers pour donner un sens à votre épargne !',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FinancialGoalsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un objectif'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsOverviewCard(List<FinancialGoal> goals, String currency) {
    if (goals.isEmpty) return const SizedBox();

    final totalTargetAmount = goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final totalCurrentAmount = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    final completedGoalsCount = goals.where((g) => g.isCompleted).length;
    final overallProgress = totalTargetAmount > 0 ? (totalCurrentAmount / totalTargetAmount) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vue d\'ensemble',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Objectifs',
                    '${goals.length}',
                    Icons.flag_outlined,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Terminés',
                    '$completedGoalsCount',
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Progression',
                    '${(overallProgress * 100).toStringAsFixed(0)}%',
                    Icons.percent,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Épargne totale: ${totalCurrentAmount.toStringAsFixed(0)} / ${totalTargetAmount.toStringAsFixed(0)} $currency',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overallProgress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  overallProgress >= 1.0 ? Colors.green : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSummaryCard(FinancialGoal goal, String currency) {
    final progress = goal.progressPercentage / 100;
    final isCompleted = goal.isCompleted;
    final isOverdue = goal.isOverdue;
    final isNearDeadline = goal.isNearDeadline;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: goal.color.withOpacity(0.15),
                  child: Icon(goal.icon, color: goal.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                          if (isOverdue && !isCompleted)
                            Icon(Icons.warning, color: Colors.red, size: 16),
                          if (isNearDeadline && !isCompleted)
                            Icon(Icons.schedule, color: Colors.orange, size: 16),
                        ],
                      ),
                      Text(
                        '${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} $currency',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : goal.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : goal.color,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Échéance: ${DateFormat('dd/MM/yyyy', 'fr_FR').format(goal.targetDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  isCompleted
                      ? 'Terminé ✓'
                      : isOverdue
                      ? 'En retard'
                      : '${goal.daysRemaining} jours',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isCompleted
                        ? Colors.green
                        : isOverdue
                        ? Colors.red
                        : isNearDeadline
                        ? Colors.orange
                        : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Suggestion d'épargne pour les objectifs actifs
            if (!isCompleted && goal.remainingAmount > 0 && !isOverdue) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Épargner ${goal.monthlySavingsNeeded.toStringAsFixed(0)} $currency/mois pour atteindre votre objectif',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: goal.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void showAddCategoryDialog() {
    final salary = budgetLogic.getSalary();
    final currency = budgetLogic.getCurrency();

    if (salary <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veuillez d\'abord définir votre salaire.'))
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