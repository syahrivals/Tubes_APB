import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

/// Singleton database helper — semua CRUD operasi ada di sini.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expert_printing.db');
    return await openDatabase(
      path,
      version: 2, // Naikkan versi biar ngetrigger onUpgrade
      onCreate: _createTables,
      onUpgrade: (db, oldVersion, newVersion) async {
        // Kalau versi naik, reset database (hapus tabel, bikin ulang + isi dummy)
        await db.execute('DROP TABLE IF EXISTS notifications');
        await db.execute('DROP TABLE IF EXISTS order_items');
        await db.execute('DROP TABLE IF EXISTS orders');
        await db.execute('DROP TABLE IF EXISTS cart_items');
        await db.execute('DROP TABLE IF EXISTS service_branches');
        await db.execute('DROP TABLE IF EXISTS branches');
        await db.execute('DROP TABLE IF EXISTS services');
        await db.execute('DROP TABLE IF EXISTS users');
        await _createTables(db, newVersion);
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price INTEGER NOT NULL DEFAULT 0,
        unit TEXT NOT NULL DEFAULT 'lembar',
        options TEXT DEFAULT '',
        description TEXT DEFAULT '',
        isActive INTEGER NOT NULL DEFAULT 1,
        icon TEXT DEFAULT 'print_outlined'
      )
    ''');

    await db.execute('''
      CREATE TABLE branches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL DEFAULT '',
        latitude REAL NOT NULL DEFAULT 0.0,
        longitude REAL NOT NULL DEFAULT 0.0,
        isOpen INTEGER NOT NULL DEFAULT 1,
        openHours TEXT DEFAULT '08.00 – 20.00',
        rating REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE service_branches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        serviceId INTEGER NOT NULL,
        branchId INTEGER NOT NULL,
        FOREIGN KEY (serviceId) REFERENCES services(id) ON DELETE CASCADE,
        FOREIGN KEY (branchId) REFERENCES branches(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        serviceId INTEGER NOT NULL,
        serviceName TEXT NOT NULL DEFAULT '',
        quantity INTEGER NOT NULL DEFAULT 1,
        size TEXT DEFAULT '',
        filePath TEXT,
        unitPrice INTEGER NOT NULL DEFAULT 0,
        totalPrice INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (serviceId) REFERENCES services(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        orderId TEXT PRIMARY KEY,
        userId INTEGER NOT NULL,
        branchId INTEGER NOT NULL,
        branchName TEXT DEFAULT '',
        status TEXT NOT NULL DEFAULT 'Pending',
        totalPrice INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (branchId) REFERENCES branches(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId TEXT NOT NULL,
        serviceId INTEGER NOT NULL,
        serviceName TEXT NOT NULL DEFAULT '',
        quantity INTEGER NOT NULL DEFAULT 1,
        size TEXT DEFAULT '',
        filePath TEXT,
        price INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (orderId) REFERENCES orders(orderId) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    
    // Panggil seeder setelah tabel selesai dibuat
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // 1. Seed Dummy User
    await db.insert('users', {
      'name': 'Syahri Dummy',
      'email': 'user@expert.com',
      'password': 'password',
      'phone': '08123456789'
    });

    // 2. Seed Dummy Services
    final services = [
      {'name': 'Print Booklet', 'price': 15000, 'unit': 'pcs', 'options': 'A4, A5', 'description': 'Cetak booklet warna berkualitas tinggi untuk majalah atau portofolio.', 'isActive': 1},
      {'name': 'Print Poster', 'price': 5000, 'unit': 'lembar', 'options': 'A3, A3+', 'description': 'Poster ukuran besar dengan bahan Art Carton.', 'isActive': 1},
      {'name': 'Cetak ID Card', 'price': 10000, 'unit': 'pcs', 'options': 'PVC', 'description': 'ID Card bahan PVC anti air.', 'isActive': 1},
      {'name': 'Print Hitam Putih', 'price': 500, 'unit': 'lembar', 'options': 'A4, F4', 'description': 'Print dokumen hitam putih biasa untuk tugas.', 'isActive': 1},
      {'name': 'Print Warna', 'price': 1000, 'unit': 'lembar', 'options': 'A4, F4', 'description': 'Print warna standar di kertas HVS.', 'isActive': 1},
    ];
    for (var s in services) {
      await db.insert('services', s);
    }

    // 3. Seed Dummy Branches
    final branches = [
      {
        'name': 'Cabang Utama Dago', 
        'address': 'Jl. Ir. H. Juanda No. 123, Bandung',
        'latitude': -6.8915, 
        'longitude': 107.6107,
        'isOpen': 1, 
        'openHours': '08.00 – 22.00', 
        'rating': 4.8
      },
      {
        'name': 'Cabang Buah Batu', 
        'address': 'Jl. Buah Batu No. 50, Bandung',
        'latitude': -6.9388, 
        'longitude': 107.6253,
        'isOpen': 1, 
        'openHours': '09.00 – 21.00', 
        'rating': 4.5
      },
      {
        'name': 'Cabang Dipatiukur', 
        'address': 'Jl. Dipati Ukur No. 80, Bandung',
        'latitude': -6.8906, 
        'longitude': 107.6171,
        'isOpen': 0, // Tutup
        'openHours': '08.00 – 17.00', 
        'rating': 4.2
      }
    ];
    for (var b in branches) {
      await db.insert('branches', b);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert('users', user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<UserModel?> getUserByEmailAndPassword(
      String email, String password) async {
    final db = await database;
    final result = await db.query('users',
        where: 'email = ? AND password = ?', whereArgs: [email, password]);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<bool> emailExists(String email) async {
    final db = await database;
    final result =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    return result.isNotEmpty;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SERVICE CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertService(ServiceModel service) async {
    final db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<List<ServiceModel>> getAllServices() async {
    final db = await database;
    final result = await db.query('services', orderBy: 'id DESC');
    return result.map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<List<ServiceModel>> getActiveServices() async {
    final db = await database;
    final result = await db
        .query('services', where: 'isActive = ?', whereArgs: [1], orderBy: 'id DESC');
    return result.map((e) => ServiceModel.fromMap(e)).toList();
  }

  Future<int> updateService(ServiceModel service) async {
    final db = await database;
    return await db.update('services', service.toMap(),
        where: 'id = ?', whereArgs: [service.id]);
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BRANCH CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertBranch(BranchModel branch) async {
    final db = await database;
    return await db.insert('branches', branch.toMap());
  }

  Future<List<BranchModel>> getAllBranches() async {
    final db = await database;
    final result = await db.query('branches', orderBy: 'id DESC');
    return result.map((e) => BranchModel.fromMap(e)).toList();
  }

  Future<int> updateBranch(BranchModel branch) async {
    final db = await database;
    return await db.update('branches', branch.toMap(),
        where: 'id = ?', whereArgs: [branch.id]);
  }

  Future<int> deleteBranch(int id) async {
    final db = await database;
    return await db.delete('branches', where: 'id = ?', whereArgs: [id]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CART CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertCartItem(CartItemModel item) async {
    final db = await database;
    return await db.insert('cart_items', item.toMap());
  }

  Future<List<CartItemModel>> getCartItems(int userId) async {
    final db = await database;
    final result = await db
        .query('cart_items', where: 'userId = ?', whereArgs: [userId]);
    return result.map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<int> deleteCartItem(int id) async {
    final db = await database;
    return await db.delete('cart_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCart(int userId) async {
    final db = await database;
    await db.delete('cart_items', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<void> deleteCartItemsByIds(List<int> ids) async {
    final db = await database;
    final placeholders = ids.map((_) => '?').join(',');
    await db.delete('cart_items',
        where: 'id IN ($placeholders)', whereArgs: ids);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ORDER CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> insertOrder(
      OrderModel order, List<OrderItemModel> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('orders', order.toMap());
      for (final item in items) {
        await txn.insert('order_items', item.toMap());
      }
    });
  }

  Future<List<OrderModel>> getOrdersByUser(int userId) async {
    final db = await database;
    final result = await db.query('orders',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return result.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderModel>> getAllOrders() async {
    final db = await database;
    final result = await db.query('orders', orderBy: 'createdAt DESC');
    return result.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    final db = await database;
    final result = await db
        .query('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    return result.map((e) => OrderItemModel.fromMap(e)).toList();
  }

  Future<int> updateOrderStatus(String orderId, String newStatus) async {
    final db = await database;
    return await db.update('orders', {'status': newStatus},
        where: 'orderId = ?', whereArgs: [orderId]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NOTIFICATION CRUD
  // ══════════════════════════════════════════════════════════════════════════

  Future<int> insertNotification(NotificationModel notification) async {
    final db = await database;
    return await db.insert('notifications', notification.toMap());
  }

  Future<List<NotificationModel>> getNotifications(int userId) async {
    final db = await database;
    final result = await db.query('notifications',
        where: 'userId = ?', whereArgs: [userId], orderBy: 'createdAt DESC');
    return result.map((e) => NotificationModel.fromMap(e)).toList();
  }

  Future<int> markNotificationAsRead(int id) async {
    final db = await database;
    return await db.update('notifications', {'isRead': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SERVICE-BRANCH RELATIONSHIP
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> setServiceBranches(
      int serviceId, List<int> branchIds) async {
    final db = await database;
    await db.delete('service_branches',
        where: 'serviceId = ?', whereArgs: [serviceId]);
    for (final branchId in branchIds) {
      await db.insert('service_branches', {
        'serviceId': serviceId,
        'branchId': branchId,
      });
    }
  }

  Future<List<int>> getBranchIdsForService(int serviceId) async {
    final db = await database;
    final result = await db.query('service_branches',
        where: 'serviceId = ?', whereArgs: [serviceId]);
    return result.map((e) => e['branchId'] as int).toList();
  }

  Future<List<ServiceModel>> getServicesForBranch(int branchId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT s.* FROM services s
      INNER JOIN service_branches sb ON s.id = sb.serviceId
      WHERE sb.branchId = ? AND s.isActive = 1
    ''', [branchId]);
    return result.map((e) => ServiceModel.fromMap(e)).toList();
  }
}
