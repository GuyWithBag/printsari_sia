-- ============================================================================
-- DROP EVERYTHING (Clean slate)
-- ============================================================================

-- Drop all tables (cascade will drop dependent objects)
DROP TABLE IF EXISTS financial_reports CASCADE;
DROP TABLE IF EXISTS activity_logs CASCADE;
DROP TABLE IF EXISTS expenses CASCADE;
DROP TABLE IF EXISTS transaction_items CASCADE;
DROP TABLE IF EXISTS print_orders CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS print_services CASCADE;
DROP TABLE IF EXISTS inventory_items CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Drop lookup tables
DROP TABLE IF EXISTS report_periods CASCADE;
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;
DROP TABLE IF EXISTS transaction_statuses CASCADE;
DROP TABLE IF EXISTS product_categories CASCADE;
DROP TABLE IF EXISTS print_finishes CASCADE;
DROP TABLE IF EXISTS print_orientations CASCADE;
DROP TABLE IF EXISTS color_modes CASCADE;
DROP TABLE IF EXISTS paper_sizes CASCADE;
DROP TABLE IF EXISTS expense_sources CASCADE;
DROP TABLE IF EXISTS expense_categories CASCADE;
DROP TABLE IF EXISTS activity_actions CASCADE;

-- Drop metrics tables
DROP TABLE IF EXISTS expenses_by_category CASCADE;
DROP TABLE IF EXISTS department_revenues CASCADE;
DROP TABLE IF EXISTS trend_data_points CASCADE;
DROP TABLE IF EXISTS monthly_metrics CASCADE;
DROP TABLE IF EXISTS weekly_metrics CASCADE;
DROP TABLE IF EXISTS daily_metrics CASCADE;

-- Drop storage policies
DROP POLICY IF EXISTS "Users can upload avatars" ON storage.objects;
DROP POLICY IF EXISTS "Users can update avatars" ON storage.objects;
DROP POLICY IF EXISTS "Public avatar read access" ON storage.objects;

-- Drop functions
DROP FUNCTION IF EXISTS get_email_by_username(text) CASCADE;
DROP FUNCTION IF EXISTS public.is_owner() CASCADE;
DROP FUNCTION IF EXISTS public.get_user_role() CASCADE;
DROP FUNCTION IF EXISTS auth.is_owner() CASCADE;
DROP FUNCTION IF EXISTS auth.user_role() CASCADE;
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;

-- ============================================================================
-- ENUM TABLES (Convert TS enums to lookup tables)
-- ============================================================================

