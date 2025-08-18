# SmartSpend

Application de gestion de dépenses intelligente développée en C++ et Dart avec Flutter.

## Description

SmartSpend est une application multi-plateforme conçue pour la gestion intelligente des finances personnelles. Elle combine la puissance du C++ pour les calculs complexes avec l'élégance de Flutter pour une interface utilisateur moderne et responsive.

## Architecture Technique

### Technologies Utilisées
- **Backend**: C/C++ pour le moteur de calcul et la logique métier
- **Frontend**: Dart/Flutter pour l'interface utilisateur
- **Build System**: CMake pour la gestion de la compilation
- **Tests**: Framework de test unitaire intégré

### Structure du Projet
```
SmartSpend/
├── src/
│   ├── core/            # Logique métier en C++
│   ├── algorithms/      # Algorithmes de calcul budgétaire
│   └── utils/          # Utilitaires communs
├── lib/                 # Code Dart/Flutter
│   ├── screens/        # Écrans de l'application
│   ├── widgets/        # Composants réutilisables
│   └── services/       # Services et gestionnaires d'état
├── tests/              # Tests unitaires et d'intégration
└── cmake/              # Configuration CMake
```

## Installation

### Prérequis
- CMake (version 3.10 ou supérieure)
- Compilateur C++ compatible C++17
- Flutter SDK (dernière version stable)
- IDE recommandé: Visual Studio Code ou Android Studio

### Étapes d'Installation
1. Cloner le dépôt:
   ```bash
   git clone https://github.com/Happyazondekon/SmartSpend.git
   cd SmartSpend
   ```

2. Configurer le projet:
   ```bash
   cmake -B build
   ```

3. Compiler:
   ```bash
   cmake --build build
   ```

4. Installer les dépendances Flutter:
   ```bash
   flutter pub get
   ```

5. Lancer l'application:
   ```bash
   flutter run
   ```

## Guide Utilisateur

### Fonctionnalités Principales

- **Planification du Budget**
   - Répartition automatique du salaire
   - Support multi-devises (XOF, USD, EUR)
   - Algorithmes d'optimisation des dépenses

- **Suivi des Dépenses**
   - Système de catégorisation intelligent
   - Reconnaissance automatique des transactions récurrentes
   - Historique détaillé des transactions

- **Analyses Statistiques**
   - Graphiques interactifs
   - Prédictions de dépenses
   - Rapports personnalisés

- **Fonctionnalités Techniques**
   - Mode hors-ligne
   - Synchronisation locale
   - Mode sombre adaptatif
   - Performance optimisée

### Utilisation

#### Saisie du Salaire
1. Ouvrez l'application
2. Dans l'onglet "Budget", saisissez votre salaire mensuel
3. Sélectionnez votre devise préférée

#### Calcul du Budget
1. Utilisez le bouton "Calculer mon budget"
2. Consultez la répartition automatique
3. Ajustez les catégories selon vos besoins

#### Gestion des Dépenses
1. Ajoutez des transactions via le bouton "+"
2. Catégorisez vos dépenses
3. Suivez vos statistiques en temps réel

#### Visualisation des Données
1. Consultez l'onglet "Statistiques"
2. Analysez les graphiques de répartition
3. Exportez vos rapports si nécessaire

### Mode Sombre
- Activation via l'icône dédiée
- Adaptation automatique selon les préférences système

### Sauvegarde des Données
- Sauvegarde locale automatique
- Option de backup manuel
- Sécurisation des données sensibles

## Contribution

Les contributions sont les bienvenues! Veuillez consulter notre guide de contribution pour plus de détails.

## License

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

---

**Note Technique**: Pour les développeurs souhaitant contribuer ou modifier l'application, veuillez consulter la documentation technique complète dans le dossier `docs/`.
