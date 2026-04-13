import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smartspend/services/auth_service.dart';
import 'package:smartspend/services/premium_service.dart';
import 'package:smartspend/services/localization_service.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'theme.dart';
import 'generated/gen_l10n/app_localizations.dart';

class _ScaleOnTap extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double beginScale;
  final double endScale;
  final VoidCallback? onTap;

  const _ScaleOnTap({
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.beginScale = 0.95,
    this.endScale = 1.0,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<_ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<_ScaleOnTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );

    _animation = Tween<double>(begin: widget.endScale, end: widget.beginScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class AIService {

  static String _getSystemPrompt(bool isEnglish) {
    if (isEnglish) {
      return """You are SmartBot, SmartSpend's premium AI assistant, a personal finance expert and caring financial advisor.

MAIN CAPABILITIES:
🏦 FINANCIAL EXPERTISE: Budgeting, savings, investing, debt management, financial planning
📱 APP GUIDE: SmartSpend features (transactions, budgets, statistics, notifications)
💡 PERSONALIZED ADVICE: Savings strategies, budget optimization, tailored investment advice
📊 FINANCIAL ANALYSIS: Spending trends interpretation, improvement recommendations

RESPONSE STYLE:
- Warm, professional and motivating
- Structured responses with appropriate emojis
- Practical and actionable advice
- Natural and accessible English
- Maximum 200 words per response

AREAS OF EXPERTISE:
✓ Creating and tracking personal budgets
✓ Savings strategies and emergency funds
✓ Debt reduction and management
✓ Beginner investments
✓ Long-term financial planning
✓ Current expense optimization
✓ General financial education""";
    } else {
      return """Tu es SmartBot, l'assistant IA premium de SmartSpend, expert en finances personnelles et conseiller financier bienveillant. 

CAPACITÉS PRINCIPALES:
🏦 EXPERTISE FINANCIÈRE: Budgétisation, épargne, investissement, gestion de dettes, planification financière
📱 GUIDE APPLICATION: Fonctionnalités SmartSpend (transactions, budgets, statistiques, notifications)
💡 CONSEILS PERSONNALISÉS: Stratégies d'épargne, optimisation budgets, conseils d'investissement adaptés
📊 ANALYSE FINANCIÈRE: Interprétation des tendances de dépenses, recommandations d'amélioration

STYLE DE RÉPONSE:
- Chaleureux, professionnel et motivant
- Réponses structurées avec emojis appropriés
- Conseils pratiques et actionnables
- Français naturel et accessible
- Maximum 200 mots par réponse

DOMAINES D'EXPERTISE:
✓ Création et suivi de budgets personnels
✓ Stratégies d'épargne et fonds d'urgence  
✓ Réduction et gestion des dettes
✓ Investissements pour débutants
✓ Planification financière à long terme
✓ Optimisation des dépenses courantes
✓ Éducation financière générale""";
    }
  }

  static Future<String> getGroqResponse(String prompt, {bool isEnglish = false}) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': _getSystemPrompt(isEnglish)
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      print('Groq Status: ${response.statusCode}');
      print('Groq Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        print('Groq Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur Groq Exception: $e');
    }
    return '';
  }

  static Future<String> getAIResponse(String prompt, {bool isEnglish = false}) async {
    // D'abord essayer la FAQ locale
    String localAnswer = FAQChatBot.getLocalAnswer(prompt, isEnglish: isEnglish);
    if (localAnswer.isNotEmpty) {
      return localAnswer;
    }
    
    // Sinon appeler l'API
    String response = await getGroqResponse(prompt, isEnglish: isEnglish);
    if (response.isNotEmpty) return response;

    return isEnglish 
        ? "⚠️ Connection temporarily unavailable. Try a question from the suggestions below."
        : "⚠️ Connexion temporairement indisponible. Essayez une question des suggestions ci-dessous.";
  }
}

class FAQChatBot {
  static final Map<String, String> enhancedFAQFr = {
    "📱 Comment ajouter une transaction?": "📝 Ajouter une transaction:\n\n1. Ouvrez l'onglet 'Transactions'\n2. Appuyez sur le bouton '+' \n3. Saisissez le montant, choisissez la catégorie et ajoutez une description\n4. Validez pour enregistrer\n\n💡 Astuce: Ajoutez vos transactions immédiatement pour un suivi précis!",
    "🎯 Comment créer un budget?": "🎯 Créer un budget efficace:\n\n1. Accédez à l'onglet 'Budget'\n2. Cliquez sur '+' pour ajouter un nouveau budget\n3. Définissez le montant maximal par catégorie\n4. Activez les alertes pour rester dans les limites\n\n💰 Conseil: Suivez la règle 50/30/20 (besoins/envies/épargne)",
    "📊 Comment consulter mes statistiques?": "📊 Analyser vos finances:\n\nL'onglet 'Statistiques' vous offre:\n• Graphiques de dépenses par catégorie\n• Évolution mensuelle de vos finances\n• Comparaisons périodiques\n• Tendances de consommation\n\n🔍 Utilisez ces données pour identifier vos habitudes et optimiser votre budget!",
    "💰 Comment économiser efficacement?": "💰 Stratégies d'épargne éprouvées:\n\n🎯 Méthode des 52 semaines: Épargnez 1€ la 1ère semaine, 2€ la 2ème...\n🏦 Épargne automatique: 10-20% de chaque revenu\n📱 Utilisez SmartSpend pour tracker vos progrès\n⚡ Réduisez les abonnements non-essentiels\n\nObjectif: Constituez d'abord un fonds d'urgence (3-6 mois de charges)!",
    "✂️ Comment réduire mes dépenses?": "✂️ Optimisation des dépenses:\n\n🔍 Analysez vos statistiques SmartSpend:\n• Identifiez les catégories les plus coûteuses\n• Repérez les dépenses récurrentes\n• Trouvez les 'fuites' budgétaires\n\n💡 Actions concrètes:\n• Comparez les prix avant d'acheter\n• Cuisinez plus à la maison\n• Renégociez vos contrats (assurance, téléphone)\n• Privilégiez l'occasion quand possible",
    "📊 Conseils investissement débutant?": "🚀 Débuter en investissement:\n\n⚠️ Prérequis essentiels:\n✓ Fonds d'urgence constitué (3-6 mois)\n✓ Dettes remboursées (sauf prêt immobilier)\n✓ Budget maîtrisé avec SmartSpend\n\n📈 Premiers pas:\n• Commencez petit (50-100€/mois)\n• Diversifiez vos placements\n• Privilégiez le long terme\n• Formez-vous avant d'investir\n\n🏦 Options: Livret A, PEL, assurance-vie, PEA",
    "💳Comment gérer mes dettes?": "💳 Stratégie de remboursement:\n\n🎯 Méthode 'Boule de neige':\n1. Listez toutes vos dettes\n2. Payez les minimums partout\n3. Attaquez la plus petite dette en premier\n4. Une fois remboursée, passez à la suivante\n\n📊 Utilisez SmartSpend pour tracker vos remboursements et célébrer vos progrès!\n\n⚡ Négociez avec vos créanciers si nécessaire.",
    "🎯 Comment créer un objectif?": "🎯 Créer un objectif financier:\n\n1. Accédez à l’onglet 'Objectifs'\n2. Appuyez sur '+' pour ajouter un nouvel objectif\n3. Indiquez le nom, la description (facultative), le montant cible et la date limite\n4. Choisissez une icône et une couleur pour personnaliser votre objectif\n5. Validez en appuyant sur 'Créer'\n",
  };

  static final Map<String, String> enhancedFAQEn = {
    "📱 How to add a transaction?": "📝 **Add a transaction:**\n\n1. Open the 'Transactions' tab\n2. Tap the '+' button\n3. Enter the amount, choose the category and add a description\n4. Confirm to save\n\n💡 **Tip:** Add your transactions immediately for accurate tracking!",
    "🎯 How to create a budget?": "🎯 **Create an effective budget:**\n\n1. Go to the 'Budget' tab\n2. Click '+' to add a new budget\n3. Set the maximum amount per category\n4. Enable alerts to stay within limits\n\n💰 **Tip:** Follow the 50/30/20 rule (needs/wants/savings)",
    "📊 How to view my statistics?": "📊 **Analyze your finances:**\n\nThe 'Statistics' tab offers:\n• Spending charts by category\n• Monthly evolution of your finances\n• Periodic comparisons\n• Consumption trends\n\n🔍 **Use this data** to identify your habits and optimize your budget!",
    "💰 How to save effectively?": "💰 **Proven saving strategies:**\n\n🎯 **52-week method:** Save \$1 week 1, \$2 week 2...\n🏦 **Automatic savings:** 10-20% of each income\n📱 Use **SmartSpend** to track your progress\n⚡ Reduce non-essential subscriptions\n\n**Goal:** First build an emergency fund (3-6 months of expenses)!",
    "✂️ How to reduce spending?": "✂️ **Spending optimization:**\n\n🔍 Analyze your **SmartSpend** statistics:\n• Identify the most expensive categories\n• Spot recurring expenses\n• Find budget 'leaks'\n\n💡 **Concrete actions:**\n• Compare prices before buying\n• Cook more at home\n• Renegotiate contracts (insurance, phone)\n• Choose second-hand when possible",
    "📊 Beginner investing tips?": "🚀 **Getting started with investing:**\n\n⚠️ **Essential prerequisites:**\n✓ Emergency fund saved (3-6 months)\n✓ Debts paid off (except mortgage)\n✓ Budget managed with **SmartSpend**\n\n📈 **First steps:**\n• Start small (\$50-100/month)\n• Diversify your investments\n• Focus on long-term\n• Learn before investing\n\n🏦 **Options:** Savings accounts, index funds, retirement accounts",
    "💳 How to manage my debt?": "💳 **Repayment strategy:**\n\n🎯 **'Snowball' method:**\n1. List all your debts\n2. Pay minimums everywhere\n3. Attack the smallest debt first\n4. Once paid, move to the next\n\n📊 Use **SmartSpend** to track your repayments and celebrate your progress!\n\n⚡ **Negotiate** with your creditors if necessary.",
    "🎯 How to create a goal?": "🎯 **Create a financial goal:**\n\n1. Go to the 'Goals' tab\n2. Tap '+' to add a new goal\n3. Enter the name, description (optional), target amount and deadline\n4. Choose an icon and color to personalize your goal\n5. Confirm by tapping 'Create'\n",
  };

  static Map<String, String> getEnhancedFAQ(bool isEnglish) {
    return isEnglish ? enhancedFAQEn : enhancedFAQFr;
  }

  static final List<String> financialTopicsFr = [
    "💰 Comment économiser efficacement?",
    "📊 Conseils investissement débutant?",
    "💳 Comment gérer mes dettes?",
    "✂️ Comment réduire mes dépenses?",
    "🎯 Créer un budget optimal",
    "🏦 Fonds d'urgence: combien épargner?",
  ];

  static final List<String> financialTopicsEn = [
    "💰 How to save effectively?",
    "📊 Beginner investing tips?",
    "💳 How to manage my debt?",
    "✂️ How to reduce spending?",
    "🎯 Create an optimal budget",
    "🏦 Emergency fund: how much to save?",
  ];

  static final List<String> appTopicsFr = [
    "📱 Comment ajouter une transaction?",
    "🎯 Comment créer un budget?",
    "📊 Comment consulter mes statistiques?",
    "🔔 Configurer les notifications",
    "⚙️ Problème de synchronisation",
    "✏️ Modifier/supprimer une transaction",
    "🎯 Comment créer un objectif?"
  ];

  static final List<String> appTopicsEn = [
    "📱 How to add a transaction?",
    "🎯 How to create a budget?",
    "📊 How to view my statistics?",
    "🔔 Configure notifications",
    "⚙️ Sync issues",
    "✏️ Edit/delete a transaction",
    "🎯 How to create a goal?"
  ];

  static List<String> getSuggestions(String query, {bool isEnglish = false}) {
    final financialTopics = isEnglish ? financialTopicsEn : financialTopicsFr;
    final appTopics = isEnglish ? appTopicsEn : appTopicsFr;
    final enhancedFAQ = getEnhancedFAQ(isEnglish);

    if (query.isEmpty) {
      List<String> suggestions = [];
      suggestions.addAll(financialTopics.take(3));
      suggestions.addAll(appTopics.take(3));
      return suggestions;
    }

    final allQuestions = [...enhancedFAQ.keys, ...financialTopics, ...appTopics];
    return allQuestions.where((question) {
      return question.toLowerCase().contains(query.toLowerCase());
    }).take(6).toList();
  }

  static String getLocalAnswer(String question, {bool isEnglish = false}) {
    final enhancedFAQ = getEnhancedFAQ(isEnglish);

    if (enhancedFAQ.containsKey(question)) {
      return enhancedFAQ[question]!;
    }

    String queryLower = question.toLowerCase();
    for (String key in enhancedFAQ.keys) {
      if (key.toLowerCase().contains(queryLower) ||
          queryLower.contains(key.toLowerCase().split(' ')[0])) {
        return enhancedFAQ[key]!;
      }
    }

    return "";
  }

  static Future<String> getAnswer(String question, {bool isEnglish = false}) async {
    String localAnswer = getLocalAnswer(question, isEnglish: isEnglish);
    if (localAnswer.isNotEmpty) {
      return localAnswer;
    }

    return await AIService.getAIResponse(question, isEnglish: isEnglish);
  }
}

class ElegantFAQChatBot extends StatefulWidget {
  const ElegantFAQChatBot({super.key});

  @override
  State<ElegantFAQChatBot> createState() => _ElegantFAQChatBotState();
}

class _ElegantFAQChatBotState extends State<ElegantFAQChatBot>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final PremiumService _premiumService = PremiumService();

  List<Map<String, dynamic>> messages = [];
  List<String> suggestions = [];
  bool isTyping = false;
  int selectedSuggestionTab = 0;
  bool _hasCountedUsage = false; // Pour tracker si on a déjà compté l'utilisation
  bool _welcomeAdded = false;

  late AnimationController _typingController;
  late AnimationController _botAvatarController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _botAvatarController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    suggestions = FAQChatBot.getSuggestions("");

    _botAvatarController.repeat();
    _shimmerController.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_welcomeAdded) {
        _welcomeAdded = true;
        _addWelcomeMessages();
      }
    });
  }

  void _addWelcomeMessages() {
    final l10n = AppLocalizations.of(context)!;
    // Récupérer les informations utilisateur
    final user = AuthService().currentUser;
    final userName = user?.displayName ?? user?.email?.split('@').first ?? l10n.chatbotDefaultUser;

    messages.add({
      'sender': 'bot',
      'text': l10n.chatbotGreeting(userName),
      'timestamp': DateTime.now(),
      'type': 'welcome',
    });
    _listKey.currentState?.insertItem(messages.length - 1);

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        messages.add({
          'sender': 'bot',
          'text': l10n.chatbotIntro,
          'timestamp': DateTime.now(),
          'type': 'intro',
        });
        _listKey.currentState?.insertItem(messages.length - 1);
        _scrollToBottom();
      }
    });

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        messages.add({
          'sender': 'bot',
          'text': l10n.chatbotCapabilities,
          'timestamp': DateTime.now(),
          'type': 'capabilities',
        });
        _listKey.currentState?.insertItem(messages.length - 1);
        _scrollToBottom();
      }
    });

    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) {
        messages.add({
          'sender': 'bot',
          'text': l10n.chatbotPrompt,
          'timestamp': DateTime.now(),
          'type': 'prompt',
        });
        _listKey.currentState?.insertItem(messages.length - 1);
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    _botAvatarController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    // Incrémenter le compteur uniquement lors du premier message envoyé
    if (!_hasCountedUsage) {
      try {
        final isPremium = await _premiumService.isPremiumUser();
        if (!isPremium) {
          await _premiumService.incrementChatbotUses();
          _hasCountedUsage = true;
          
          final remaining = await _premiumService.getRemainingChatbotUses();
          if (remaining == 0 && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.chatbotLastFreeUse),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          _hasCountedUsage = true; // Pas besoin de compter pour les utilisateurs premium
        }
      } catch (e) {
        debugPrint('Erreur lors de l\'incrémentation du compteur: $e');
      }
    }

    final question = _controller.text.trim();
    _controller.clear();

    messages.add({
      'sender': 'user',
      'text': question,
      'timestamp': DateTime.now(),
      'type': 'question',
    });

    _listKey.currentState?.insertItem(messages.length - 1);

    setState(() {
      isTyping = true;
      suggestions = FAQChatBot.getSuggestions(question, isEnglish: isEnglish);
    });

    _scrollToBottom();
    _typingController.repeat();

    try {
      final answer = await FAQChatBot.getAnswer(question, isEnglish: isEnglish);
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          isTyping = false;
        });

        messages.add({
          'sender': 'bot',
          'text': answer,
          'timestamp': DateTime.now(),
          'type': 'answer',
        });

        _listKey.currentState?.insertItem(messages.length - 1);
        _typingController.stop();
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isTyping = false;
        });

        messages.add({
          'sender': 'bot',
          'text': l10n.chatbotError,
          'timestamp': DateTime.now(),
          'type': 'error',
        });

        _listKey.currentState?.insertItem(messages.length - 1);
        _typingController.stop();
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true, // 🔑 permet d'éviter que le clavier cache l'input
      backgroundColor: Colors.transparent,
      body: Container(
        height: MediaQuery.of(context).size.height * 0.95,
        decoration: BoxDecoration(
          color: colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            _buildElegantHeader(colorScheme, textTheme),
            Expanded(
              child: AnimatedList(
                key: _listKey,
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                initialItemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index, animation) {
                  if (isTyping && index == messages.length) {
                    return FadeTransition(
                      opacity: animation,
                      child: _buildTypingIndicator(colorScheme),
                    );
                  }

                  if (index < messages.length) {
                    final message = messages[index];
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: _buildMessageBubble(message, colorScheme, textTheme),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildSuggestionsSection(colorScheme, textTheme),
            _buildInputSection(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }


  Widget _buildElegantHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _shimmerController.value * 2, 0.0),
                        end: Alignment(1.0 + _shimmerController.value * 2, 0.0),
                        colors: [
                          Colors.white.withOpacity(0.0),
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorScheme.onPrimary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _botAvatarController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Icon(
                    Icons.psychology_outlined,
                    color: colorScheme.onPrimary,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'SmartBot',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'IA PREMIUM',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 07,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.chatbotSubtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onPrimary,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, ColorScheme colorScheme, TextTheme textTheme) {
    final isUser = message['sender'] == 'user';
    final messageType = message['type'] ?? 'default';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getMessageIcon(messageType),
                color: colorScheme.onPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                )
                    : null,
                color: isUser ? null : colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: !isUser
                    ? Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? colorScheme.primary : colorScheme.surface).withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser && messageType != 'welcome') ...[
                    Text(
                      'SmartBot',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text.rich(
                    _parseBoldText(message['text']),
                    style: textTheme.bodyMedium?.copyWith(
                      color: isUser ? colorScheme.onPrimary : colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_outline,
                color: colorScheme.onSurfaceVariant,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  TextSpan _parseBoldText(String text) {
    final regex = RegExp(r'\*\*(.+?)\*\*');
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return TextSpan(children: spans);
  }

  IconData _getMessageIcon(String type) {
    switch (type) {
      case 'welcome':
        return Icons.waving_hand;
      case 'intro':
        return Icons.psychology;
      case 'capabilities':
        return Icons.auto_awesome;
      case 'prompt':
        return Icons.rocket_launch;
      case 'answer':
        return Icons.lightbulb_outline;
      case 'error':
        return Icons.warning_outlined;
      default:
        return Icons.chat_bubble_outline;
    }
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.more_horiz,
              color: colorScheme.onPrimary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.chatbotThinking,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 40,
                  height: 20,
                  child: AnimatedBuilder(
                    animation: _typingController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(3, (index) {
                          final animationValue = (_typingController.value + index * 0.33) % 1.0;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 6,
                            height: 6 + (animationValue * 6),
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                colorScheme.outline.withOpacity(0.3),
                                colorScheme.primary,
                                animationValue,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildSuggestionTab(AppLocalizations.of(context)!.chatbotTabPopular, 0, colorScheme, textTheme),
                _buildSuggestionTab(AppLocalizations.of(context)!.chatbotTabFinance, 1, colorScheme, textTheme),
                _buildSuggestionTab(AppLocalizations.of(context)!.chatbotTabApp, 2, colorScheme, textTheme),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _getCurrentSuggestions().length,
              itemBuilder: (context, index) {
                final suggestion = _getCurrentSuggestions()[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildSuggestionChip(suggestion, colorScheme, textTheme),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTab(String title, int index, ColorScheme colorScheme, TextTheme textTheme) {
    final isSelected = selectedSuggestionTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSuggestionTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [colorScheme.primary, colorScheme.secondary],
            )
                : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion, ColorScheme colorScheme, TextTheme textTheme) {
    return _ScaleOnTap(
      onTap: () {
        _controller.text = suggestion;
        _sendMessage();
      },
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.7),
              colorScheme.secondaryContainer.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _extractEmoji(suggestion),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Expanded( // La correction principale est ici
              child: Text(
                _removeEmoji(suggestion),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCurrentSuggestions() {
    final isEnglish = Provider.of<LocalizationService>(context, listen: false).isEnglish();
    switch (selectedSuggestionTab) {
      case 1:
        return isEnglish ? FAQChatBot.financialTopicsEn : FAQChatBot.financialTopicsFr;
      case 2:
        return isEnglish ? FAQChatBot.appTopicsEn : FAQChatBot.appTopicsFr;
      default:
        return FAQChatBot.getSuggestions("", isEnglish: isEnglish);
    }
  }

  String _extractEmoji(String text) {
    final RegExp emojiRegex = RegExp(r'[\u{1f300}-\u{1f5ff}]|[\u{1f600}-\u{1f64f}]|[\u{1f680}-\u{1f6ff}]|[\u{2600}-\u{26ff}]|[\u{2700}-\u{27bf}]', unicode: true);
    final match = emojiRegex.firstMatch(text);
    return match?.group(0) ?? '💡';
  }

  String _removeEmoji(String text) {
    return text.replaceAll(RegExp(r'[\u{1f300}-\u{1f5ff}]|[\u{1f600}-\u{1f64f}]|[\u{1f680}-\u{1f6ff}]|[\u{2600}-\u{26ff}]|[\u{2700}-\u{27bf}]', unicode: true), '').trim();
  }

  Widget _buildInputSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.chatbotInputHint,
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    prefixIcon: Icon(
                      Icons.psychology_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(28),
                  onTap: _sendMessage,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.send_rounded,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension AnimationExtension on Widget {
  Widget animate() => _AnimatedWrapper(child: this);
}

class _AnimatedWrapper extends StatefulWidget {
  final Widget child;

  const _AnimatedWrapper({required this.child});

  @override
  State<_AnimatedWrapper> createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<_AnimatedWrapper>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<Offset>(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scaleX: _scaleAnimation.value.dx,
          scaleY: _scaleAnimation.value.dy,
          child: widget.child,
        );
      },
    );
  }

  Widget scale({
    required Offset begin,
    required Duration duration,
    required Curve curve,
  }) {
    return widget.child;
  }

  Widget onTap(VoidCallback callback) {
    return GestureDetector(
      onTap: callback,
      child: widget.child,
    );
  }
}

extension DurationExtension on int {
  Duration get milliseconds => Duration(milliseconds: this);
}

void showElegantFAQChatBot(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (context) {
      return const ElegantFAQChatBot();
    },
  );
}