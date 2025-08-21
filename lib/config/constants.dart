import 'package:flutter/material.dart';

class AppConstants {
  // ==================== Application ==================== //
  static const String appName = 'SmartStock';
  static const String defaultCurrency = 'GNF';
  static const String defaultUnit = 'unité';

  // ==================== Configuration API ==================== //
  static const String apiBaseUrl = 'https://api.smartstock.com/v1';
  static const String salesEndpoint = '/sales';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int syncRetryAttempts = 3;
  static const Duration syncInterval = Duration(minutes: 15);

  // ==================== Authentification ==================== //
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const Duration tokenExpiryThreshold = Duration(minutes: 5);

  // ==================== Base de données ==================== //
  static const String databaseName = 'smartstock.db';
  static const int databaseVersion = 2;
  static const String salesTable = 'sales';
  static const String saleItemsTable = 'sale_items';

  // ==================== UI Générale ==================== //
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;

  static const double defaultElevation = 2.0;
  static const double appBarElevation = 0.0;

  // ==================== Thème & Couleurs ==================== //
  static const Color primaryColor = Color(0xFF3366CC);
  static const Color secondaryColor = Color(0xFF33CCCC);
  static const Color accentColor = Color(0xFFFF6633);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFF44336);
  static const Color disabledColor = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFEEEEEE);

  // ==================== Typographie ==================== //
  static const String fontFamily = 'Roboto';
  static const double headlineFontSize = 24.0;
  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;

  // ==================== Stock ==================== //
  static const List<String> stockMovementTypes = ['Entrée', 'Sortie', 'Ajustement'];
  static const double stockCardElevation = 2.0;
  static const EdgeInsets stockCardMargin = EdgeInsets.symmetric(
    horizontal: paddingMedium,
    vertical: paddingSmall,
  );
  static const EdgeInsets stockCardPadding = EdgeInsets.all(paddingMedium);
  static const double stockWarningThreshold = 5.0;

  // ==================== Produits ==================== //
  static const int maxProductQuantity = 9999;
  static const int barcodeLength = 13;
  static const double productImageSize = 60.0;

  // ==================== Ventes ==================== //
  static const int maxSaleItems = 20;
  static const int maxSearchHistory = 5;
  static const double minSaleAmount = 0.01;
  static const double maxSaleAmount = 999999.99;
  static const EdgeInsets saleItemPadding = EdgeInsets.symmetric(
    horizontal: paddingMedium,
    vertical: paddingSmall,
  );

  // ==================== Formats ==================== //
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String currencyFormat = '###,###.##';
  static const String quantityFormat = '###,###';
}

/// Couleurs spécifiques au module Ventes
class SalesColors {
  static const Color paid = Color(0xFF4CAF50); // Vert
  static const Color unpaid = Color(0xFFF44336); // Rouge
  static const Color partial = Color(0xFFFFC107); // Orange
  static const Color background = Color(0xFFF5F5F5);
}

/// Icônes spécifiques au module Ventes
class SalesIcons {
  static const IconData sale = Icons.point_of_sale;
  static const IconData receipt = Icons.receipt;
  static const IconData paid = Icons.check_circle;
  static const IconData unpaid = Icons.pending;
  static const IconData client = Icons.person;
}

/// Statuts de synchronisation
class SyncStatus {
  static const String synced = 'synced';
  static const String pending = 'pending';
  static const String failed = 'failed';

  static const List<String> all = [synced, pending, failed];
}

/// Types de paiement
class PaymentTypes {
  static const String cash = 'cash';
  static const String card = 'card';
  static const String transfer = 'transfer';
  static const String check = 'check';
  static const String other = 'other';

  static const List<String> all = [cash, card, transfer, check, other];
}

/// Constantes pour les préférences utilisateur
class PrefKeys {
  static const String themeMode = 'theme_mode';
  static const String languageCode = 'language_code';
  static const String firstLaunch = 'first_launch';
  static const String userPreferences = 'user_preferences';
  static const String lastSync = 'last_sync_timestamp';
  static const String defaultPaymentMethod = 'default_payment_method';
}

/// Constantes pour la synchronisation
class SyncConstants {
  static const int batchSize = 50;
  static const int maxConflictRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  static const String salesSyncKey = 'last_sales_sync';
}

/// Méthodes d'extension pour les constantes de chaînes
extension SyncStatusExtensions on String {
  bool get isSynced => this == SyncStatus.synced;
  bool get isPending => this == SyncStatus.pending;
  bool get isFailed => this == SyncStatus.failed;

  Color get syncStatusColor {
    switch (this) {
      case SyncStatus.synced:
        return SalesColors.paid;
      case SyncStatus.pending:
        return SalesColors.partial;
      case SyncStatus.failed:
        return SalesColors.unpaid;
      default:
        return Colors.grey;
    }
  }
}

extension PaymentTypesExtensions on String {
  bool get isCash => this == PaymentTypes.cash;
  bool get isCard => this == PaymentTypes.card;
  bool get isTransfer => this == PaymentTypes.transfer;
  bool get isCheck => this == PaymentTypes.check;
  bool get isOther => this == PaymentTypes.other;

  IconData get paymentIcon {
    switch (this) {
      case PaymentTypes.cash:
        return Icons.attach_money;
      case PaymentTypes.card:
        return Icons.credit_card;
      case PaymentTypes.transfer:
        return Icons.account_balance;
      case PaymentTypes.check:
        return Icons.description;
      case PaymentTypes.other:
        return Icons.payment;
      default:
        return Icons.payment;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentTypes.cash:
        return 'Espèces';
      case PaymentTypes.card:
        return 'Carte';
      case PaymentTypes.transfer:
        return 'Virement';
      case PaymentTypes.check:
        return 'Chèque';
      case PaymentTypes.other:
        return 'Autre';
      default:
        return 'Inconnu';
    }
  }
}