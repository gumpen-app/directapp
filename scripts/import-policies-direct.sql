-- Import Role-Based Access Control Policies
-- Generated from schema/policies/complete-role-policies.json
-- Direct SQL import (bypasses API authentication issues)

BEGIN;

-- =============================================================================
-- CREATE 9 ROLE POLICIES
-- =============================================================================

-- 1. Nybilselger Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-nybilselger-uuid',
  'Nybilselger',
  'badge',
  'Nybilselger - Can create and manage nybil for own dealership',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 2. Bruktbilselger Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-bruktbilselger-uuid',
  'Bruktbilselger',
  'badge',
  'Bruktbilselger - Can create bruktbil and search across dealerships',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 3. Delelager Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-delelager-uuid',
  'Delelager',
  'badge',
  'Delelager - Manages parts ordering and tracking',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 4. Mottakskontrollør Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-mottakskontroll-uuid',
  'Mottakskontrollør',
  'badge',
  'Mottakskontrollør - Performs vehicle inspections',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 5. Booking Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-booking-uuid',
  'Booking',
  'badge',
  'Booking - Workshop scheduling and assignment',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 6. Mekaniker Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-mekaniker-uuid',
  'Mekaniker',
  'badge',
  'Mekaniker - Technical prep work with time banking',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 7. Bilpleiespesialist Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-bilpleier-uuid',
  'Bilpleiespesialist',
  'badge',
  'Bilpleiespesialist - Cosmetic prep work with time banking',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 8. Daglig leder Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-daglig-leder-uuid',
  'Daglig leder',
  'badge',
  'Daglig leder - Read-only access to all dealership data',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- 9. Økonomiansvarlig Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'pol-okonomi-uuid',
  'Økonomiansvarlig',
  'badge',
  'Økonomiansvarlig - Financial data access and pricing',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- NYBILSELGER PERMISSIONS
-- =============================================================================

-- Nybilselger: CREATE cars (nybil only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'create',
  NULL,
  NULL,
  '{"car_type": "nybil"}',
  'vin,license_plate,brand,model,model_year,color,order_number,customer_name,customer_phone,customer_email,car_type,status,accessories,estimated_technical_hours,estimated_cosmetic_hours,sale_price,seller_notes,dealership_id,seller_id,registered_at',
  'pol-nybilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Nybilselger: READ cars (nybil, own dealership only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"_and": [{"car_type": {"_eq": "nybil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}',
  NULL,
  NULL,
  '*',
  'pol-nybilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Nybilselger: UPDATE cars (nybil, own dealership, not archived)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"car_type": {"_eq": "nybil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'vin,license_plate,brand,model,model_year,color,order_number,customer_name,customer_phone,customer_email,status,accessories,sale_price,sold_at,delivered_to_customer_at,seller_notes',
  'pol-nybilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Nybilselger: DELETE cars (only ny_ordre status)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'delete',
  '{"_and": [{"car_type": {"_eq": "nybil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_eq": "ny_ordre"}}]}',
  NULL,
  NULL,
  '*',
  'pol-nybilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Nybilselger: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-nybilselger-uuid')
ON CONFLICT DO NOTHING;

-- Nybilselger: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, 'id,first_name,last_name,email,avatar,dealership_id', 'pol-nybilselger-uuid')
ON CONFLICT DO NOTHING;

-- Nybilselger: UPDATE own user profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-nybilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Nybilselger: CREATE files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'create', '{}', NULL, NULL, '*', 'pol-nybilselger-uuid')
ON CONFLICT DO NOTHING;

-- Nybilselger: READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-nybilselger-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- BRUKTBILSELGER PERMISSIONS
-- =============================================================================

-- Bruktbilselger: CREATE cars (bruktbil only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'create',
  NULL,
  NULL,
  '{"car_type": "bruktbil"}',
  'vin,license_plate,brand,model,model_year,color,mileage,trade_in_value,car_type,status,accessories,estimated_technical_hours,estimated_cosmetic_hours,sale_price,seller_notes,dealership_id,seller_id,registered_at',
  'pol-bruktbilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: READ cars (ALL bruktbil across dealerships!)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"car_type": {"_eq": "bruktbil"}}',
  NULL,
  NULL,
  '*',
  'pol-bruktbilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: UPDATE cars (bruktbil, own dealership only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"car_type": {"_eq": "bruktbil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'vin,license_plate,brand,model,model_year,color,mileage,trade_in_value,status,accessories,sale_price,sold_at,delivered_to_customer_at,seller_notes',
  'pol-bruktbilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: DELETE cars (only innbytte_registrert)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'delete',
  '{"_and": [{"car_type": {"_eq": "bruktbil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_eq": "innbytte_registrert"}}]}',
  NULL,
  NULL,
  '*',
  'pol-bruktbilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: READ all dealerships (for cross-dealership search)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-bruktbilselger-uuid')
