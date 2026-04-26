/// Data models untuk Expert Printing App
/// Semua model punya toMap() untuk insert ke DB dan fromMap() untuk baca dari DB.

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String phone;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        id: map['id'],
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        phone: map['phone'] ?? '',
      );
}

class ServiceModel {
  final int? id;
  final String name;
  final int price;
  final String unit;
  final String options; // comma-separated: "BW,Berwarna"
  final String description;
  final bool isActive;
  final String icon; // icon name string

  ServiceModel({
    this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.options = '',
    this.description = '',
    this.isActive = true,
    this.icon = 'print_outlined',
  });

  List<String> get optionsList =>
      options.isEmpty ? [] : options.split(',').map((e) => e.trim()).toList();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'price': price,
        'unit': unit,
        'options': options,
        'description': description,
        'isActive': isActive ? 1 : 0,
        'icon': icon,
      };

  factory ServiceModel.fromMap(Map<String, dynamic> map) => ServiceModel(
        id: map['id'],
        name: map['name'] ?? '',
        price: map['price'] ?? 0,
        unit: map['unit'] ?? '',
        options: map['options'] ?? '',
        description: map['description'] ?? '',
        isActive: (map['isActive'] ?? 1) == 1,
        icon: map['icon'] ?? 'print_outlined',
      );

  ServiceModel copyWith({
    int? id,
    String? name,
    int? price,
    String? unit,
    String? options,
    String? description,
    bool? isActive,
    String? icon,
  }) =>
      ServiceModel(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
        unit: unit ?? this.unit,
        options: options ?? this.options,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
        icon: icon ?? this.icon,
      );
}

class BranchModel {
  final int? id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final String openHours;
  final double rating;

  BranchModel({
    this.id,
    required this.name,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.isOpen = true,
    this.openHours = '08.00 – 20.00',
    this.rating = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'isOpen': isOpen ? 1 : 0,
        'openHours': openHours,
        'rating': rating,
      };

  factory BranchModel.fromMap(Map<String, dynamic> map) => BranchModel(
        id: map['id'],
        name: map['name'] ?? '',
        address: map['address'] ?? '',
        latitude: (map['latitude'] ?? 0.0).toDouble(),
        longitude: (map['longitude'] ?? 0.0).toDouble(),
        isOpen: (map['isOpen'] ?? 1) == 1,
        openHours: map['openHours'] ?? '08.00 – 20.00',
        rating: (map['rating'] ?? 0.0).toDouble(),
      );
}

class CartItemModel {
  final int? id;
  final int userId;
  final int serviceId;
  final String serviceName;
  final int quantity;
  final String size;
  final String? filePath;
  final int unitPrice;
  final int totalPrice;

  CartItemModel({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    this.size = '',
    this.filePath,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'quantity': quantity,
        'size': size,
        'filePath': filePath,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
      };

  factory CartItemModel.fromMap(Map<String, dynamic> map) => CartItemModel(
        id: map['id'],
        userId: map['userId'] ?? 0,
        serviceId: map['serviceId'] ?? 0,
        serviceName: map['serviceName'] ?? '',
        quantity: map['quantity'] ?? 1,
        size: map['size'] ?? '',
        filePath: map['filePath'],
        unitPrice: map['unitPrice'] ?? 0,
        totalPrice: map['totalPrice'] ?? 0,
      );
}

class OrderModel {
  final String orderId;
  final int userId;
  final int branchId;
  final String branchName;
  final String status; // Pending, Sedang Dicetak, Siap Diambil
  final int totalPrice;
  final String createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.branchId,
    this.branchName = '',
    this.status = 'Pending',
    required this.totalPrice,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'orderId': orderId,
        'userId': userId,
        'branchId': branchId,
        'branchName': branchName,
        'status': status,
        'totalPrice': totalPrice,
        'createdAt': createdAt,
      };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
        orderId: map['orderId'] ?? '',
        userId: map['userId'] ?? 0,
        branchId: map['branchId'] ?? 0,
        branchName: map['branchName'] ?? '',
        status: map['status'] ?? 'Pending',
        totalPrice: map['totalPrice'] ?? 0,
        createdAt: map['createdAt'] ?? '',
      );
}

class OrderItemModel {
  final int? id;
  final String orderId;
  final int serviceId;
  final String serviceName;
  final int quantity;
  final String size;
  final String? filePath;
  final int price;

  OrderItemModel({
    this.id,
    required this.orderId,
    required this.serviceId,
    required this.serviceName,
    required this.quantity,
    this.size = '',
    this.filePath,
    required this.price,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'orderId': orderId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'quantity': quantity,
        'size': size,
        'filePath': filePath,
        'price': price,
      };

  factory OrderItemModel.fromMap(Map<String, dynamic> map) => OrderItemModel(
        id: map['id'],
        orderId: map['orderId'] ?? '',
        serviceId: map['serviceId'] ?? 0,
        serviceName: map['serviceName'] ?? '',
        quantity: map['quantity'] ?? 1,
        size: map['size'] ?? '',
        filePath: map['filePath'],
        price: map['price'] ?? 0,
      );
}

class NotificationModel {
  final int? id;
  final int userId;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'title': title,
        'message': message,
        'createdAt': createdAt,
        'isRead': isRead ? 1 : 0,
      };

  factory NotificationModel.fromMap(Map<String, dynamic> map) =>
      NotificationModel(
        id: map['id'],
        userId: map['userId'] ?? 0,
        title: map['title'] ?? '',
        message: map['message'] ?? '',
        createdAt: map['createdAt'] ?? '',
        isRead: (map['isRead'] ?? 0) == 1,
      );
}

/// Helper class: menyimpan session user yang sedang login
class SessionManager {
  static int? currentUserId;
  static String? currentUserName;
  static String? currentUserEmail;

  static void login(UserModel user) {
    currentUserId = user.id;
    currentUserName = user.name;
    currentUserEmail = user.email;
  }

  static void logout() {
    currentUserId = null;
    currentUserName = null;
    currentUserEmail = null;
  }

  static bool get isLoggedIn => currentUserId != null;
}
