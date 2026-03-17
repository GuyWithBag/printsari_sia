import 'package:flutter/material.dart';
import 'package:printsari_sia/shared/types/types.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<List<Product>> getProducts() async {
    final query = await supabase
        .from('products')
        .select('*, product_categories(*)');
    final result = List.generate(
      query.length,
      (i) => Product.fromJson(query[i]),
    );
    return result;
  }

  Future<List<PrintService>> getPrintServices() async {
    final query = await supabase
        .from('print_services')
        .select(
          '*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*)',
        );
    final result = List.generate(
      query.length,
      (i) => PrintService.fromJson(query[i]),
    );
    return result;
  }

  Future<Product> createProduct(Product product) async {
    final inserted = await supabase
        .from('products')
        .insert(product.toInsertJson())
        .select('*, product_categories(*)')
        .single();
    notifyListeners();
    return Product.fromJson(inserted);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> updates) async {
    final updated = await supabase
        .from('products')
        .update(updates)
        .eq('id', id)
        .select('*, product_categories(*)')
        .single();
    notifyListeners();
    return Product.fromJson(updated);
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('id', id);
    notifyListeners();
  }

  Future<PrintService> createPrintService(PrintService service) async {
    final inserted = await supabase
        .from('print_services')
        .insert(service.toInsertJson())
        .select(
          '*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*)',
        )
        .single();
    notifyListeners();
    return PrintService.fromJson(inserted);
  }

  Future<PrintService> updatePrintService(
    int id,
    Map<String, dynamic> updates,
  ) async {
    final updated = await supabase
        .from('print_services')
        .update(updates)
        .eq('id', id)
        .select(
          '*, paper_sizes(*), color_modes(*), print_orientations(*), print_finishes(*)',
        )
        .single();
    notifyListeners();
    return PrintService.fromJson(updated);
  }

  Future<void> deletePrintService(int id) async {
    await supabase.from('print_services').delete().eq('id', id);
    notifyListeners();
  }
}
