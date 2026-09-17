import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/product_model.dart';

/// Repository for handling Product and Category data from Cloud Firestore with cached fallback
class ProductRepository {
  static final ProductRepository _instance = ProductRepository._internal();
  factory ProductRepository() => _instance;
  ProductRepository._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// In-memory cache of categories (empty in production until fetched from Firestore or seeded in tests)
  List<FreshCategory> _cachedCategories = [];

  /// In-memory cache of products (empty in production until fetched from Firestore or seeded in tests)
  List<Product> _cachedProducts = [];

  /// Helper to seed data explicitly for unit/widget tests
  void seedForTesting({
    List<FreshCategory>? categories,
    List<Product>? products,
  }) {
    if (categories != null) _cachedCategories = List.from(categories);
    if (products != null) _cachedProducts = List.from(products);
  }

  /// Get current cached categories
  List<FreshCategory> get cachedCategories => List.unmodifiable(_cachedCategories);

  /// Get current cached products
  List<Product> get cachedProducts => List.unmodifiable(_cachedProducts);

  /// Synchronous category lookup
  FreshCategory? getCategoryById(String id) {
    try {
      return _cachedCategories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Synchronous products lookup by category
  List<Product> getProductsByCategory(String categoryId) {
    if (categoryId.toLowerCase() == 'all') return _cachedProducts;
    return _cachedProducts.where((p) => p.categoryId == categoryId).toList();
  }

  /// Synchronous product lookup by ID
  Product? getProductById(String id) {
    try {
      return _cachedProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Global product search across all categories (case-insensitive, trimmed)
  List<Product> searchProducts(String query) {
    if (query.trim().isEmpty) return List.unmodifiable(_cachedProducts);
    final q = query.toLowerCase().trim();
    return _cachedProducts.where((p) {
      final matchesName = p.name.toLowerCase().contains(q);
      final matchesCategory = p.categoryName.toLowerCase().contains(q);
      final matchesCategoryId = p.categoryId.toLowerCase().contains(q);
      final matchesDesc = p.description?.toLowerCase().contains(q) ?? false;
      final matchesOrigin = p.farmOrigin?.toLowerCase().contains(q) ?? false;
      return matchesName ||
          matchesCategory ||
          matchesCategoryId ||
          matchesDesc ||
          matchesOrigin;
    }).toList();
  }

  /// Stream of all product categories from Firestore collection 'categories'
  Stream<List<FreshCategory>> getCategoriesStream() {
    final db = _firestore;
    if (db == null) {
      return Stream.value(_cachedCategories);
    }

    try {
      return db.collection('categories').snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          _cachedCategories = [];
          return <FreshCategory>[];
        }
        final list = snapshot.docs
            .map((doc) => FreshCategory.fromMap(doc.data(), doc.id))
            .toList();
        _cachedCategories = list;
        return list;
      }).handleError((error) {
        debugPrint('ProductRepository: getCategoriesStream notice: $error');
        return _cachedCategories;
      });
    } catch (_) {
      return Stream.value(_cachedCategories);
    }
  }

  /// Stream of all products from Firestore collection 'products', optionally filtered by categoryId
  Stream<List<Product>> getProductsStream({String? categoryId}) {
    final db = _firestore;
    if (db == null) {
      final cached = categoryId == null || categoryId == 'all'
          ? _cachedProducts
          : getProductsByCategory(categoryId);
      return Stream.value(cached);
    }

    try {
      Query<Map<String, dynamic>> query = db.collection('products');
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      return query.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          if (categoryId == null || categoryId == 'all') {
            _cachedProducts = [];
          }
          return <Product>[];
        }
        final list = snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList();
        if (categoryId == null || categoryId == 'all') {
          _cachedProducts = list;
        }
        return list;
      }).handleError((error) {
        debugPrint('ProductRepository: getProductsStream notice: $error');
        return <Product>[];
      });
    } catch (_) {
      return Stream.value(<Product>[]);
    }
  }

  /// Stream of fresh deal products (discounted items) from Firestore collection 'products'
  Stream<List<Product>> getFreshDealsStream() {
    final db = _firestore;
    if (db == null) {
      return Stream.value(_cachedProducts.where((p) => p.badge != null).take(4).toList());
    }

    try {
      return db
          .collection('products')
          .where('badge', isNull: false)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return <Product>[];
        }
        return snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), doc.id))
            .toList();
      }).handleError((e) {
        debugPrint('ProductRepository: getFreshDealsStream error: $e');
        return <Product>[];
      });
    } catch (e) {
      debugPrint('ProductRepository: getFreshDealsStream catch: $e');
      return Stream.value(<Product>[]);
    }
  }

  /// Stream of a single product by ID from Firestore collection 'products/{id}'
  Stream<Product?> getProductByIdStream(String id) {
    final db = _firestore;
    if (db == null) {
      return Stream.value(getProductById(id));
    }

    try {
      return db.collection('products').doc(id).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) {
          return getProductById(id);
        }
        return Product.fromMap(doc.data()!, doc.id);
      }).handleError((_) {
        return getProductById(id);
      });
    } catch (_) {
      return Stream.value(getProductById(id));
    }
  }
}

/// CategoryRepository alias pointing to the centralized ProductRepository
typedef CategoryRepository = ProductRepository;

