import 'package:flutter/foundation.dart';

enum UserRole { admin, seller }

class User {
  final String email;
  final String? name; // Ajout pour le profil
  final UserRole role;
  final DateTime? lastLogin; // Pour statistiques

  User({
    required this.email,
    this.name,
    required this.role,
    this.lastLogin,
  });

  // Méthode pour simuler des données utilisateur complètes
  factory User.demoAdmin() {
    return User(
      email: 'admin@demo.com',
      name: 'Administrateur SmartStock',
      role: UserRole.admin,
      lastLogin: DateTime.now(),
    );
  }

  factory User.demoSeller() {
    return User(
      email: 'vendeur@demo.com',
      name: 'Vendeur SmartStock',
      role: UserRole.seller,
      lastLogin: DateTime.now(),
    );
  }
}

class AuthService with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // Données mock pour le dashboard
  Map<String, dynamic> get dashboardStats {
    if (_currentUser == null) return {};
    
    return _currentUser!.role == UserRole.admin 
      ? _adminDashboardStats
      : _sellerDashboardStats;
  }

  final Map<String, dynamic> _adminDashboardStats = {
    'totalProducts': 142,
    'dailySales': 1240.0,
    'lowStockItems': 8,
    'newCustomers': 3,
    'salesTrend': 12.5, // %
  };

  final Map<String, dynamic> _sellerDashboardStats = {
    'dailySales': 680.0,
    'stockAvailability': 76, // %
    'salesTarget': 15, // %
    'topProduct': 'PC Portable',
    'conversionRate': 32.4, // %
  };

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800)); // Simulation réseau

    try {
      // Simulation d'authentification
      if (email == 'admin@demo.com' && password == '1234') {
        _currentUser = User.demoAdmin();
      } else if (email == 'vendeur@demo.com' && password == '1234') {
        _currentUser = User.demoSeller();
      } else {
        throw Exception('Identifiants incorrects');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _currentUser = User(
      email: email,
      name: name,
      role: role,
      lastLogin: DateTime.now(),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulation délai
    _currentUser = null;
    notifyListeners();
  }

  // Méthodes pour le dashboard
  String get userDisplayName => _currentUser?.name ?? _currentUser?.email ?? 'Invité';
  
  String get userRoleDisplay {
    switch (_currentUser?.role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.seller:
        return 'Vendeur';
      default:
        return 'Non connecté';
    }
  }

  DateTime? get lastLoginDate => _currentUser?.lastLogin;
}