ON CONFLICT DO NOTHING;

-- Bruktbilselger: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, 'id,first_name,last_name,email,avatar,dealership_id', 'pol-bruktbilselger-uuid')
ON CONFLICT DO NOTHING;

-- Bruktbilselger: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-bruktbilselger-uuid'
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: CREATE/READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'create', '{}', NULL, NULL, '*', 'pol-bruktbilselger-uuid')
ON CONFLICT DO NOTHING;

INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-bruktbilselger-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- DELELAGER PERMISSIONS
-- =============================================================================

-- Delelager: READ cars (own dealership OR prep center)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"_or": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}',
  NULL,
  NULL,
  '*',
  'pol-delelager-uuid'
) ON CONFLICT DO NOTHING;

-- Delelager: UPDATE cars (parts fields only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"_or": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'parts_ordered_seller_at,parts_arrived_seller_at,parts_ordered_prep_at,parts_arrived_prep_at,accessories,parts_notes',
  'pol-delelager-uuid'
) ON CONFLICT DO NOTHING;

-- Delelager: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-delelager-uuid')
ON CONFLICT DO NOTHING;

-- Delelager: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, 'id,first_name,last_name,email,dealership_id', 'pol-delelager-uuid')
ON CONFLICT DO NOTHING;

-- Delelager: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-delelager-uuid'
) ON CONFLICT DO NOTHING;

-- Delelager: READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-delelager-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- MOTTAKSKONTROLLØR PERMISSIONS
-- =============================================================================

-- Mottakskontrollør: READ cars (prep center only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}',
  NULL,
  NULL,
  '*',
  'pol-mottakskontroll-uuid'
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: UPDATE cars (inspection fields during inspection statuses)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"_or": [{"status": {"_eq": "mottakskontroll_pågår"}}, {"status": {"_eq": "mottakskontroll_godkjent"}}, {"status": {"_eq": "mottakskontroll_avvik"}}]}]}',
  NULL,
  NULL,
  'status,inspection_started_at,inspection_completed_at,inspection_approved,inspection_notes,inspection_defects',
  'pol-mottakskontroll-uuid'
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-mottakskontroll-uuid')
ON CONFLICT DO NOTHING;

-- Mottakskontrollør: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, 'id,first_name,last_name,email,dealership_id', 'pol-mottakskontroll-uuid')
ON CONFLICT DO NOTHING;

-- Mottakskontrollør: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-mottakskontroll-uuid'
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: CREATE/READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'create', '{}', NULL, NULL, '*', 'pol-mottakskontroll-uuid')
ON CONFLICT DO NOTHING;

INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-mottakskontroll-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- BOOKING PERMISSIONS
-- =============================================================================

-- Booking: READ cars (prep center only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}',
  NULL,
  NULL,
  '*',
  'pol-booking-uuid'
) ON CONFLICT DO NOTHING;

-- Booking: UPDATE cars (scheduling and assignment fields)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'status,scheduled_technical_start,scheduled_cosmetic_start,estimated_technical_hours,estimated_cosmetic_hours,assigned_mechanic_id,assigned_detailer_id,delivered_to_dealership_at,booking_notes',
  'pol-booking-uuid'
) ON CONFLICT DO NOTHING;

-- Booking: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-booking-uuid')
ON CONFLICT DO NOTHING;

-- Booking: READ directus_users (need to see all prep center staff for assignment)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, '*', 'pol-booking-uuid')
ON CONFLICT DO NOTHING;

-- Booking: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-booking-uuid'
) ON CONFLICT DO NOTHING;

-- Booking: READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-booking-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- MEKANIKER PERMISSIONS
-- =============================================================================

