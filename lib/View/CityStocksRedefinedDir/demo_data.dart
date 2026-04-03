import 'package:quick_ecommerce_city_panel_redefined/View/CityStocksRedefinedDir/models.dart';

// ─────────────────────────────────────────────
//  DEMO DATA
// ─────────────────────────────────────────────

final List<MainCategory> demoMainCategories = [
  MainCategory(id: 'mc1', name: 'Beverages', emoji: '🥤', bgColorHex: 'E0F2FE'),
  MainCategory(id: 'mc2', name: 'Snacks & Food', emoji: '🍿', bgColorHex: 'FEF9C3'),
  MainCategory(id: 'mc3', name: 'Dairy', emoji: '🥛', bgColorHex: 'FCE7F3'),
  MainCategory(id: 'mc4', name: 'Personal Care', emoji: '🧴', bgColorHex: 'F3E8FF'),
  MainCategory(id: 'mc5', name: 'Household', emoji: '🏠', bgColorHex: 'E0FFF4'),
];

final List<Category> demoCategories = [
  // Beverages
  Category(id: 'c1', name: 'Cold Drinks', emoji: '🫙', mainCategoryId: 'mc1', colorHex: 'DBEAFE'),
  Category(id: 'c2', name: 'Juices', emoji: '🍊', mainCategoryId: 'mc1', colorHex: 'FEF3C7'),
  Category(id: 'c3', name: 'Water & Energy', emoji: '💧', mainCategoryId: 'mc1', colorHex: 'CFFAFE'),
  // Snacks
  Category(id: 'c4', name: 'Chips & Crisps', emoji: '🍟', mainCategoryId: 'mc2', colorHex: 'FEF9C3'),
  Category(id: 'c5', name: 'Biscuits', emoji: '🍪', mainCategoryId: 'mc2', colorHex: 'FEE2E2'),
  Category(id: 'c6', name: 'Namkeen', emoji: '🌶️', mainCategoryId: 'mc2', colorHex: 'FFE4E6'),
  // Dairy
  Category(id: 'c7', name: 'Milk Products', emoji: '🥛', mainCategoryId: 'mc3', colorHex: 'F0FDF4'),
  Category(id: 'c8', name: 'Cheese & Butter', emoji: '🧈', mainCategoryId: 'mc3', colorHex: 'FFF7ED'),
  // Personal Care
  Category(id: 'c9', name: 'Shampoo & Soap', emoji: '🧼', mainCategoryId: 'mc4', colorHex: 'EDE9FE'),
  // Household
  Category(id: 'c10', name: 'Cleaning', emoji: '🧹', mainCategoryId: 'mc5', colorHex: 'F0FDF4'),
];

final List<SubCategory> demoSubCategories = [
  SubCategory(id: 's1', name: 'Pepsi Products', emoji: '🫙', categoryId: 'c1'),
  SubCategory(id: 's2', name: 'Coca-Cola Products', emoji: '🥤', categoryId: 'c1'),
  SubCategory(id: 's3', name: 'Sprite & Others', emoji: '💚', categoryId: 'c1'),
  SubCategory(id: 's4', name: 'Mango Juices', emoji: '🥭', categoryId: 'c2'),
  SubCategory(id: 's5', name: 'Mixed Fruit', emoji: '🍹', categoryId: 'c2'),
  SubCategory(id: 's6', name: 'Packaged Water', emoji: '💧', categoryId: 'c3'),
  SubCategory(id: 's7', name: "Lay's", emoji: '🍟', categoryId: 'c4'),
  SubCategory(id: 's8', name: 'Kurkure', emoji: '🌽', categoryId: 'c4'),
  SubCategory(id: 's9', name: 'Parle Products', emoji: '🍪', categoryId: 'c5'),
  SubCategory(id: 's10', name: 'Britannia', emoji: '🫓', categoryId: 'c5'),
  SubCategory(id: 's11', name: 'Amul Milk', emoji: '🥛', categoryId: 'c7'),
  SubCategory(id: 's12', name: 'Amul Dahi', emoji: '🍶', categoryId: 'c7'),
];

