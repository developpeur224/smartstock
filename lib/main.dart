import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/routes.dart';
import 'package:smart_stock/config/theme.dart';
import 'package:smart_stock/providers/product_provider.dart';
import 'package:smart_stock/providers/sales_provider.dart';
import 'package:smart_stock/providers/stock_provider.dart';
import 'package:smart_stock/services/auth_service.dart';
import 'package:smart_stock/services/product_service.dart';
import 'package:smart_stock/services/sales_service.dart';
import 'package:smart_stock/services/stock_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
        ChangeNotifierProvider(create: (_) => SalesProvider(SalesService())),
        ChangeNotifierProvider(create: (_) => StockProvider(StockService())),
      ],
      child: MaterialApp(
        title: 'SmartStock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.materialTheme,
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}