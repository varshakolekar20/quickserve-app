-- QuickServe Production Database Setup
-- Run this entire script in Supabase SQL Editor

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Profiles Table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('customer', 'agent', 'admin')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Services Table
CREATE TABLE IF NOT EXISTS public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    base_price NUMERIC(10, 2),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed Services
INSERT INTO public.services (name, description, icon, base_price)
SELECT 'AC Servicing', 'Cooling diagnostics, filter cleaning, refrigerant check', 'ac_unit', 499.00
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE name = 'AC Servicing');

INSERT INTO public.services (name, description, icon, base_price)
SELECT 'Plumbing', 'Leak detection, pipe repair, faucet replacement', 'plumbing', 299.00
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE name = 'Plumbing');

INSERT INTO public.services (name, description, icon, base_price)
SELECT 'Electrical', 'Wiring inspection, short circuit fix, breaker upgrade', 'bolt', 399.00
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE name = 'Electrical');

INSERT INTO public.services (name, description, icon, base_price)
SELECT 'Cleaning', 'Deep residential cleaning, kitchen and bathroom sanitation', 'cleaning_services', 349.00
WHERE NOT EXISTS (SELECT 1 FROM public.services WHERE name = 'Cleaning');

-- 3. Service Requests Table
CREATE TABLE IF NOT EXISTS public.service_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id TEXT UNIQUE,
    customer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    agent_id UUID REFERENCES public.profiles(id),
    service_id UUID NOT NULL REFERENCES public.services(id),
    description TEXT,
    preferred_date DATE NOT NULL,
    preferred_time TEXT NOT NULL,
    address TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH')),
    status TEXT NOT NULL DEFAULT 'CREATED' CHECK (status IN ('CREATED', 'ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Status History Table
CREATE TABLE IF NOT EXISTS public.request_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_id UUID NOT NULL REFERENCES public.service_requests(id) ON DELETE CASCADE,
    previous_status TEXT,
    new_status TEXT NOT NULL,
    changed_by UUID REFERENCES public.profiles(id),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Triggers: Auto Profile Creation on Signup
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
    )
    ON CONFLICT (id) DO UPDATE
    SET full_name = EXCLUDED.full_name,
        phone = EXCLUDED.phone;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Triggers: Auto Human-Readable Request ID
CREATE OR REPLACE FUNCTION public.generate_request_id()
RETURNS TRIGGER AS $$
DECLARE
    seq_num INT;
BEGIN
    IF NEW.request_id IS NULL OR NEW.request_id = '' THEN
        SELECT COUNT(*) + 1 INTO seq_num FROM public.service_requests;
        NEW.request_id := 'REQ-' || TO_CHAR(now(), 'YYYY') || '-' || LPAD(seq_num::TEXT, 6, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_request_id ON public.service_requests;
CREATE TRIGGER set_request_id
    BEFORE INSERT ON public.service_requests
    FOR EACH ROW EXECUTE FUNCTION public.generate_request_id();

-- Enable Row Level Security (RLS)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.request_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Profiles Policies
DROP POLICY IF EXISTS "profiles_select" ON public.profiles;
CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "profiles_update" ON public.profiles;
CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Services Policies (Public Read)
DROP POLICY IF EXISTS "services_select" ON public.services;
CREATE POLICY "services_select" ON public.services FOR SELECT USING (is_active = true);

-- Service Requests Policies
DROP POLICY IF EXISTS "requests_select" ON public.service_requests;
CREATE POLICY "requests_select" ON public.service_requests FOR SELECT USING (
    customer_id = auth.uid() OR agent_id = auth.uid()
);

DROP POLICY IF EXISTS "requests_insert" ON public.service_requests;
CREATE POLICY "requests_insert" ON public.service_requests FOR INSERT WITH CHECK (
    customer_id = auth.uid()
);

DROP POLICY IF EXISTS "requests_update_customer" ON public.service_requests;
CREATE POLICY "requests_update_customer" ON public.service_requests FOR UPDATE USING (
    customer_id = auth.uid() AND status IN ('CREATED', 'ASSIGNED')
);

DROP POLICY IF EXISTS "requests_update_agent" ON public.service_requests;
CREATE POLICY "requests_update_agent" ON public.service_requests FOR UPDATE USING (
    agent_id = auth.uid()
);

-- Status History Policies
DROP POLICY IF EXISTS "history_select" ON public.request_status_history;
CREATE POLICY "history_select" ON public.request_status_history FOR SELECT USING (true);

DROP POLICY IF EXISTS "history_insert" ON public.request_status_history;
CREATE POLICY "history_insert" ON public.request_status_history FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Audit Logs Policies
DROP POLICY IF EXISTS "audit_select" ON public.audit_logs;
CREATE POLICY "audit_select" ON public.audit_logs FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "audit_insert" ON public.audit_logs;
CREATE POLICY "audit_insert" ON public.audit_logs FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Performance Indexes
CREATE INDEX IF NOT EXISTS idx_requests_customer ON public.service_requests(customer_id);
CREATE INDEX IF NOT EXISTS idx_requests_agent ON public.service_requests(agent_id);
CREATE INDEX IF NOT EXISTS idx_requests_status ON public.service_requests(status);
CREATE INDEX IF NOT EXISTS idx_requests_created ON public.service_requests(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_history_request ON public.request_status_history(request_id);
