// providers_setup.dart
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:smart_stock/providers/product_provider.dart';
import 'package:smart_stock/providers/sales_provider.dart';
import 'package:smart_stock/services/product_service.dart';
import 'package:smart_stock/services/sales_service.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(
      create: (context) => ProductProvider(ProductService()),
    ),
    ChangeNotifierProvider(
      create: (context) => SalesProvider(SalesService()),
    ),
  ];
}