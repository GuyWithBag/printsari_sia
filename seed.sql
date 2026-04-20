-- =============================================
-- MOCK DATA FOR PRINTSARI SIA
-- 2 owners, 3 cashiers
-- =============================================

-- =============================================
-- 1. AUTH USERS & PROFILES
-- =============================================
DO $$
DECLARE
  owner1_uid   uuid := '00000000-0000-0000-0000-000000000001';
  owner2_uid   uuid := '00000000-0000-0000-0000-000000000002';
  cashier1_uid uuid := '00000000-0000-0000-0000-000000000003';
  cashier2_uid uuid := '00000000-0000-0000-0000-000000000004';
  cashier3_uid uuid := '00000000-0000-0000-0000-000000000005';
  owner_role_id   int8;
  cashier_role_id int8;
BEGIN
  SELECT id INTO owner_role_id   FROM user_roles WHERE role_name = 'owner';
  SELECT id INTO cashier_role_id FROM user_roles WHERE role_name = 'cashier';

  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data, is_super_admin,
    confirmation_token, recovery_token, email_change, email_change_token_new
  ) VALUES
    ('00000000-0000-0000-0000-000000000000', owner1_uid,   'authenticated', 'authenticated', 'owner1@printsari.com',   crypt('owner123',   gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', owner2_uid,   'authenticated', 'authenticated', 'owner2@printsari.com',   crypt('owner123',   gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', cashier1_uid, 'authenticated', 'authenticated', 'cashier1@printsari.com', crypt('cashier123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', cashier2_uid, 'authenticated', 'authenticated', 'cashier2@printsari.com', crypt('cashier123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', ''),
    ('00000000-0000-0000-0000-000000000000', cashier3_uid, 'authenticated', 'authenticated', 'cashier3@printsari.com', crypt('cashier123', gen_salt('bf')), NOW(), NOW(), NOW(), '{"provider":"email","providers":["email"]}', '{}', false, '', '', '', '');

  INSERT INTO auth.identities (id, user_id, provider_id, identity_data, provider, created_at, updated_at, last_sign_in_at)
  VALUES
    (gen_random_uuid(), owner1_uid,   'owner1@printsari.com',   jsonb_build_object('sub', owner1_uid::text,   'email', 'owner1@printsari.com'),   'email', NOW(), NOW(), NOW()),
    (gen_random_uuid(), owner2_uid,   'owner2@printsari.com',   jsonb_build_object('sub', owner2_uid::text,   'email', 'owner2@printsari.com'),   'email', NOW(), NOW(), NOW()),
    (gen_random_uuid(), cashier1_uid, 'cashier1@printsari.com', jsonb_build_object('sub', cashier1_uid::text, 'email', 'cashier1@printsari.com'), 'email', NOW(), NOW(), NOW()),
    (gen_random_uuid(), cashier2_uid, 'cashier2@printsari.com', jsonb_build_object('sub', cashier2_uid::text, 'email', 'cashier2@printsari.com'), 'email', NOW(), NOW(), NOW()),
    (gen_random_uuid(), cashier3_uid, 'cashier3@printsari.com', jsonb_build_object('sub', cashier3_uid::text, 'email', 'cashier3@printsari.com'), 'email', NOW(), NOW(), NOW());

  INSERT INTO profiles (user_id, username, role_id, name, phone, address_city, address_province, address_country)
  VALUES
    (owner1_uid,   'daniel_owner',  owner_role_id,   'Daniel David Lupase', '09171111001', 'Lipa', 'Batangas', 'Philippines'),
    (owner2_uid,   'jose_owner',    owner_role_id,   'Jose Reyes',          '09171111002', 'Lipa', 'Batangas', 'Philippines'),
    (cashier1_uid, 'maria_cashier', cashier_role_id, 'Maria Santos',        '09171111003', 'Lipa', 'Batangas', 'Philippines'),
    (cashier2_uid, 'pedro_cashier', cashier_role_id, 'Pedro Garcia',        '09171111004', 'Lipa', 'Batangas', 'Philippines'),
    (cashier3_uid, 'ana_cashier',   cashier_role_id, 'Ana Cruz',            '09171111005', 'Lipa', 'Batangas', 'Philippines');
END $$;

-- =============================================
-- 2. PRODUCTS (store category = 1)
-- =============================================
INSERT INTO products (name, description, category_id, purchase_price, sku) VALUES
  ('Yellow Pad Short',     'Short bond yellow pad paper',   1, 18.00, 'SKU-001'),
  ('Ballpen Black',        'Black ballpoint pen',           1,  4.00, 'SKU-002'),
  ('Correction Tape',      'White correction tape roller',  1, 11.00, 'SKU-003'),
  ('Pandesal (pack 12)',   'Fresh baked bread pack of 12',  1, 25.00, 'SKU-004'),
  ('Coffee 3-in-1 sachet', 'Instant 3-in-1 coffee sachet', 1,  4.00, 'SKU-005'),
  ('Mug (ceramic white)',  'Plain white ceramic mug',       1, 60.00, 'SKU-006');

-- =============================================
-- 3. PRINT SERVICES
-- paper_size_id: 1=short, 2=long, 3=a4
-- color_mode_id: 1=bw, 2=colored
-- =============================================
INSERT INTO print_services (name, description, paper_size_id, color_mode_id, base_price, ink_cost_per_page, paper_cost_per_page, electricity_cost_per_page, maintenance_cost_per_page, total_cost_per_page) VALUES
  ('Photocopy B&W Short', 'Black and white photocopy on short bond', 1, 1,  3.00, 0.20, 0.10, 0.02, 0.01, 0.33),
  ('Print B&W A4',        'Black and white print on A4 bond',        3, 1,  3.00, 0.20, 0.10, 0.02, 0.01, 0.33),
  ('Print Colored A4',    'Full color print on A4 bond',             3, 2, 10.00, 1.50, 0.15, 0.05, 0.05, 1.75),
  ('Print Photo 4R',      'Photo print on 4R glossy paper',          3, 2, 20.00, 3.00, 1.00, 0.10, 0.10, 4.20),
  ('Photocopy B&W Long',  'Black and white photocopy on long bond',  2, 1,  4.00, 0.20, 0.15, 0.02, 0.01, 0.38);

-- =============================================
-- 4. CUSTOMERS
-- =============================================
INSERT INTO customers (name, email, phone, address, notes) VALUES
  ('Juan Dela Cruz', 'juan@email.com',       '09181112222', 'Brgy. San Jose, Lipa, Batangas',    'Regular customer'),
  ('Ana Reyes',      'ana.reyes@email.com',  '09193334444', 'Brgy. Tambo, Lipa, Batangas',       'Student - bulk printing'),
  ('Pedro Garcia',   'pedro.g@email.com',    '09205556666', 'Brgy. Marawoy, Lipa, Batangas',     NULL),
  ('Rosa Mendoza',   'rosa.m@email.com',     '09217778888', 'Brgy. Dagatan, Lipa, Batangas',     'Sari-sari store owner nearby'),
  ('Carlos Tan',     'carlos.t@email.com',   '09229990000', 'Brgy. Balintawak, Lipa, Batangas',  'Office supplies buyer');

-- =============================================
-- 5. ACTIVITY ACTIONS (additional seed entries)
-- =============================================
INSERT INTO activity_actions (action_name, category) VALUES
  ('Transaction Completed', 'transaction'),
  ('Transaction Voided',    'transaction'),
  ('Inventory Restocked',   'inventory'),
  ('Inventory Adjusted',    'inventory'),
  ('User Login',            'user'),
  ('User Created',          'user'),
  ('Expense Recorded',      'expense'),
  ('Customer Registered',   'customer'),
  ('Print Order Created',   'print_service')
ON CONFLICT DO NOTHING;

-- =============================================
-- 6. INVENTORY, PRINT ORDERS, TRANSACTIONS,
--    TRANSACTION ITEMS, EXPENSES, ACTIVITY LOGS
-- =============================================
DO $$
DECLARE
  -- Product IDs
  p_ypad int8; p_pen  int8; p_tape int8;
  p_pan  int8; p_cof  int8; p_mug  int8;
  -- Inventory IDs
  inv_ypad int8; inv_pen  int8; inv_tape int8;
  inv_pan  int8; inv_cof  int8; inv_mug  int8;
  -- Print service IDs
  ps_bw_short int8; ps_bw_a4 int8; ps_col_a4 int8; ps_photo int8;
  -- Print order IDs
  po1 int8; po2 int8; po3 int8; po4 int8; po5 int8;
  -- Cashier profile ID
  cashier_pid int8;
  -- Transaction IDs
  txn1  int8; txn2  int8; txn3  int8; txn4  int8;
  txn5  int8; txn6  int8; txn7  int8; txn8  int8;
  txn9  int8; txn10 int8; txn11 int8;
  -- Customer IDs
  cust1 int8; cust2 int8; cust3 int8; cust4 int8; cust5 int8;
  -- Lookup IDs
  status_completed  int8;
  pay_cash int8; pay_gcash int8; pay_card int8;
BEGIN
  -- Resolve lookup IDs
  SELECT id INTO status_completed FROM transaction_statuses WHERE status_name = 'completed';
  SELECT id INTO pay_cash         FROM payment_methods WHERE method_name = 'cash';
  SELECT id INTO pay_gcash        FROM payment_methods WHERE method_name = 'gcash';
  SELECT id INTO pay_card         FROM payment_methods WHERE method_name = 'card';

  -- Resolve product IDs
  SELECT id INTO p_ypad FROM products WHERE sku = 'SKU-001';
  SELECT id INTO p_pen  FROM products WHERE sku = 'SKU-002';
  SELECT id INTO p_tape FROM products WHERE sku = 'SKU-003';
  SELECT id INTO p_pan  FROM products WHERE sku = 'SKU-004';
  SELECT id INTO p_cof  FROM products WHERE sku = 'SKU-005';
  SELECT id INTO p_mug  FROM products WHERE sku = 'SKU-006';

  -- Resolve print service IDs
  SELECT id INTO ps_bw_short FROM print_services WHERE name = 'Photocopy B&W Short';
  SELECT id INTO ps_bw_a4    FROM print_services WHERE name = 'Print B&W A4';
  SELECT id INTO ps_col_a4   FROM print_services WHERE name = 'Print Colored A4';
  SELECT id INTO ps_photo    FROM print_services WHERE name = 'Print Photo 4R';

  -- Resolve cashier profile ID
  SELECT id INTO cashier_pid FROM profiles WHERE username = 'maria_cashier';

  -- Resolve customer IDs
  SELECT id INTO cust1 FROM customers WHERE email = 'juan@email.com';
  SELECT id INTO cust2 FROM customers WHERE email = 'ana.reyes@email.com';
  SELECT id INTO cust3 FROM customers WHERE email = 'pedro.g@email.com';
  SELECT id INTO cust4 FROM customers WHERE email = 'rosa.m@email.com';
  SELECT id INTO cust5 FROM customers WHERE email = 'carlos.t@email.com';

  -- Inventory items
  INSERT INTO inventory_items (product_id, stock, retail_price, reorder_level, location, last_restocked) VALUES
    (p_ypad, 48,  35.00,  10, 'Shelf A1', NOW() - INTERVAL '3 days'),
    (p_pen,  120, 12.00,  20, 'Shelf A2', NOW() - INTERVAL '1 day'),
    (p_tape, 35,  25.00,  10, 'Shelf A3', NOW() - INTERVAL '5 days'),
    (p_pan,  200, 45.00,  30, 'Shelf B1', NOW() - INTERVAL '2 days'),
    (p_cof,  75,   8.00,  15, 'Shelf B2', NOW() - INTERVAL '4 days'),
    (p_mug,  5,  120.00,  10, 'Shelf C1', NOW() - INTERVAL '10 days');

  SELECT id INTO inv_ypad FROM inventory_items WHERE product_id = p_ypad;
  SELECT id INTO inv_pen  FROM inventory_items WHERE product_id = p_pen;
  SELECT id INTO inv_tape FROM inventory_items WHERE product_id = p_tape;
  SELECT id INTO inv_pan  FROM inventory_items WHERE product_id = p_pan;
  SELECT id INTO inv_cof  FROM inventory_items WHERE product_id = p_cof;
  SELECT id INTO inv_mug  FROM inventory_items WHERE product_id = p_mug;

  -- Print orders
  INSERT INTO print_orders (service_id, quantity, double_sided, copies, total_price, ink_used, paper_used, electricity_used, total_cost, profit_margin) VALUES
    (ps_bw_short, 10, false, 1,  50.00,  3.00,  2.00, 0.50,  5.50,  44.50),
    (ps_bw_short, 25, false, 2, 125.00,  7.50,  5.00, 1.25, 13.75, 111.25),
    (ps_col_a4,    5, false, 1,  75.00,  5.00,  2.50, 0.50,  8.00,  67.00),
    (ps_bw_a4,    50, false, 1, 200.00, 15.00, 10.00, 2.50, 27.50, 172.50),
    (ps_photo,     3, false, 1,  90.00,  8.00,  6.00, 1.00, 15.00,  75.00);

  SELECT id INTO po1 FROM print_orders WHERE service_id = ps_bw_short AND quantity = 10 LIMIT 1;
  SELECT id INTO po2 FROM print_orders WHERE service_id = ps_bw_short AND quantity = 25 LIMIT 1;
  SELECT id INTO po3 FROM print_orders WHERE service_id = ps_col_a4   AND quantity = 5  LIMIT 1;
  SELECT id INTO po4 FROM print_orders WHERE service_id = ps_bw_a4    AND quantity = 50 LIMIT 1;
  SELECT id INTO po5 FROM print_orders WHERE service_id = ps_photo     AND quantity = 3  LIMIT 1;

  -- Transactions
  INSERT INTO transactions (transaction_number, subtotal, total, date, status_id, payment_method_id, cashier_id, customer_id, notes, store_revenue, printing_revenue, total_cost, gross_profit) VALUES
    ('TXN-' || TO_CHAR(NOW(),                          'YYYYMMDD') || '-001', 223.00, 223.00, NOW() - INTERVAL '2 hours',        status_completed, pay_cash,  cashier_pid, cust1, 'Morning sale',      223.00,   0.00, 108.00, 115.00),
    ('TXN-' || TO_CHAR(NOW(),                          'YYYYMMDD') || '-002', 125.00, 125.00, NOW() - INTERVAL '1 hour',         status_completed, pay_gcash, cashier_pid, cust2, 'Student printing',    0.00, 125.00,  13.75, 111.25),
    ('TXN-' || TO_CHAR(NOW(),                          'YYYYMMDD') || '-003',  79.00,  79.00, NOW() - INTERVAL '30 minutes',     status_completed, pay_cash,  cashier_pid, NULL,  NULL,                 79.00,   0.00,  40.00,  39.00),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '1 day',       'YYYYMMDD') || '-001', 347.00, 347.00, NOW() - INTERVAL '1 day 6 hours',  status_completed, pay_cash,  cashier_pid, cust4, 'Bulk purchase',     272.00,  75.00, 148.00, 199.00),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '1 day',       'YYYYMMDD') || '-002',  56.00,  56.00, NOW() - INTERVAL '1 day 3 hours',  status_completed, pay_cash,  cashier_pid, NULL,  NULL,                 56.00,   0.00,  28.00,  28.00),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '1 day',       'YYYYMMDD') || '-003', 200.00, 200.00, NOW() - INTERVAL '1 day 1 hour',   status_completed, pay_gcash, cashier_pid, cust5, 'Office printing',    0.00, 200.00,  27.50, 172.50),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '2 days',      'YYYYMMDD') || '-001', 155.00, 155.00, NOW() - INTERVAL '2 days 5 hours', status_completed, pay_cash,  cashier_pid, cust3, NULL,                155.00,   0.00,  80.00,  75.00),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '2 days',      'YYYYMMDD') || '-002', 258.00, 258.00, NOW() - INTERVAL '2 days 2 hours', status_completed, pay_card,  cashier_pid, NULL,  'Card payment',      208.00,  50.00, 115.50, 142.50),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '3 days',      'YYYYMMDD') || '-001',  91.00,  91.00, NOW() - INTERVAL '3 days 4 hours', status_completed, pay_cash,  cashier_pid, NULL,  NULL,                 91.00,   0.00,  48.00,  43.00),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '3 days',      'YYYYMMDD') || '-002', 441.00, 441.00, NOW() - INTERVAL '3 days 2 hours', status_completed, pay_cash,  cashier_pid, cust2, 'Large print job',   141.00, 300.00,  72.00, 369.00),
    ('TXN-' || TO_CHAR(NOW() - INTERVAL '5 days',      'YYYYMMDD') || '-001', 332.00, 332.00, NOW() - INTERVAL '5 days 3 hours', status_completed, pay_gcash, cashier_pid, cust4, 'GCash payment',     332.00,   0.00, 168.00, 164.00);

  SELECT id INTO txn1  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW(),                     'YYYYMMDD') || '-001';
  SELECT id INTO txn2  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW(),                     'YYYYMMDD') || '-002';
  SELECT id INTO txn3  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW(),                     'YYYYMMDD') || '-003';
  SELECT id INTO txn4  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '1 day',  'YYYYMMDD') || '-001';
  SELECT id INTO txn5  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '1 day',  'YYYYMMDD') || '-002';
  SELECT id INTO txn6  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '1 day',  'YYYYMMDD') || '-003';
  SELECT id INTO txn7  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '2 days', 'YYYYMMDD') || '-001';
  SELECT id INTO txn8  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '2 days', 'YYYYMMDD') || '-002';
  SELECT id INTO txn9  FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '3 days', 'YYYYMMDD') || '-001';
  SELECT id INTO txn10 FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '3 days', 'YYYYMMDD') || '-002';
  SELECT id INTO txn11 FROM transactions WHERE transaction_number = 'TXN-' || TO_CHAR(NOW() - INTERVAL '5 days', 'YYYYMMDD') || '-001';

  -- Transaction items
  -- TXN-001 today: store items (₱223)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn1, inv_pan,  p_pan,  'Pandesal (pack 12)',    2, 45.00, 90.00, 1, 50.00),
    (txn1, inv_cof,  p_cof,  'Coffee 3-in-1 sachet',  5,  8.00, 40.00, 1, 20.00),
    (txn1, inv_ypad, p_ypad, 'Yellow Pad Short',       1, 35.00, 35.00, 1, 18.00),
    (txn1, inv_pen,  p_pen,  'Ballpen Black',          3, 12.00, 36.00, 1, 12.00),
    (txn1, inv_tape, p_tape, 'Correction Tape',        1, 22.00, 22.00, 1,  8.00);

  -- TXN-002 today: print job (₱125)
  INSERT INTO transaction_items (transaction_id, product_id, product_name, quantity, unit_price, subtotal, category_id, print_order_id, item_cost) VALUES
    (txn2, p_ypad, 'Photocopy B&W Short - 25 pages', 1, 125.00, 125.00, 2, po2, 13.75);

  -- TXN-003 today: small store (₱79)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn3, inv_pan,  p_pan,  'Pandesal (pack 12)', 1, 45.00, 45.00, 1, 25.00),
    (txn3, inv_pen,  p_pen,  'Ballpen Black',       1, 12.00, 12.00, 1,  4.00),
    (txn3, inv_tape, p_tape, 'Correction Tape',     1, 22.00, 22.00, 1, 11.00);

  -- TXN-004 yesterday: mixed (₱347 = ₱272 store + ₱75 print)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn4, inv_pan,  p_pan,  'Pandesal (pack 12)',   3, 45.00, 135.00, 1, 72.00),
    (txn4, inv_cof,  p_cof,  'Coffee 3-in-1 sachet', 8,  8.00,  64.00, 1, 32.00),
    (txn4, inv_ypad, p_ypad, 'Yellow Pad Short',      1, 35.00,  35.00, 1, 18.00),
    (txn4, inv_pen,  p_pen,  'Ballpen Black',         2, 12.00,  24.00, 1,  8.00),
    (txn4, inv_tape, p_tape, 'Correction Tape',       1, 14.00,  14.00, 1,  6.00);
  INSERT INTO transaction_items (transaction_id, product_id, product_name, quantity, unit_price, subtotal, category_id, print_order_id, item_cost) VALUES
    (txn4, p_ypad, 'Print Colored A4 - 5 pages', 1, 75.00, 75.00, 2, po3, 8.00);

  -- TXN-005 yesterday: store only (₱56)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn5, inv_cof, p_cof, 'Coffee 3-in-1 sachet', 5, 8.00, 40.00, 1, 20.00),
    (txn5, inv_pen, p_pen, 'Ballpen Black',         2, 8.00, 16.00, 1,  8.00);

  -- TXN-006 yesterday: large print (₱200)
  INSERT INTO transaction_items (transaction_id, product_id, product_name, quantity, unit_price, subtotal, category_id, print_order_id, item_cost) VALUES
    (txn6, p_ypad, 'Print B&W A4 - 50 pages', 1, 200.00, 200.00, 2, po4, 27.50);

  -- TXN-007 2 days ago: store only (₱155)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn7, inv_ypad, p_ypad, 'Yellow Pad Short', 2, 35.00, 70.00, 1, 36.00),
    (txn7, inv_tape, p_tape, 'Correction Tape',  2, 25.00, 50.00, 1, 20.00),
    (txn7, inv_ypad, p_ypad, 'Yellow Pad Short', 1, 35.00, 35.00, 1, 24.00);

  -- TXN-008 2 days ago: mixed (₱258 = ₱208 store + ₱50 print)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn8, inv_pan, p_pan, 'Pandesal (pack 12)',   2, 45.00, 90.00, 1, 50.00),
    (txn8, inv_cof, p_cof, 'Coffee 3-in-1 sachet', 6,  8.00, 48.00, 1, 24.00),
    (txn8, inv_mug, p_mug, 'Mug (ceramic white)',  1, 70.00, 70.00, 1, 36.00);
  INSERT INTO transaction_items (transaction_id, product_id, product_name, quantity, unit_price, subtotal, category_id, print_order_id, item_cost) VALUES
    (txn8, p_ypad, 'Photocopy B&W Short - 10 pages', 1, 50.00, 50.00, 2, po1, 5.50);

  -- TXN-009 3 days ago: small store (₱91)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn9, inv_pan,  p_pan,  'Pandesal (pack 12)',   1, 45.00, 45.00, 1, 25.00),
    (txn9, inv_cof,  p_cof,  'Coffee 3-in-1 sachet', 3,  8.00, 24.00, 1, 12.00),
    (txn9, inv_tape, p_tape, 'Correction Tape',       1, 22.00, 22.00, 1, 11.00);

  -- TXN-010 3 days ago: large mixed (₱441 = ₱141 store + ₱300 print)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn10, inv_ypad, p_ypad, 'Yellow Pad Short', 2, 35.00, 70.00, 1, 36.00),
    (txn10, inv_pen,  p_pen,  'Ballpen Black',    3, 12.00, 36.00, 1, 12.00),
    (txn10, inv_ypad, p_ypad, 'Yellow Pad Short', 1, 35.00, 35.00, 1, 14.00);
  INSERT INTO transaction_items (transaction_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn10, p_ypad, 'Bulk printing - thesis', 1, 300.00, 300.00, 2, 55.00);

  -- TXN-011 5 days ago: store bulk (₱332)
  INSERT INTO transaction_items (transaction_id, inventory_id, product_id, product_name, quantity, unit_price, subtotal, category_id, item_cost) VALUES
    (txn11, inv_pan,  p_pan,  'Pandesal (pack 12)',    4, 45.00, 180.00, 1, 96.00),
    (txn11, inv_cof,  p_cof,  'Coffee 3-in-1 sachet', 10,  8.00,  80.00, 1, 40.00),
    (txn11, inv_ypad, p_ypad, 'Yellow Pad Short',       1, 35.00,  35.00, 1, 18.00),
    (txn11, inv_pen,  p_pen,  'Ballpen Black',          3, 12.00,  37.00, 1, 14.00);

  -- =============================================
  -- Expenses
  -- expense_categories: 1=printing_ink, 2=printing_paper, 3=printing_electricity,
  --   4=printing_maintenance, 5=store_inventory, 6=utilities, 7=rent, 8=salaries, 9=supplies, 10=other
  -- =============================================
  INSERT INTO expenses (description, amount, category_id, date, source_id, vendor, payment_method_id, notes) VALUES
    ('Monthly rent payment',                  8000.00, (SELECT id FROM expense_categories WHERE category_name = 'rent'),             NOW() - INTERVAL '5 days', 1, 'Landlord',           pay_cash,  'March 2026 rent'),
    ('Electricity bill',                      2500.00, (SELECT id FROM expense_categories WHERE category_name = 'utilities'),        NOW() - INTERVAL '4 days', 1, 'Meralco',            pay_cash,  'Feb billing'),
    ('Store supplies restock - food items',   3200.00, (SELECT id FROM expense_categories WHERE category_name = 'store_inventory'),  NOW() - INTERVAL '3 days', 1, 'Metro Wholesale',    pay_cash,  NULL),
    ('Store supplies restock - school items', 2800.00, (SELECT id FROM expense_categories WHERE category_name = 'store_inventory'),  NOW() - INTERVAL '3 days', 1, 'Metro Wholesale',    pay_cash,  NULL),
    ('Printer paper restock - short bond',    1500.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_paper'),   NOW() - INTERVAL '2 days', 1, 'National Bookstore', pay_gcash, '5 reams short bond'),
    ('Printer ink cartridge - black',          800.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_ink'),     NOW() - INTERVAL '2 days', 1, 'National Bookstore', pay_gcash, 'Epson T664 black'),
    ('Water and cleaning supplies',            450.00, (SELECT id FROM expense_categories WHERE category_name = 'supplies'),         NOW() - INTERVAL '1 day',  1, 'Puregold',           pay_cash,  NULL);

  -- Auto-generated print expenses (source_id = 2)
  INSERT INTO expenses (description, amount, category_id, date, source_id, linked_transaction_id) VALUES
    ('Ink cost - Photocopy B&W Short - 25 pages',          7.50, (SELECT id FROM expense_categories WHERE category_name = 'printing_ink'),          NOW() - INTERVAL '1 hour', 2, txn2),
    ('Paper cost - Photocopy B&W Short - 25 pages',        5.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_paper'),        NOW() - INTERVAL '1 hour', 2, txn2),
    ('Electricity cost - Photocopy B&W Short - 25 pages',  1.25, (SELECT id FROM expense_categories WHERE category_name = 'printing_electricity'),  NOW() - INTERVAL '1 hour', 2, txn2),
    ('Maintenance cost - Photocopy B&W Short - 25 pages',  0.50, (SELECT id FROM expense_categories WHERE category_name = 'printing_maintenance'),  NOW() - INTERVAL '1 hour', 2, txn2);

  INSERT INTO expenses (description, amount, category_id, date, source_id, linked_transaction_id) VALUES
    ('Ink cost - Print B&W A4 - 50 pages',          15.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_ink'),         NOW() - INTERVAL '1 day 1 hour', 2, txn6),
    ('Paper cost - Print B&W A4 - 50 pages',        10.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_paper'),       NOW() - INTERVAL '1 day 1 hour', 2, txn6),
    ('Electricity cost - Print B&W A4 - 50 pages',   2.50, (SELECT id FROM expense_categories WHERE category_name = 'printing_electricity'), NOW() - INTERVAL '1 day 1 hour', 2, txn6),
    ('Maintenance cost - Print B&W A4 - 50 pages',   1.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_maintenance'), NOW() - INTERVAL '1 day 1 hour', 2, txn6);

  INSERT INTO expenses (description, amount, category_id, date, source_id, linked_transaction_id) VALUES
    ('Ink cost - Photocopy B&W Short - 10 pages',          3.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_ink'),         NOW() - INTERVAL '2 days 2 hours', 2, txn8),
    ('Paper cost - Photocopy B&W Short - 10 pages',        2.00, (SELECT id FROM expense_categories WHERE category_name = 'printing_paper'),       NOW() - INTERVAL '2 days 2 hours', 2, txn8),
    ('Electricity cost - Photocopy B&W Short - 10 pages',  0.50, (SELECT id FROM expense_categories WHERE category_name = 'printing_electricity'), NOW() - INTERVAL '2 days 2 hours', 2, txn8),
    ('Maintenance cost - Photocopy B&W Short - 10 pages',  0.25, (SELECT id FROM expense_categories WHERE category_name = 'printing_maintenance'), NOW() - INTERVAL '2 days 2 hours', 2, txn8);

  -- Activity logs
  INSERT INTO activity_logs (action_id, description, timestamp, performed_by, performed_by_id) VALUES
    ((SELECT id FROM activity_actions WHERE action_name = 'Transaction Completed' LIMIT 1), 'Completed sale — ₱79.00',                   NOW() - INTERVAL '30 minutes',       'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Transaction Completed' LIMIT 1), 'Completed sale — ₱125.00 (printing)',        NOW() - INTERVAL '1 hour',           'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Print Order Created'   LIMIT 1), 'Print order: Photocopy B&W Short 25 pages',  NOW() - INTERVAL '1 hour 5 minutes', 'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Transaction Completed' LIMIT 1), 'Completed sale — ₱223.00',                   NOW() - INTERVAL '2 hours',          'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Inventory Restocked'   LIMIT 1), 'Restocked Ballpen Black: +30 units',          NOW() - INTERVAL '3 hours',          'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Expense Recorded'      LIMIT 1), 'Recorded expense: Water and cleaning — ₱450', NOW() - INTERVAL '1 day',            'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Transaction Completed' LIMIT 1), 'Completed sale — ₱200.00 (printing)',         NOW() - INTERVAL '1 day 1 hour',     'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Transaction Completed' LIMIT 1), 'Completed sale — ₱347.00',                   NOW() - INTERVAL '1 day 6 hours',    'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Product Added'         LIMIT 1), 'Added new product: Skyflakes Crackers',        NOW() - INTERVAL '2 days',           'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Inventory Restocked'   LIMIT 1), 'Restocked Coffee 3-in-1: +50 units',          NOW() - INTERVAL '2 days 1 hour',    'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Customer Registered'   LIMIT 1), 'New customer: Carlos Tan',                    NOW() - INTERVAL '3 days',           'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'Expense Recorded'      LIMIT 1), 'Recorded expense: Printer paper — ₱1,500',    NOW() - INTERVAL '3 days',           'Maria Santos', cashier_pid),
    ((SELECT id FROM activity_actions WHERE action_name = 'User Login'            LIMIT 1), 'User logged in',                              NOW() - INTERVAL '4 days',           'Maria Santos', cashier_pid);

END $$;
