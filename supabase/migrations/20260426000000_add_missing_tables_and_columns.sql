-- ============================================================================
-- Migration: Add missing tables and columns
-- Date: 2026-04-26
--
-- Changes:
--   1. Add selling_price, perishable to products
--   2. Add is_active to profiles
--   3. Create machines table
--   4. Create service_supplies table
--   5. Create stock_in table
--   6. Alter inventory_items: nullable product_id, drop unique, add FKs + expiry_date
--   7. Add machine_id, service_supply_id to print_services
--   8. Create stock_out table
--   9. Create login_history table
--  10. Create services, service_types, service_type_costs tables (normalized ERD)
-- ============================================================================

-- ============================================================================
-- 1. ALTER EXISTING TABLES
-- ============================================================================

-- Products: add selling_price and perishable
ALTER TABLE products
  ADD COLUMN IF NOT EXISTS selling_price numeric(12, 2),
  ADD COLUMN IF NOT EXISTS perishable boolean NOT NULL DEFAULT true;

-- Profiles: add is_active
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true;

-- ============================================================================
-- 2. MACHINES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS machines (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_machines_name ON machines(name);
CREATE INDEX IF NOT EXISTS idx_machines_is_active ON machines(is_active);

CREATE TRIGGER update_machines_updated_at BEFORE UPDATE ON machines
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE machines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view machines"
  ON machines FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can create machines"
  ON machines FOR INSERT TO authenticated WITH CHECK (public.is_owner());
CREATE POLICY "Owners can update machines"
  ON machines FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete machines"
  ON machines FOR DELETE TO authenticated USING (public.is_owner());

-- ============================================================================
-- 3. SERVICE_SUPPLIES TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS service_supplies (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text NOT NULL,
  supply_type text NOT NULL,
  paper_size text,
  purchase_price numeric(12, 2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_service_supplies_supply_type ON service_supplies(supply_type);

CREATE TRIGGER update_service_supplies_updated_at BEFORE UPDATE ON service_supplies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE service_supplies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view service_supplies"
  ON service_supplies FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can create service_supplies"
  ON service_supplies FOR INSERT TO authenticated WITH CHECK (public.is_owner());
CREATE POLICY "Owners can update service_supplies"
  ON service_supplies FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete service_supplies"
  ON service_supplies FOR DELETE TO authenticated USING (public.is_owner());

-- ============================================================================
-- 4. STOCK_IN TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS stock_in (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  product_id int8 REFERENCES products(id) ON DELETE SET NULL,
  service_supply_id int8 REFERENCES service_supplies(id) ON DELETE SET NULL,
  user_id int8 NOT NULL REFERENCES profiles(id),
  expense_id int8 REFERENCES expenses(id) ON DELETE SET NULL,
  purchase_price numeric(12, 2) NOT NULL DEFAULT 0,
  quantity_added numeric(12, 2) NOT NULL DEFAULT 0,
  expiry_date date,
  stock_in_date timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stock_in_product_id ON stock_in(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_in_service_supply_id ON stock_in(service_supply_id);
CREATE INDEX IF NOT EXISTS idx_stock_in_user_id ON stock_in(user_id);
CREATE INDEX IF NOT EXISTS idx_stock_in_stock_in_date ON stock_in(stock_in_date);

ALTER TABLE stock_in ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view stock_in"
  ON stock_in FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can create stock_in"
  ON stock_in FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Owners can update stock_in"
  ON stock_in FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete stock_in"
  ON stock_in FOR DELETE TO authenticated USING (public.is_owner());

-- ============================================================================
-- 5. ALTER INVENTORY_ITEMS
-- ============================================================================

-- Remove UNIQUE constraint on product_id (support multiple batches per product)
ALTER TABLE inventory_items
  DROP CONSTRAINT IF EXISTS inventory_items_product_id_key;

-- Make product_id nullable (may be NULL for service supply items)
ALTER TABLE inventory_items
  ALTER COLUMN product_id DROP NOT NULL;

-- Add new columns
ALTER TABLE inventory_items
  ADD COLUMN IF NOT EXISTS service_supply_id int8 REFERENCES service_supplies(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS expiry_date date,
  ADD COLUMN IF NOT EXISTS stock_in_id int8 REFERENCES stock_in(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_inventory_items_service_supply_id ON inventory_items(service_supply_id);
CREATE INDEX IF NOT EXISTS idx_inventory_items_stock_in_id ON inventory_items(stock_in_id);
CREATE INDEX IF NOT EXISTS idx_inventory_items_expiry_date ON inventory_items(expiry_date);

-- ============================================================================
-- 6. ALTER PRINT_SERVICES
-- ============================================================================

ALTER TABLE print_services
  ADD COLUMN IF NOT EXISTS machine_id int8 REFERENCES machines(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS service_supply_id int8 REFERENCES service_supplies(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_print_services_machine_id ON print_services(machine_id);
CREATE INDEX IF NOT EXISTS idx_print_services_service_supply_id ON print_services(service_supply_id);

-- ============================================================================
-- 7. STOCK_OUT TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS stock_out (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  transaction_id int8 REFERENCES transactions(id) ON DELETE SET NULL,
  transaction_item_id int8 REFERENCES transaction_items(id) ON DELETE SET NULL,
  product_id int8 REFERENCES products(id) ON DELETE SET NULL,
  service_supply_id int8 REFERENCES service_supplies(id) ON DELETE SET NULL,
  inventory_item_id int8 REFERENCES inventory_items(id) ON DELETE SET NULL,
  user_id int8 NOT NULL REFERENCES profiles(id),
  quantity_removed numeric(12, 2) NOT NULL DEFAULT 0,
  stock_out_type text NOT NULL,
  stock_out_date timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_stock_out_transaction_id ON stock_out(transaction_id);
CREATE INDEX IF NOT EXISTS idx_stock_out_product_id ON stock_out(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_out_service_supply_id ON stock_out(service_supply_id);
CREATE INDEX IF NOT EXISTS idx_stock_out_inventory_item_id ON stock_out(inventory_item_id);
CREATE INDEX IF NOT EXISTS idx_stock_out_stock_out_date ON stock_out(stock_out_date);

ALTER TABLE stock_out ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view stock_out"
  ON stock_out FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated users can create stock_out"
  ON stock_out FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Owners can update stock_out"
  ON stock_out FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete stock_out"
  ON stock_out FOR DELETE TO authenticated USING (public.is_owner());

-- ============================================================================
-- 8. LOGIN_HISTORY TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS login_history (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  profile_id int8 NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  username text NOT NULL,
  login_time timestamptz NOT NULL DEFAULT now(),
  logout_time timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_login_history_profile_id ON login_history(profile_id);
CREATE INDEX IF NOT EXISTS idx_login_history_login_time ON login_history(login_time);

ALTER TABLE login_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own login_history"
  ON login_history FOR SELECT TO authenticated
  USING (profile_id = (SELECT id FROM profiles WHERE user_id = auth.uid()) OR public.is_owner());
CREATE POLICY "Authenticated users can create login_history"
  ON login_history FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Owners can delete login_history"
  ON login_history FOR DELETE TO authenticated USING (public.is_owner());

-- ============================================================================
-- 9. NORMALIZED SERVICE TABLES (from ERD)
-- ============================================================================

-- services: top-level service group (e.g. "Printing", "Lamination")
CREATE TABLE IF NOT EXISTS services (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE services ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view services"
  ON services FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can create services"
  ON services FOR INSERT TO authenticated WITH CHECK (public.is_owner());
CREATE POLICY "Owners can update services"
  ON services FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete services"
  ON services FOR DELETE TO authenticated USING (public.is_owner());

-- service_types: specific variant (e.g. "Short BW", "A4 Colored")
CREATE TABLE IF NOT EXISTS service_types (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  service_id int8 NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  service_supply_id int8 REFERENCES service_supplies(id) ON DELETE SET NULL,
  machine_id int8 REFERENCES machines(id) ON DELETE SET NULL,
  name text NOT NULL,
  paper_size text,
  color_mode text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_service_types_service_id ON service_types(service_id);
CREATE INDEX IF NOT EXISTS idx_service_types_machine_id ON service_types(machine_id);

CREATE TRIGGER update_service_types_updated_at BEFORE UPDATE ON service_types
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

ALTER TABLE service_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view service_types"
  ON service_types FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can create service_types"
  ON service_types FOR INSERT TO authenticated WITH CHECK (public.is_owner());
CREATE POLICY "Owners can update service_types"
  ON service_types FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete service_types"
  ON service_types FOR DELETE TO authenticated USING (public.is_owner());

-- service_type_costs: pricing/cost breakdown per service type
CREATE TABLE IF NOT EXISTS service_type_costs (
  id int8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  service_type_id int8 NOT NULL REFERENCES service_types(id) ON DELETE CASCADE,
  service_supply_cost numeric(12, 2) NOT NULL DEFAULT 0,
  ink_cost numeric(12, 2) NOT NULL DEFAULT 0,
  electricity_cost numeric(12, 2) NOT NULL DEFAULT 0,
  labor_cost numeric(12, 2) NOT NULL DEFAULT 0,
  service_total_cost numeric(12, 2) NOT NULL DEFAULT 0,
  service_selling_price numeric(12, 2) NOT NULL DEFAULT 0,
  last_updated timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_service_type_costs_service_type_id ON service_type_costs(service_type_id);

ALTER TABLE service_type_costs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view service_type_costs"
  ON service_type_costs FOR SELECT TO authenticated USING (true);
CREATE POLICY "Owners can create service_type_costs"
  ON service_type_costs FOR INSERT TO authenticated WITH CHECK (public.is_owner());
CREATE POLICY "Owners can update service_type_costs"
  ON service_type_costs FOR UPDATE TO authenticated USING (public.is_owner());
CREATE POLICY "Owners can delete service_type_costs"
  ON service_type_costs FOR DELETE TO authenticated USING (public.is_owner());

-- ============================================================================
-- 10. SEED: NEW ACTIVITY LOG ACTIONS
-- ============================================================================

INSERT INTO activity_actions (action_name, category) VALUES
  ('Machine Added', 'machine'),
  ('Machine Updated', 'machine'),
  ('Machine Deleted', 'machine'),
  ('Service Supply Added', 'service_supply'),
  ('Service Supply Updated', 'service_supply'),
  ('Service Supply Deleted', 'service_supply'),
  ('Stock In', 'inventory'),
  ('Stock Out', 'inventory'),
  ('Print Service Added', 'print_service'),
  ('Print Service Updated', 'print_service'),
  ('Print Service Deleted', 'print_service')
ON CONFLICT DO NOTHING;