-- Mekaniker: READ cars (prep center only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}',
  NULL,
  NULL,
  '*',
  'pol-mekaniker-uuid'
) ON CONFLICT DO NOTHING;

-- Mekaniker: UPDATE cars (technical fields, ONLY when assigned, during technical statuses)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"assigned_mechanic_id": {"_eq": "$CURRENT_USER"}}, {"_or": [{"status": {"_eq": "planlagt_teknisk"}}, {"status": {"_eq": "teknisk_pågår"}}, {"status": {"_eq": "teknisk_ferdig"}}]}]}',
  NULL,
  NULL,
  'status,technical_started_at,technical_completed_at,technical_work_description,technical_issues,actual_technical_hours',
  'pol-mekaniker-uuid'
) ON CONFLICT DO NOTHING;

-- Mekaniker: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-mekaniker-uuid')
ON CONFLICT DO NOTHING;

-- Mekaniker: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, 'id,first_name,last_name,email,dealership_id', 'pol-mekaniker-uuid')
ON CONFLICT DO NOTHING;

-- Mekaniker: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-mekaniker-uuid'
) ON CONFLICT DO NOTHING;

-- Mekaniker: CREATE/READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'create', '{}', NULL, NULL, '*', 'pol-mekaniker-uuid')
ON CONFLICT DO NOTHING;

INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-mekaniker-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- BILPLEIESPESIALIST PERMISSIONS
-- =============================================================================

-- Bilpleiespesialist: READ cars (prep center only)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}',
  NULL,
  NULL,
  '*',
  'pol-bilpleier-uuid'
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: UPDATE cars (cosmetic fields, ONLY when assigned, during cosmetic statuses)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"assigned_detailer_id": {"_eq": "$CURRENT_USER"}}, {"_or": [{"status": {"_eq": "planlagt_kosmetisk"}}, {"status": {"_eq": "kosmetisk_pågår"}}, {"status": {"_eq": "kosmetisk_ferdig"}}]}]}',
  NULL,
  NULL,
  'status,cosmetic_started_at,cosmetic_completed_at,cosmetic_work_description,cosmetic_issues,actual_cosmetic_hours',
  'pol-bilpleier-uuid'
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-bilpleier-uuid')
ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, 'id,first_name,last_name,email,dealership_id', 'pol-bilpleier-uuid')
ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-bilpleier-uuid'
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: CREATE/READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'create', '{}', NULL, NULL, '*', 'pol-bilpleier-uuid')
ON CONFLICT DO NOTHING;

INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-bilpleier-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- DAGLIG LEDER PERMISSIONS (Read-Only)
-- =============================================================================

-- Daglig leder: READ cars (all in own dealership)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}',
  NULL,
  NULL,
  '*',
  'pol-daglig-leder-uuid'
) ON CONFLICT DO NOTHING;

-- Daglig leder: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-daglig-leder-uuid')
ON CONFLICT DO NOTHING;

-- Daglig leder: READ all directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, '*', 'pol-daglig-leder-uuid')
ON CONFLICT DO NOTHING;

-- Daglig leder: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-daglig-leder-uuid'
) ON CONFLICT DO NOTHING;

-- Daglig leder: READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-daglig-leder-uuid')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- ØKONOMIANSVARLIG PERMISSIONS
-- =============================================================================

-- Økonomiansvarlig: READ cars (all in own dealership)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}',
  NULL,
  NULL,
  '*',
  'pol-okonomi-uuid'
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: UPDATE cars (pricing fields ONLY)
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'purchase_price,sale_price,prep_cost',
  'pol-okonomi-uuid'
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('dealership', 'read', NULL, NULL, NULL, '*', 'pol-okonomi-uuid')
ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_users', 'read', NULL, NULL, NULL, '*', 'pol-okonomi-uuid')
ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: UPDATE own profile
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'pol-okonomi-uuid'
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: READ files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES ('directus_files', 'read', '{}', NULL, NULL, '*', 'pol-okonomi-uuid')
ON CONFLICT DO NOTHING;

COMMIT;

-- =============================================================================
-- Import complete!
-- =============================================================================

-- Next step: Link policies to roles via directus_access table
-- Example:
-- INSERT INTO directus_access (role, policy) VALUES ('role-uuid', 'pol-nybilselger-uuid');
