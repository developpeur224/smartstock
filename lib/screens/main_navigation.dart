import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/theme.dart';
import 'package:smart_stock/providers/product_provider.dart';
import 'package:smart_stock/providers/sales_provider.dart';
import 'package:smart_stock/screens/dashboard/dashboard_screen.dart';
import 'package:smart_stock/screens/products/product_list_screen.dart';
import 'package:smart_stock/screens/sales/sales_list_screen.dart';
import 'package:smart_stock/screens/stock/stock_movements_screen.dart';
import 'package:smart_stock/services/product_service.dart';
import 'package:smart_stock/services/sales_service.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    ChangeNotifierProvider(
      create: (context) => ProductProvider(ProductService()),
      child: const ProductListScreen(),
    ),
    ChangeNotifierProvider(
       create: (context) => SalesProvider(SalesService()),
       child: const SalesListScreen(),
     ),
    const StockMovementsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Ventes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse_outlined),
            activeIcon: Icon(Icons.warehouse),
            label: 'Stock',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }
}