-- Activity actions lookup table
CREATE TABLE activity_actions (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  action_name text NOT NULL UNIQUE,
  category text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO activity_actions (action_name, category) VALUES
  ('transaction_created', 'transaction'),
  ('transaction_cancelled', 'transaction'),
  ('transaction_refunded', 'transaction'),
  ('product_created', 'product'),
  ('product_updated', 'product'),
  ('product_deleted', 'product'),
  ('inventory_added', 'inventory'),
  ('inventory_updated', 'inventory'),
  ('inventory_depleted', 'inventory'),
  ('inventory_expired', 'inventory'),
  ('user_created', 'user'),
  ('user_updated', 'user'),
  ('user_deleted', 'user'),
  ('user_login', 'user'),
  ('user_logout', 'user'),
  ('expense_created', 'expense'),
  ('expense_updated', 'expense'),
  ('expense_deleted', 'expense'),
  ('customer_created', 'customer'),
  ('customer_updated', 'customer'),
  ('customer_deleted', 'customer'),
  ('print_service_created', 'print_service'),
  ('print_service_updated', 'print_service'),
  ('print_service_deleted', 'print_service');

-- Expense categories lookup table
CREATE TABLE expense_categories (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  category_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO expense_categories (category_name) VALUES
  ('printing_ink'),
  ('printing_paper'),
  ('printing_electricity'),
  ('printing_maintenance'),
  ('store_inventory'),
  ('utilities'),
  ('rent'),
  ('salaries'),
  ('supplies'),
  ('other');

-- Expense sources lookup table
CREATE TABLE expense_sources (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  source_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO expense_sources (source_name) VALUES
  ('manual'),
  ('auto_print');

-- Paper sizes lookup table
CREATE TABLE paper_sizes (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  size_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO paper_sizes (size_name) VALUES
  ('short'),
  ('long'),
  ('a4'),
  ('legal'),
  ('letter');

-- Color modes lookup table
CREATE TABLE color_modes (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  mode_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO color_modes (mode_name) VALUES
  ('bw'),
  ('colored'),
  ('grayscale');

-- Print orientations lookup table
CREATE TABLE print_orientations (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  orientation_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO print_orientations (orientation_name) VALUES
  ('portrait'),
  ('landscape');

-- Print finishes lookup table
CREATE TABLE print_finishes (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  finish_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO print_finishes (finish_name) VALUES
  ('none'),
  ('laminated'),
  ('bound');

-- Product categories lookup table
CREATE TABLE product_categories (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  category_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO product_categories (category_name) VALUES
  ('store'),
  ('printing');

-- Transaction statuses lookup table
CREATE TABLE transaction_statuses (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  status_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO transaction_statuses (status_name) VALUES
  ('completed'),
  ('pending'),
  ('cancelled'),
  ('refunded');

-- Payment methods lookup table
CREATE TABLE payment_methods (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  method_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO payment_methods (method_name) VALUES
  ('cash'),
  ('gcash'),
  ('card'),
  ('credit');

-- User roles lookup table
CREATE TABLE user_roles (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  role_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO user_roles (role_name) VALUES
  ('owner'),
  ('cashier');

-- Report periods lookup table
CREATE TABLE report_periods (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  period_name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO report_periods (period_name) VALUES
  ('daily'),
  ('weekly'),
  ('monthly');

-- ============================================================================
-- MAIN TABLES
-- ============================================================================

-- Profiles table (connected to Supabase auth.users)
CREATE TABLE profiles (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  username text NOT NULL UNIQUE,
  role_id int8 NOT NULL REFERENCES user_roles(id),
  name text NOT NULL,
  phone text,
  profile_picture text,
  address_street text,
  address_barangay text,
  address_city text,
  address_province text,
  address_region text,
  address_postal_code text,
  address_country text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Customers table
CREATE TABLE customers (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text,
  email text NOT NULL,
  phone text,
  address text,
  notes text,
  registered_date timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Products table
CREATE TABLE products (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text NOT NULL,
  description text NOT NULL,
  category_id int8 NOT NULL REFERENCES product_categories(id),
  purchase_price numeric(12, 2) NOT NULL,
  sku text,
  barcode text,
  supplier text,
  expiry_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Inventory items table
CREATE TABLE inventory_items (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  product_id int8 NOT NULL UNIQUE REFERENCES products(id) ON DELETE CASCADE,
  stock numeric(12, 2) NOT NULL DEFAULT 0,
  retail_price numeric(12, 2) NOT NULL,
  reorder_level numeric(12, 2),
  location text,
  last_restocked timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Print services table
CREATE TABLE print_services (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text NOT NULL,
  description text NOT NULL,
  paper_size_id int8 NOT NULL REFERENCES paper_sizes(id),
  color_mode_id int8 NOT NULL REFERENCES color_modes(id),
  base_price numeric(12, 2) NOT NULL,
  ink_cost_per_page numeric(12, 2) NOT NULL,
  paper_cost_per_page numeric(12, 2) NOT NULL,
  electricity_cost_per_page numeric(12, 2) NOT NULL,
  maintenance_cost_per_page numeric(12, 2) NOT NULL,
  total_cost_per_page numeric(12, 2) NOT NULL,
  orientation_id int8 REFERENCES print_orientations(id),
  finish_id int8 REFERENCES print_finishes(id),
  paper_stock numeric(12, 2),
  ink_level numeric(5, 2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Transactions table
CREATE TABLE transactions (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  transaction_number text NOT NULL UNIQUE,
  subtotal numeric(12, 2) NOT NULL,
  tax numeric(12, 2),
  discount numeric(12, 2),
  total numeric(12, 2) NOT NULL,
  date timestamptz NOT NULL DEFAULT now(),
  status_id int8 NOT NULL REFERENCES transaction_statuses(id),
  payment_method_id int8 NOT NULL REFERENCES payment_methods(id),
  cashier_id int8 NOT NULL REFERENCES profiles(id),
  customer_id int8 REFERENCES customers(id),
  notes text,
  store_revenue numeric(12, 2) NOT NULL DEFAULT 0,
  printing_revenue numeric(12, 2) NOT NULL DEFAULT 0,
  total_cost numeric(12, 2),
  gross_profit numeric(12, 2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Print orders table
CREATE TABLE print_orders (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  service_id int8 NOT NULL REFERENCES print_services(id),
  quantity int4 NOT NULL,
  double_sided boolean,
  copies int4,
  additional_finish_id int8 REFERENCES print_finishes(id),
  total_price numeric(12, 2) NOT NULL,
  ink_used numeric(12, 2) NOT NULL,
  paper_used numeric(12, 2) NOT NULL,
  electricity_used numeric(12, 4) NOT NULL,
  total_cost numeric(12, 2) NOT NULL,
  profit_margin numeric(12, 2) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Transaction items table
CREATE TABLE transaction_items (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  transaction_id int8 NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
  inventory_id int8 REFERENCES inventory_items(id) ON DELETE SET NULL,
  product_id int8 REFERENCES products(id) ON DELETE SET NULL,
  product_name text NOT NULL,
  quantity numeric(12, 2) NOT NULL,
  unit_price numeric(12, 2) NOT NULL,
  subtotal numeric(12, 2) NOT NULL,
  category_id int8 NOT NULL REFERENCES product_categories(id),
  discount numeric(12, 2),
  print_order_id int8 REFERENCES print_orders(id),
  item_cost numeric(12, 2),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Expenses table
CREATE TABLE expenses (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  description text NOT NULL,
  amount numeric(12, 2) NOT NULL,
  category_id int8 NOT NULL REFERENCES expense_categories(id),
  date timestamptz NOT NULL DEFAULT now(),
  receipt_number text,
  vendor text,
  payment_method_id int8 REFERENCES payment_methods(id),
  notes text,
  linked_transaction_id int8 REFERENCES transactions(id),
  source_id int8 NOT NULL REFERENCES expense_sources(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Activity logs table
CREATE TABLE activity_logs (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  action_id int8 NOT NULL REFERENCES activity_actions(id),
  description text NOT NULL,
  timestamp timestamptz NOT NULL DEFAULT now(),
  performed_by text NOT NULL,
  performed_by_id int8 NOT NULL REFERENCES profiles(id),
  metadata jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Financial reports table
CREATE TABLE financial_reports (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  period_id int8 NOT NULL REFERENCES report_periods(id),
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================================
-- INDEXES
-- ============================================================================

CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_username ON profiles(username);
CREATE INDEX idx_profiles_role_id ON profiles(role_id);

CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_registered_date ON customers(registered_date);

CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);
CREATE INDEX idx_products_barcode ON products(barcode);

CREATE INDEX idx_inventory_items_product_id ON inventory_items(product_id);
CREATE INDEX idx_inventory_items_stock ON inventory_items(stock);

CREATE INDEX idx_print_services_paper_size_id ON print_services(paper_size_id);
CREATE INDEX idx_print_services_color_mode_id ON print_services(color_mode_id);

CREATE INDEX idx_transactions_transaction_number ON transactions(transaction_number);
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_status_id ON transactions(status_id);
CREATE INDEX idx_transactions_cashier_id ON transactions(cashier_id);
CREATE INDEX idx_transactions_customer_id ON transactions(customer_id);

CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id);
CREATE INDEX idx_transaction_items_inventory_id ON transaction_items(inventory_id);
CREATE INDEX idx_transaction_items_product_id ON transaction_items(product_id);
CREATE INDEX idx_transaction_items_print_order_id ON transaction_items(print_order_id);

CREATE INDEX idx_print_orders_service_id ON print_orders(service_id);

CREATE INDEX idx_expenses_category_id ON expenses(category_id);
CREATE INDEX idx_expenses_date ON expenses(date);
CREATE INDEX idx_expenses_source_id ON expenses(source_id);
CREATE INDEX idx_expenses_linked_transaction_id ON expenses(linked_transaction_id);

CREATE INDEX idx_activity_logs_action_id ON activity_logs(action_id);
CREATE INDEX idx_activity_logs_performed_by_id ON activity_logs(performed_by_id);
CREATE INDEX idx_activity_logs_timestamp ON activity_logs(timestamp);

CREATE INDEX idx_financial_reports_period_id ON financial_reports(period_id);
CREATE INDEX idx_financial_reports_start_date ON financial_reports(start_date);
CREATE INDEX idx_financial_reports_end_date ON financial_reports(end_date);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_customers_updated_at BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON inventory_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_print_services_updated_at BEFORE UPDATE ON print_services
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transaction_items_updated_at BEFORE UPDATE ON transaction_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_print_orders_updated_at BEFORE UPDATE ON print_orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_financial_reports_updated_at BEFORE UPDATE ON financial_reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Helper function to get user's role
CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS text AS $$
  SELECT ur.role_name
  FROM profiles p
  JOIN user_roles ur ON p.role_id = ur.id
  WHERE p.user_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER;

-- Helper function to check if user is owner
CREATE OR REPLACE FUNCTION public.is_owner()
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1
    FROM profiles p
    JOIN user_roles ur ON p.role_id = ur.id
    WHERE p.user_id = auth.uid()
    AND ur.role_name = 'owner'
  )
$$ LANGUAGE sql SECURITY DEFINER;

-- ============================================================================
-- ENABLE RLS ON ALL MAIN TABLES
-- ============================================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE print_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE print_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_reports ENABLE ROW LEVEL SECURITY;

ALTER TABLE activity_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE paper_sizes ENABLE ROW LEVEL SECURITY;
ALTER TABLE color_modes ENABLE ROW LEVEL SECURITY;
ALTER TABLE print_orientations ENABLE ROW LEVEL SECURITY;
ALTER TABLE print_finishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE transaction_statuses ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_periods ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES - LOOKUP TABLES (Read-only for authenticated users)
-- ============================================================================

CREATE POLICY "Authenticated users can read activity_actions"
  ON activity_actions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read expense_categories"
  ON expense_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read expense_sources"
  ON expense_sources FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read paper_sizes"
  ON paper_sizes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read color_modes"
  ON color_modes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read print_orientations"
  ON print_orientations FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read print_finishes"
  ON print_finishes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read product_categories"
  ON product_categories FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read transaction_statuses"
  ON transaction_statuses FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read payment_methods"
  ON payment_methods FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read user_roles"
  ON user_roles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can read report_periods"
  ON report_periods FOR SELECT
  TO authenticated
  USING (true);

-- ============================================================================
-- RLS POLICIES - PROFILES
-- ============================================================================

-- Users can view all profiles (needed for cashier names, etc.)
CREATE POLICY "Authenticated users can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid());

-- Only owners can create new profiles
CREATE POLICY "Owners can create profiles"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

-- Only owners can delete profiles
CREATE POLICY "Owners can delete profiles"
  ON profiles FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - CUSTOMERS
-- ============================================================================

-- All authenticated users can view customers
CREATE POLICY "Authenticated users can view customers"
  ON customers FOR SELECT
  TO authenticated
  USING (true);

-- All authenticated users can create customers
CREATE POLICY "Authenticated users can create customers"
  ON customers FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- All authenticated users can update customers
CREATE POLICY "Authenticated users can update customers"
  ON customers FOR UPDATE
  TO authenticated
  USING (true);

-- Only owners can delete customers
CREATE POLICY "Owners can delete customers"
  ON customers FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - PRODUCTS
-- ============================================================================

-- All authenticated users can view products
CREATE POLICY "Authenticated users can view products"
  ON products FOR SELECT
  TO authenticated
  USING (true);

-- Only owners can create products
CREATE POLICY "Owners can create products"
  ON products FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

-- Only owners can update products
CREATE POLICY "Owners can update products"
  ON products FOR UPDATE
  TO authenticated
  USING (public.is_owner());

-- Only owners can delete products
CREATE POLICY "Owners can delete products"
  ON products FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - INVENTORY ITEMS
-- ============================================================================

-- All authenticated users can view inventory
CREATE POLICY "Authenticated users can view inventory"
  ON inventory_items FOR SELECT
  TO authenticated
  USING (true);

-- Only owners can create inventory items
CREATE POLICY "Owners can create inventory"
  ON inventory_items FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

-- All authenticated users can update inventory (for stock deductions during sales)
CREATE POLICY "Authenticated users can update inventory"
  ON inventory_items FOR UPDATE
  TO authenticated
  USING (true);

-- Only owners can delete inventory items
CREATE POLICY "Owners can delete inventory"
  ON inventory_items FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - PRINT SERVICES
-- ============================================================================

-- All authenticated users can view print services
CREATE POLICY "Authenticated users can view print services"
  ON print_services FOR SELECT
  TO authenticated
  USING (true);

-- Only owners can create print services
CREATE POLICY "Owners can create print services"
  ON print_services FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

-- Only owners can update print services
CREATE POLICY "Owners can update print services"
  ON print_services FOR UPDATE
  TO authenticated
  USING (public.is_owner());

-- Only owners can delete print services
CREATE POLICY "Owners can delete print services"
  ON print_services FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - TRANSACTIONS
-- ============================================================================

-- All authenticated users can view all transactions
CREATE POLICY "Authenticated users can view transactions"
  ON transactions FOR SELECT
  TO authenticated
  USING (true);

-- All authenticated users can create transactions
CREATE POLICY "Authenticated users can create transactions"
  ON transactions FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Users can update their own transactions, owners can update all
CREATE POLICY "Users can update own transactions, owners can update all"
  ON transactions FOR UPDATE
  TO authenticated
  USING (
    public.is_owner() OR
    cashier_id = (SELECT id FROM profiles WHERE user_id = auth.uid())
  );

-- Only owners can delete transactions
CREATE POLICY "Owners can delete transactions"
  ON transactions FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - TRANSACTION ITEMS
-- ============================================================================

-- All authenticated users can view transaction items
CREATE POLICY "Authenticated users can view transaction items"
  ON transaction_items FOR SELECT
  TO authenticated
  USING (true);

-- All authenticated users can create transaction items
CREATE POLICY "Authenticated users can create transaction items"
  ON transaction_items FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- All authenticated users can update transaction items
CREATE POLICY "Authenticated users can update transaction items"
  ON transaction_items FOR UPDATE
  TO authenticated
  USING (true);

-- Only owners can delete transaction items
CREATE POLICY "Owners can delete transaction items"
  ON transaction_items FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - PRINT ORDERS
-- ============================================================================

-- All authenticated users can view print orders
CREATE POLICY "Authenticated users can view print orders"
  ON print_orders FOR SELECT
  TO authenticated
  USING (true);

-- All authenticated users can create print orders
CREATE POLICY "Authenticated users can create print orders"
  ON print_orders FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- All authenticated users can update print orders
CREATE POLICY "Authenticated users can update print orders"
  ON print_orders FOR UPDATE
  TO authenticated
  USING (true);

-- Only owners can delete print orders
CREATE POLICY "Owners can delete print orders"
  ON print_orders FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - EXPENSES
-- ============================================================================

-- All authenticated users can view expenses
CREATE POLICY "Authenticated users can view expenses"
  ON expenses FOR SELECT
  TO authenticated
  USING (true);

-- All authenticated users can create expenses
CREATE POLICY "Authenticated users can create expenses"
  ON expenses FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Only owners can update expenses
CREATE POLICY "Owners can update expenses"
  ON expenses FOR UPDATE
  TO authenticated
  USING (public.is_owner());

-- Only owners can delete expenses
CREATE POLICY "Owners can delete expenses"
  ON expenses FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- RLS POLICIES - ACTIVITY LOGS
-- ============================================================================

-- All authenticated users can view activity logs
CREATE POLICY "Authenticated users can view activity logs"
  ON activity_logs FOR SELECT
  TO authenticated
  USING (true);

-- All authenticated users can create activity logs
CREATE POLICY "Authenticated users can create activity logs"
  ON activity_logs FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- No one can update activity logs (immutable audit trail)
-- No one can delete activity logs (immutable audit trail)

-- ============================================================================
-- RLS POLICIES - FINANCIAL REPORTS
-- ============================================================================

-- All authenticated users can view financial reports
CREATE POLICY "Authenticated users can view financial reports"
  ON financial_reports FOR SELECT
  TO authenticated
  USING (true);

-- Only owners can create financial reports
CREATE POLICY "Owners can create financial reports"
  ON financial_reports FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

-- Only owners can update financial reports
CREATE POLICY "Owners can update financial reports"
  ON financial_reports FOR UPDATE
  TO authenticated
  USING (public.is_owner());

-- Only owners can delete financial reports
CREATE POLICY "Owners can delete financial reports"
  ON financial_reports FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- FINANCIAL METRICS TABLES (Replace JSONB storage)
-- ============================================================================

-- Daily metrics table
CREATE TABLE daily_metrics (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  financial_report_id int8 NOT NULL REFERENCES financial_reports(id) ON DELETE CASCADE,
  date date NOT NULL,
  revenue numeric(12, 2) NOT NULL,
  store_revenue numeric(12, 2) NOT NULL,
  printing_revenue numeric(12, 2) NOT NULL,
  expenses numeric(12, 2) NOT NULL,
  profit numeric(12, 2) NOT NULL,
  transaction_count int4 NOT NULL,
  profit_margin numeric(5, 2) NOT NULL, -- Percentage
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Weekly metrics table
CREATE TABLE weekly_metrics (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  financial_report_id int8 NOT NULL REFERENCES financial_reports(id) ON DELETE CASCADE,
  week_start_date date NOT NULL,
  week_end_date date NOT NULL,
  revenue numeric(12, 2) NOT NULL,
  store_revenue numeric(12, 2) NOT NULL,
  printing_revenue numeric(12, 2) NOT NULL,
  expenses numeric(12, 2) NOT NULL,
  profit numeric(12, 2) NOT NULL,
  daily_average numeric(12, 2) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Monthly metrics table
CREATE TABLE monthly_metrics (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  financial_report_id int8 NOT NULL REFERENCES financial_reports(id) ON DELETE CASCADE,
  month date NOT NULL, -- First day of the month
  revenue numeric(12, 2) NOT NULL,
  store_revenue numeric(12, 2) NOT NULL,
  printing_revenue numeric(12, 2) NOT NULL,
  expenses numeric(12, 2) NOT NULL,
  profit numeric(12, 2) NOT NULL,
  daily_average numeric(12, 2) NOT NULL,
  transaction_count int4 NOT NULL,
  profit_margin numeric(5, 2) NOT NULL, -- Percentage
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Trend data points table
CREATE TABLE trend_data_points (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  financial_report_id int8 NOT NULL REFERENCES financial_reports(id) ON DELETE CASCADE,
  date date NOT NULL,
  revenue numeric(12, 2) NOT NULL,
  store_revenue numeric(12, 2) NOT NULL,
  printing_revenue numeric(12, 2) NOT NULL,
  expenses numeric(12, 2) NOT NULL,
  profit numeric(12, 2) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Department revenue table
CREATE TABLE department_revenues (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  financial_report_id int8 NOT NULL REFERENCES financial_reports(id) ON DELETE CASCADE,
  name text NOT NULL CHECK (name IN ('Store', 'Printing')),
  value numeric(12, 2) NOT NULL,
  percentage numeric(5, 2) NOT NULL,
  color text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Expenses by category table
CREATE TABLE expenses_by_category (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  financial_report_id int8 NOT NULL REFERENCES financial_reports(id) ON DELETE CASCADE,
  category_id int8 NOT NULL REFERENCES expense_categories(id),
  amount numeric(12, 2) NOT NULL,
  percentage numeric(5, 2) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ============================================================================
-- INDEXES FOR METRICS TABLES
-- ============================================================================

CREATE INDEX idx_daily_metrics_financial_report_id ON daily_metrics(financial_report_id);
CREATE INDEX idx_daily_metrics_date ON daily_metrics(date);

CREATE INDEX idx_weekly_metrics_financial_report_id ON weekly_metrics(financial_report_id);
CREATE INDEX idx_weekly_metrics_week_start_date ON weekly_metrics(week_start_date);

CREATE INDEX idx_monthly_metrics_financial_report_id ON monthly_metrics(financial_report_id);
CREATE INDEX idx_monthly_metrics_month ON monthly_metrics(month);

CREATE INDEX idx_trend_data_points_financial_report_id ON trend_data_points(financial_report_id);
CREATE INDEX idx_trend_data_points_date ON trend_data_points(date);

CREATE INDEX idx_department_revenues_financial_report_id ON department_revenues(financial_report_id);

CREATE INDEX idx_expenses_by_category_financial_report_id ON expenses_by_category(financial_report_id);
CREATE INDEX idx_expenses_by_category_category_id ON expenses_by_category(category_id);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT (metrics tables)
-- ============================================================================

CREATE TRIGGER update_daily_metrics_updated_at BEFORE UPDATE ON daily_metrics
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_weekly_metrics_updated_at BEFORE UPDATE ON weekly_metrics
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_monthly_metrics_updated_at BEFORE UPDATE ON monthly_metrics
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trend_data_points_updated_at BEFORE UPDATE ON trend_data_points
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_department_revenues_updated_at BEFORE UPDATE ON department_revenues
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_by_category_updated_at BEFORE UPDATE ON expenses_by_category
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- RLS FOR METRICS TABLES
-- ============================================================================

ALTER TABLE daily_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE trend_data_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE department_revenues ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses_by_category ENABLE ROW LEVEL SECURITY;

-- All authenticated users can view metrics
CREATE POLICY "Authenticated users can view daily_metrics"
  ON daily_metrics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view weekly_metrics"
  ON weekly_metrics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view monthly_metrics"
  ON monthly_metrics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view trend_data_points"
  ON trend_data_points FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view department_revenues"
  ON department_revenues FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can view expenses_by_category"
  ON expenses_by_category FOR SELECT
  TO authenticated
  USING (true);

-- Only owners can create metrics
CREATE POLICY "Owners can create daily_metrics"
  ON daily_metrics FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

CREATE POLICY "Owners can create weekly_metrics"
  ON weekly_metrics FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

CREATE POLICY "Owners can create monthly_metrics"
  ON monthly_metrics FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

CREATE POLICY "Owners can create trend_data_points"
  ON trend_data_points FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

CREATE POLICY "Owners can create department_revenues"
  ON department_revenues FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

CREATE POLICY "Owners can create expenses_by_category"
  ON expenses_by_category FOR INSERT
  TO authenticated
  WITH CHECK (public.is_owner());

-- Only owners can update metrics
CREATE POLICY "Owners can update daily_metrics"
  ON daily_metrics FOR UPDATE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can update weekly_metrics"
  ON weekly_metrics FOR UPDATE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can update monthly_metrics"
  ON monthly_metrics FOR UPDATE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can update trend_data_points"
  ON trend_data_points FOR UPDATE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can update department_revenues"
  ON department_revenues FOR UPDATE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can update expenses_by_category"
  ON expenses_by_category FOR UPDATE
  TO authenticated
  USING (public.is_owner());

-- Only owners can delete metrics
CREATE POLICY "Owners can delete daily_metrics"
  ON daily_metrics FOR DELETE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can delete weekly_metrics"
  ON weekly_metrics FOR DELETE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can delete monthly_metrics"
  ON monthly_metrics FOR DELETE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can delete trend_data_points"
  ON trend_data_points FOR DELETE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can delete department_revenues"
  ON department_revenues FOR DELETE
  TO authenticated
  USING (public.is_owner());

CREATE POLICY "Owners can delete expenses_by_category"
  ON expenses_by_category FOR DELETE
  TO authenticated
  USING (public.is_owner());

-- ============================================================================
-- SEED DATA ADDITIONS
-- ============================================================================

INSERT INTO activity_actions (action_name, category) VALUES
  ('Product Added', 'product'),
  ('Product Updated', 'product'),
  ('Product Deleted', 'product'),
  ('Print Service Added', 'print_service'),
  ('Print Service Updated', 'print_service'),
  ('Print Service Deleted', 'print_service')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- STORAGE POLICIES
-- ============================================================================

-- Allow authenticated users to upload/update their own profile pictures
CREATE POLICY "Users can upload avatars"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Users can update avatars"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'avatars');

-- Allow public read access
CREATE POLICY "Public avatar read access"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

CREATE OR REPLACE FUNCTION get_email_by_username(lookup_username text)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT au.email
  FROM auth.users au
  JOIN public.profiles p ON p.user_id = au.id
  WHERE p.username = lookup_username
  LIMIT 1;
$$;
