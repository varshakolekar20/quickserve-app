-- =============================================================================
-- QuickServe — Complete Database Schema
-- PostgreSQL / Supabase
-- =============================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================================
-- TABLE: profiles
-- Extends Supabase auth.users. Created automatically on user registration
-- via a Postgres trigger.
-- =============================================================================
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT        NOT NULL,
  email       TEXT        UNIQUE NOT NULL,
  phone       TEXT,
  role        TEXT        NOT NULL DEFAULT 'customer'
                          CHECK (role IN ('customer', 'agent', 'admin')),
  is_active   BOOLEAN     NOT NULL DEFAULT true,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ
);

-- Auto-create profile on new Supabase Auth user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
    NEW.raw_user_meta_data->>'phone',
    COALESCE(NEW.raw_user_meta_data->>'role', 'customer')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================================================
-- TABLE: services
-- Service catalog visible to customers when creating a request
-- =============================================================================
CREATE TABLE IF NOT EXISTS services (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT        NOT NULL,
  description TEXT,
  icon        TEXT,                        -- Material icon name (e.g. 'plumbing')
  base_price  NUMERIC(10, 2),
  is_active   BOOLEAN     NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed initial service categories
INSERT INTO services (name, description, icon, base_price) VALUES
  ('AC Servicing',    'Cooling diagnostics, filter cleaning, refrigerant check', 'ac_unit',           499.00),
  ('Plumbing',        'Leak detection, pipe repair, faucet replacement',          'plumbing',          299.00),
  ('Electrical',      'Wiring inspection, short circuit fix, breaker upgrade',     'bolt',              399.00),
  ('Cleaning',        'Deep residential cleaning, kitchen and bathroom sanitation', 'cleaning_services', 349.00);

-- =============================================================================
-- TABLE: service_requests
-- Core table — one row per customer service request
-- =============================================================================
CREATE TABLE IF NOT EXISTS service_requests (
  id              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id      TEXT        UNIQUE NOT NULL,               -- Human-readable: REQ-2026-000001
  customer_id     UUID        NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  agent_id        UUID        REFERENCES profiles(id),       -- NULL until assigned
  service_id      UUID        NOT NULL REFERENCES services(id),
  description     TEXT,
  preferred_date  DATE,
  preferred_time  TEXT,                                      -- 'Morning' | 'Afternoon' | 'Evening'
  address         TEXT,
  priority        TEXT        NOT NULL DEFAULT 'MEDIUM'
                              CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
  status          TEXT        NOT NULL DEFAULT 'CREATED'
                              CHECK (status IN (
                                'CREATED', 'ASSIGNED', 'ACCEPTED',
                                'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
                              )),
  notes           TEXT,                                      -- Agent field notes
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ
);

-- Auto-generate human-readable request_id
CREATE OR REPLACE FUNCTION generate_request_id()
RETURNS TRIGGER AS $$
DECLARE
  seq_num INT;
BEGIN
  SELECT COUNT(*) + 1 INTO seq_num FROM service_requests;
  NEW.request_id := 'REQ-' || TO_CHAR(now(), 'YYYY') || '-' || LPAD(seq_num::TEXT, 6, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_request_id
  BEFORE INSERT ON service_requests
  FOR EACH ROW EXECUTE FUNCTION generate_request_id();

-- =============================================================================
-- TABLE: request_status_history
-- Immutable audit log of every status transition per request
-- =============================================================================
CREATE TABLE IF NOT EXISTS request_status_history (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id       UUID        NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  previous_status  TEXT,
  new_status       TEXT        NOT NULL,
  changed_by       UUID        REFERENCES profiles(id),
  note             TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- TABLE: audit_logs
-- Application-level event log (auth, errors, security events)
-- =============================================================================
CREATE TABLE IF NOT EXISTS audit_logs (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        REFERENCES profiles(id),
  event_type    TEXT        NOT NULL,   -- LOGIN_SUCCESS, REQUEST_CREATED, etc.
  resource_type TEXT,                   -- 'service_request', 'profile', etc.
  resource_id   UUID,
  metadata      JSONB,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =============================================================================
-- ROW LEVEL SECURITY
-- All tables have RLS enabled. Access is scoped to auth.uid().
-- =============================================================================

ALTER TABLE profiles            ENABLE ROW LEVEL SECURITY;
ALTER TABLE services            ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests    ENABLE ROW LEVEL SECURITY;
ALTER TABLE request_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs          ENABLE ROW LEVEL SECURITY;

-- profiles: users can only see and update their own profile
CREATE POLICY "Users: select own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users: update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

-- services: publicly readable (catalog)
CREATE POLICY "Services: public read"
  ON services FOR SELECT
  USING (is_active = true);

-- service_requests: customers see only their own
CREATE POLICY "Customers: select own requests"
  ON service_requests FOR SELECT
  USING (auth.uid() = customer_id);

-- service_requests: agents see only their assigned requests
CREATE POLICY "Agents: select assigned requests"
  ON service_requests FOR SELECT
  USING (auth.uid() = agent_id);

-- service_requests: customers can insert their own
CREATE POLICY "Customers: insert own requests"
  ON service_requests FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

-- service_requests: customers can cancel (update) their own if CREATED or ASSIGNED
CREATE POLICY "Customers: cancel own requests"
  ON service_requests FOR UPDATE
  USING (auth.uid() = customer_id AND status IN ('CREATED', 'ASSIGNED'));

-- service_requests: agents can update only their assigned requests
CREATE POLICY "Agents: update assigned requests"
  ON service_requests FOR UPDATE
  USING (auth.uid() = agent_id);

-- request_status_history: participants can read
CREATE POLICY "Participants: read request history"
  ON request_status_history FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM service_requests sr
      WHERE sr.id = request_id
        AND (sr.customer_id = auth.uid() OR sr.agent_id = auth.uid())
    )
  );

-- audit_logs: users can read their own logs
CREATE POLICY "Users: read own audit logs"
  ON audit_logs FOR SELECT
  USING (auth.uid() = user_id);

-- =============================================================================
-- INDEXES for query performance
-- =============================================================================
CREATE INDEX IF NOT EXISTS idx_service_requests_customer_id  ON service_requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_agent_id     ON service_requests(agent_id);
CREATE INDEX IF NOT EXISTS idx_service_requests_status       ON service_requests(status);
CREATE INDEX IF NOT EXISTS idx_service_requests_created_at   ON service_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_request_history_request_id    ON request_status_history(request_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id            ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_event_type         ON audit_logs(event_type);