final List<Product> demoProducts = [
  // Pepsi
  Product(
    id: 'p1', name: 'Pepsi', sku: 'BEV-PEP-001', subCategoryId: 's1',
    variants: [
      ProductVariant(id: 'v1', label: '200ml', currentStock: 45, minLevel: 80),
      ProductVariant(id: 'v2', label: '500ml', currentStock: 22, minLevel: 60),
      ProductVariant(id: 'v3', label: '1L', currentStock: 8, minLevel: 30),
      ProductVariant(id: 'v4', label: '2L', currentStock: 30, minLevel: 25),
    ],
  ),
  Product(
    id: 'p2', name: 'Pepsi Black', sku: 'BEV-PEP-002', subCategoryId: 's1',
    variants: [
      ProductVariant(id: 'v5', label: '250ml Can', currentStock: 60, minLevel: 50),
      ProductVariant(id: 'v6', label: '500ml', currentStock: 10, minLevel: 40),
    ],
  ),
  Product(
    id: 'p3', name: 'Mountain Dew', sku: 'BEV-PEP-003', subCategoryId: 's1',
    variants: [
      ProductVariant(id: 'v7', label: '200ml', currentStock: 90, minLevel: 60),
      ProductVariant(id: 'v8', label: '600ml', currentStock: 35, minLevel: 30),
    ],
  ),
  // Coca-Cola
  Product(
    id: 'p4', name: 'Coca-Cola', sku: 'BEV-COK-001', subCategoryId: 's2',
    variants: [
      ProductVariant(id: 'v9', label: '200ml', currentStock: 5, minLevel: 80),
      ProductVariant(id: 'v10', label: '500ml', currentStock: 15, minLevel: 60),
      ProductVariant(id: 'v11', label: '1L', currentStock: 30, minLevel: 30),
    ],
  ),
  Product(
    id: 'p5', name: 'Thums Up', sku: 'BEV-COK-002', subCategoryId: 's2',
    variants: [
      ProductVariant(id: 'v12', label: '200ml', currentStock: 120, minLevel: 80),
      ProductVariant(id: 'v13', label: '500ml', currentStock: 70, minLevel: 50),
    ],
  ),
  // Sprite
  Product(
    id: 'p6', name: 'Sprite', sku: 'BEV-SPR-001', subCategoryId: 's3',
    variants: [
      ProductVariant(id: 'v14', label: '200ml', currentStock: 10, minLevel: 60),
      ProductVariant(id: 'v15', label: '500ml', currentStock: 5, minLevel: 40),
      ProductVariant(id: 'v16', label: '1.25L', currentStock: 18, minLevel: 20),
    ],
  ),
  // Juices
  Product(
    id: 'p7', name: 'Real Juice Mango', sku: 'JUI-REA-001', subCategoryId: 's4',
    variants: [
      ProductVariant(id: 'v17', label: '180ml', currentStock: 40, minLevel: 50),
      ProductVariant(id: 'v18', label: '1L', currentStock: 12, minLevel: 25),
    ],
  ),
  Product(
    id: 'p8', name: 'Tropicana Orange', sku: 'JUI-TRO-001', subCategoryId: 's5',
    variants: [
      ProductVariant(id: 'v19', label: '200ml', currentStock: 55, minLevel: 40),
      ProductVariant(id: 'v20', label: '1L', currentStock: 20, minLevel: 25),
    ],
  ),
  // Water
  Product(
    id: 'p9', name: 'Kinley Water', sku: 'WAT-KIN-001', subCategoryId: 's6',
    variants: [
      ProductVariant(id: 'v21', label: '500ml', currentStock: 150, minLevel: 120),
      ProductVariant(id: 'v22', label: '1L', currentStock: 80, minLevel: 60),
      ProductVariant(id: 'v23', label: '2L', currentStock: 40, minLevel: 30),
    ],
  ),
  // Chips
  Product(
    id: 'p10', name: "Lay's Classic Salted", sku: 'SNK-LAY-001', subCategoryId: 's7',
    variants: [
      ProductVariant(id: 'v24', label: '26g', currentStock: 200, minLevel: 150),
      ProductVariant(id: 'v25', label: '52g', currentStock: 80, minLevel: 100),
      ProductVariant(id: 'v26', label: '130g', currentStock: 30, minLevel: 50),
    ],
  ),
  Product(
    id: 'p11', name: "Lay's Magic Masala", sku: 'SNK-LAY-002', subCategoryId: 's7',
    variants: [
      ProductVariant(id: 'v27', label: '26g', currentStock: 180, minLevel: 150),
      ProductVariant(id: 'v28', label: '52g', currentStock: 3, minLevel: 80),
    ],
  ),
  // Kurkure
  Product(
    id: 'p12', name: 'Kurkure Masala Munch', sku: 'SNK-KUR-001', subCategoryId: 's8',
    variants: [
      ProductVariant(id: 'v29', label: '22g', currentStock: 300, minLevel: 200),
      ProductVariant(id: 'v30', label: '90g', currentStock: 60, minLevel: 80),
    ],
  ),
  // Biscuits
  Product(
    id: 'p13', name: 'Parle-G', sku: 'BSC-PAR-001', subCategoryId: 's9',
    variants: [
      ProductVariant(id: 'v31', label: '100g', currentStock: 400, minLevel: 250),
      ProductVariant(id: 'v32', label: '250g', currentStock: 120, minLevel: 100),
    ],
  ),
  Product(
    id: 'p14', name: 'Britannia Good Day', sku: 'BSC-BRI-001', subCategoryId: 's10',
    variants: [
      ProductVariant(id: 'v33', label: '100g', currentStock: 15, minLevel: 80),
      ProductVariant(id: 'v34', label: '250g', currentStock: 8, minLevel: 50),
    ],
  ),
  // Dairy
  Product(
    id: 'p15', name: 'Amul Full Cream Milk', sku: 'DAI-AMU-001', subCategoryId: 's11',
    variants: [
      ProductVariant(id: 'v35', label: '500ml', currentStock: 90, minLevel: 80),
      ProductVariant(id: 'v36', label: '1L', currentStock: 55, minLevel: 60),
    ],
  ),
  Product(
    id: 'p16', name: 'Amul Dahi', sku: 'DAI-AMU-002', subCategoryId: 's12',
    variants: [
      ProductVariant(id: 'v37', label: '200g', currentStock: 25, minLevel: 60),
      ProductVariant(id: 'v38', label: '400g', currentStock: 12, minLevel: 50),
      ProductVariant(id: 'v39', label: '1kg', currentStock: 5, minLevel: 25),
    ],
  ),
];

