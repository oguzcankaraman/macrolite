import 'package:dio/dio.dart';
import 'package:macrolite/features/tracker/domain/food_item.dart';
import 'package:uuid/uuid.dart';

class OpenFoodFactsService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  DateTime? _lastRequestTime;
  static const Duration _cooldown = Duration(
    milliseconds: 800,
  ); // Faster rate limit

  Future<List<FoodItem>> searchFood(String query) async {
    // Rate Limiting
    if (_lastRequestTime != null) {
      final timeSinceLast = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLast < _cooldown) {
        // Wait for the remaining cooldown
        await Future.delayed(_cooldown - timeSinceLast);
      }
    }
    _lastRequestTime = DateTime.now();

    try {
      print('OpenFoodFacts: Searching for "$query"');
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page_size': 20,
          'sort_by': 'unique_scans_n', // Sort by popularity
          'fields':
              'product_name,product_name_tr,product_name_en,nutriments,serving_quantity,serving_size,unique_scans_n', // Optimization
        },
        options: Options(
          headers: {
            'User-Agent':
                'MacroLite - Android/iOS - Version 1.0 - macrolite.app', // Compliant User-Agent
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['products'] is List) {
          final products = data['products'] as List;
          print('OpenFoodFacts: Found ${products.length} items');

          return products
              .map((json) => _mapToFoodItem(json))
              .where((item) => item != null) // Filter out failed mappings
              .cast<FoodItem>()
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load food data: ${response.statusCode}');
      }
    } catch (e) {
      print('OpenFoodFacts: Error $e');
      throw Exception('Error fetching data: $e');
    }
  }

  FoodItem? _mapToFoodItem(dynamic json) {
    if (json is! Map) return null;

    final nutriments = json['nutriments'];
    if (nutriments == null || nutriments is! Map || nutriments.isEmpty)
      return null;

    // Filter out items with absolutely no energy data (likely incomplete)
    // We allow 0 if it's explicitly 0, but usually empty map means no data.
    // Let's check if at least one major macro is present or energy is present.
    if (!_hasData(nutriments, 'energy-kcal') &&
        !_hasData(nutriments, 'energy-kcal_100g')) {
      return null;
    }

    final String name =
        json['product_name'] ??
        json['product_name_tr'] ??
        json['product_name_en'] ??
        'Unknown';

    // OpenFoodFacts usually provides data per 100g/100ml
    // We check serving size but default to 100g base if not clear,
    // but actually for consistency with our app logic, it's safer to always use 100g
    // as the base amount because the 'nutriments' object keys like 'energy-kcal_100g'
    // explicitly refer to 100g.

    final double calories =
        _parseNum(nutriments['energy-kcal_100g']) ??
        _parseNum(nutriments['energy-kcal']) ??
        0.0;
    final double protein =
        _parseNum(nutriments['proteins_100g']) ??
        _parseNum(nutriments['proteins']) ??
        0.0;
    final double carbs =
        _parseNum(nutriments['carbohydrates_100g']) ??
        _parseNum(nutriments['carbohydrates']) ??
        0.0;
    final double fat =
        _parseNum(nutriments['fat_100g']) ??
        _parseNum(nutriments['fat']) ??
        0.0;

    // Filter out items with no calorie info if desired, but let's keep them for now

    // Parse serving size and unit
    double? servingSizeG;
    String? servingUnit;

    if (json['serving_quantity'] != null) {
      servingSizeG = _parseNum(json['serving_quantity']);
    }

    if (json['serving_size'] != null) {
      final String servingStr = json['serving_size'].toString().toLowerCase();

      // If we didn't get quantity from serving_quantity, try to parse it from string
      if (servingSizeG == null) {
        final RegExp regExp = RegExp(r'(\d+(\.\d+)?)');
        final match = regExp.firstMatch(servingStr);
        if (match != null) {
          servingSizeG = double.tryParse(match.group(1)!);
        }
      }

      // Smart Unit Detection
      // Check for specific keywords in the serving string
      // Prioritize specific units over generic "portion" or "g"

      // Regex for liquid (ml, l, cl)
      // Matches: 330ml, 330 ml, 1l, 1 l, 1.5L
      final mlRegex = RegExp(r'\d\s*(ml|l|cl)\b');

      if (mlRegex.hasMatch(servingStr) || servingStr.contains('milliliter')) {
        servingUnit = 'Ml';
      } else if (servingStr.contains('biscuit') ||
          servingStr.contains('cookie') ||
          servingStr.contains('adet') ||
          servingStr.contains('piece') ||
          servingStr.contains('egg') ||
          servingStr.contains('yumurta')) {
        servingUnit = 'Adet';
      } else if (servingStr.contains('slice') ||
          servingStr.contains('dilim') ||
          servingStr.contains('tranche')) {
        servingUnit = 'Dilim';
      } else if (servingStr.contains('bar') ||
          servingStr.contains('paket') ||
          servingStr.contains('pack')) {
        servingUnit = 'Paket';
      } else if (servingStr.contains('cup') ||
          servingStr.contains('bardak') ||
          servingStr.contains('verre')) {
        servingUnit = 'Bardak';
      } else if (servingStr.contains('tbsp') ||
          servingStr.contains('kaşık') ||
          servingStr.contains('spoon')) {
        servingUnit = 'Kaşık';
      } else if (servingStr.contains('portion') ||
          servingStr.contains('porsiyon')) {
        // Explicit portion
        servingUnit = 'Porsiyon';
      } else if (servingStr.contains('g') || servingStr.contains('gram')) {
        // If it explicitly says grams but no other unit, it's just a portion size in grams.
        // We can leave servingUnit null or set to 'Porsiyon' if we want to show it as a serving option
        // Example: "20g" -> We might want to allow user to select "1 Porsiyon (20g)"
        servingUnit = 'Porsiyon';
      } else {
        // Default to "Porsiyon" if we have a size but no specific unit
        if (servingSizeG != null) {
          servingUnit = 'Porsiyon';
        }
      }
    }

    return FoodItem(
      id: const Uuid().v4(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      unit: 'gram',
      baseAmount: 100.0, // Standardize on 100g for OpenFoodFacts
      servingSizeG: servingSizeG,
      servingUnit: servingUnit,
    );
  }

  double? _parseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool _hasData(Map map, String key) {
    return map.containsKey(key) && map[key] != null && map[key] != '';
  }
}
