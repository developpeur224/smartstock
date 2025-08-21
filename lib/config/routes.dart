import 'package:flutter/material.dart';
import 'package:smart_stock/screens/auth/login_screen.dart';
import 'package:smart_stock/screens/dashboard/dashboard_screen.dart';
import 'package:smart_stock/screens/main_navigation.dart';
import 'package:smart_stock/screens/products/product_detail_screen.dart';
import 'package:smart_stock/screens/products/product_form_screen.dart';
import 'package:smart_stock/screens/products/product_list_screen.dart';
import 'package:smart_stock/models/product.dart';

class AppRoutes {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String main = '/main';

  static const String productList = '/products';
  static const String productDetails = '/product-details';
  static const String addProduct = '/add-product';
  static const String editProduct = '/edit-product';

  static const String salesList = '/sales';
  static const String addSale = '/add-sale';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainNavigation());
      case productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      case productDetails:
        final Product product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        );
      case addProduct:
        return MaterialPageRoute(builder: (_) => ProductFormScreen());
      case editProduct:
        final Product product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (_) => ProductFormScreen(product: product),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}