final List<StockRequest> demoRequests = [
  StockRequest(
    id: 'REQ-2025-001',
    date: DateTime(2025, 3, 28),
    status: RequestStatus.approved,
    priority: RequestPriority.urgent,
    items: [
      RequestItem(name: 'Sprite 200ml', qty: 60),
      RequestItem(name: 'Sprite 500ml', qty: 40),
      RequestItem(name: 'Coca-Cola 200ml', qty: 80),
    ],
    note: 'IPL season — cold drinks running critically low.',
  ),
  StockRequest(
    id: 'REQ-2025-002',
    date: DateTime(2025, 3, 30),
    status: RequestStatus.pending,
    priority: RequestPriority.critical,
    items: [
      RequestItem(name: 'Amul Dahi 200g', qty: 50),
      RequestItem(name: 'Amul Dahi 400g', qty: 40),
      RequestItem(name: 'Amul Dahi 1kg', qty: 20),
    ],
    note: 'Wedding season in area, dahi demand very high.',
  ),
  StockRequest(
    id: 'REQ-2025-003',
    date: DateTime(2025, 4, 1),
    status: RequestStatus.partial,
    priority: RequestPriority.normal,
    items: [
      RequestItem(name: "Lay's Magic Masala 52g", qty: 80),
      RequestItem(name: 'Britannia Good Day 100g', qty: 80),
      RequestItem(name: 'Britannia Good Day 250g', qty: 50),
      RequestItem(name: 'Kurkure 90g', qty: 60),
    ],
    note: '',
  ),
  StockRequest(
    id: 'REQ-2025-004',
    date: DateTime(2025, 4, 2),
    status: RequestStatus.pending,
    priority: RequestPriority.urgent,
    items: [
      RequestItem(name: 'Pepsi 200ml', qty: 100),
      RequestItem(name: 'Pepsi 500ml', qty: 60),
      RequestItem(name: 'Pepsi Black 500ml', qty: 40),
    ],
    note: 'Summer peak — festive weekend approaching.',
  ),
];

final List<IncomingShipment> demoShipments = [
  IncomingShipment(
    id: 'SHP-2025-011',
    requestId: 'REQ-2025-001',
    dispatchDate: DateTime(2025, 3, 29),
    status: ShipmentStatus.arrived,
    items: [
      ShipmentItem(productName: 'Sprite', variantLabel: '200ml', expectedQty: 60),
      ShipmentItem(productName: 'Sprite', variantLabel: '500ml', expectedQty: 40),
      ShipmentItem(productName: 'Coca-Cola', variantLabel: '200ml', expectedQty: 80),
    ],
  ),
  IncomingShipment(
    id: 'SHP-2025-012',
    requestId: 'REQ-2025-003',
    dispatchDate: DateTime(2025, 4, 2),
    status: ShipmentStatus.inTransit,
    items: [
      ShipmentItem(productName: "Lay's Magic Masala", variantLabel: '52g', expectedQty: 80),
      ShipmentItem(productName: 'Britannia Good Day', variantLabel: '100g', expectedQty: 80),
      ShipmentItem(productName: 'Britannia Good Day', variantLabel: '250g', expectedQty: 50),
    ],
  ),
];
