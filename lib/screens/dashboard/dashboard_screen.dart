import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/routes.dart';
import 'package:smart_stock/config/theme.dart';
import 'package:smart_stock/services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoggingOut = false;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoggingOut = true);
      
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.logout();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoggingOut = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final stats = authService.dashboardStats;
    final isAdmin = authService.currentUser?.role == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
            tooltip: 'Notifications',
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Profil'),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red[400]),
                  title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                await _logout(context);
              }
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildUserHeader(authService),
            const SizedBox(height: 24),
            _buildStatsSection(stats, isAdmin),
            const SizedBox(height: 32),
            _buildQuickActionsSection(),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/add-product'),
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildUserHeader(AuthService authService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: Icon(Icons.person, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authService.userDisplayName,
                    style: AppTheme.headline2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authService.userRoleDisplay,
                    style: AppTheme.bodyText2.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (_isLoggingOut)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(Map<String, dynamic> stats, bool isAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques',
          style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: isAdmin 
              ? _buildAdminStats(stats)
              : _buildSellerStats(stats),
        ),
      ],
    );
  }

  List<Widget> _buildAdminStats(Map<String, dynamic> stats) {
    return [
      _buildStatCard(
        'Produits', 
        '${stats['totalProducts']}', 
        Icons.inventory_2,
        subtitle: 'en stock',
      ),
      _buildStatCard(
        'Ventes du jour', 
        '${stats['dailySales']} GNF', 
        Icons.shopping_cart,
        trend: stats['salesTrend'],
      ),
      _buildStatCard(
        'Stock faible', 
        '${stats['lowStockItems']}', 
        Icons.warning,
        color: Colors.orange,
      ),
      _buildStatCard(
        'Nouveaux clients', 
        '${stats['newCustomers']}', 
        Icons.people_alt,
        subtitle: 'ce mois',
      ),
    ];
  }

  List<Widget> _buildSellerStats(Map<String, dynamic> stats) {
    return [
      _buildStatCard(
        'Ventes du jour', 
        '${stats['dailySales']} GNF', 
        Icons.point_of_sale,
        trend: stats['conversionRate'],
      ),
      _buildStatCard(
        'Stock dispo', 
        '${stats['stockAvailability']}%', 
        Icons.warehouse,
        progress: stats['stockAvailability'] / 100,
      ),
      _buildStatCard(
        'Objectif', 
        '${stats['salesTarget']}%', 
        Icons.trending_up,
        progress: stats['salesTarget'] / 100,
      ),
      _buildStatCard(
        'Top produit', 
        stats['topProduct'].toString(), 
        Icons.star,
        color: Colors.amber,
      ),
    ];
  }

  Widget _buildStatCard(
    String title, 
    String value, 
    IconData icon, {
    String? subtitle,
    double? trend,
    double? progress,
    Color? color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color ?? AppTheme.primaryColor, size: 28),
                if (trend != null) _buildTrendIndicator(trend),
                if (progress != null) _buildProgressIndicator(progress),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyText2.copyWith(color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: AppTheme.headline2.copyWith(
                    fontSize: 22,
                    color: color ?? AppTheme.primaryColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTheme.bodyText2.copyWith(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(double trend) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          trend >= 0 ? Icons.trending_up : Icons.trending_down,
          color: trend >= 0 ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '${trend.abs()}%',
          style: TextStyle(
            color: trend >= 0 ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return SizedBox(
      width: 40,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey[200],
        color: progress >= 0.8 
            ? Colors.green 
            : progress >= 0.5 
                ? Colors.orange 
                : Colors.red,
        minHeight: 6,
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accès rapide',
          style: AppTheme.headline2.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.8,
          children: [
            _buildQuickActionButton('Produits', Icons.inventory_2, '/products'),
            _buildQuickActionButton('Ventes', Icons.receipt_long, '/sales'),
            _buildQuickActionButton('Stock', Icons.warehouse, '/inventory'),
            _buildQuickActionButton('Clients', Icons.people_outline, '/clients'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pushNamed(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}