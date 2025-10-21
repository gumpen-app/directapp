-- Import Role-Based Access Control Policies
-- Generated from schema/policies/complete-role-policies.json
-- AUTO-GENERATED with real UUIDs

BEGIN;

-- =============================================================================
-- CREATE 9 ROLE POLICIES
-- =============================================================================

-- Nybilselger Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid,
  'Nybilselger',
  'badge',
  'Nybilselger - Can create and manage nybil for own dealership',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Bruktbilselger Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid,
  'Bruktbilselger',
  'badge',
  'Bruktbilselger - Can create bruktbil and search across dealerships',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Delelager Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid,
  'Delelager',
  'badge',
  'Delelager - Manages parts ordering and tracking',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Mottakskontrollør Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid,
  'Mottakskontrollør',
  'badge',
  'Mottakskontrollør - Performs vehicle inspections',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Booking Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid,
  'Booking',
  'badge',
  'Booking - Workshop scheduling and assignment',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Mekaniker Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid,
  'Mekaniker',
  'badge',
  'Mekaniker - Technical prep work with time banking',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Bilpleiespesialist Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid,
  'Bilpleiespesialist',
  'badge',
  'Bilpleiespesialist - Cosmetic prep work with time banking',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Daglig leder Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  '2cd122c5-2c28-43b3-ac0f-dd2301516641'::uuid,
  'Daglig leder',
  'badge',
  'Daglig leder - Read-only access to all dealership data',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- Økonomiansvarlig Policy
INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)
VALUES (
  '095acd4c-3c0e-4f17-858d-4300877c5128'::uuid,
  'Økonomiansvarlig',
  'badge',
  'Økonomiansvarlig - Financial data access and pricing',
  NULL,
  true,
  false,
  true
) ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- PERMISSIONS
-- =============================================================================


=== NYBILSELGER POLICY ===

-- Nybilselger: READ cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"_and": [{"car_type": {"_eq": "nybil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}',
  NULL,
  NULL,
  '*',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"car_type": {"_eq": "nybil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'vin,license_plate,brand,model,model_year,color,order_number,customer_name,customer_phone,customer_email,status,accessories,sale_price,sold_at,delivered_to_customer_at,seller_notes',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: DELETE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'delete',
  '{"_and": [{"car_type": {"_eq": "nybil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_eq": "ny_ordre"}}]}',
  NULL,
  NULL,
  '*',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  'id,first_name,last_name,email,avatar,dealership_id',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;

-- Nybilselger: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  'af762edd-da63-48c4-978d-c215ff239d58'::uuid
) ON CONFLICT DO NOTHING;


=== BRUKTBILSELGER POLICY ===

-- Bruktbilselger: READ cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'read',
  '{"car_type": {"_eq": "bruktbil"}}',
  NULL,
  NULL,
  '*',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"car_type": {"_eq": "bruktbil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'vin,license_plate,brand,model,model_year,color,status,sale_price,sold_at,delivered_to_customer_at,seller_notes',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: DELETE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'delete',
  '{"_and": [{"car_type": {"_eq": "bruktbil"}}, {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_eq": "innbytte_registrert"}}]}',
  NULL,
  NULL,
  '*',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  'id,first_name,last_name,email,avatar,dealership_id',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;

-- Bruktbilselger: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '68ac5207-84ff-41d9-a936-dfcb8258cd93'::uuid
) ON CONFLICT DO NOTHING;


=== DELELAGER POLICY ===

-- Delelager: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"_or": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}]}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'status,accessories,parts_ordered_seller_at,parts_arrived_seller_at,parts_ordered_prep_at,parts_arrived_prep_at,parts_notes',
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid
) ON CONFLICT DO NOTHING;

-- Delelager: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid
) ON CONFLICT DO NOTHING;

-- Delelager: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  'id,first_name,last_name,email,avatar,dealership_id',
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid
) ON CONFLICT DO NOTHING;

-- Delelager: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid
) ON CONFLICT DO NOTHING;

-- Delelager: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid
) ON CONFLICT DO NOTHING;

-- Delelager: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  'fcb8459f-0364-42b2-9e85-42c2bfe0f464'::uuid
) ON CONFLICT DO NOTHING;


=== MOTTAKSKONTROLLØR POLICY ===

-- Mottakskontrollør: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"_or": [{"status": {"_eq": "ankommet_klargjoring"}}, {"status": {"_eq": "mottakskontroll_p\u00e5g\u00e5r"}}, {"status": {"_eq": "mottakskontroll_avvik"}}]}]}',
  NULL,
  NULL,
  'status,arrived_prep_center_at,inspection_completed_at,inspection_approved,inspection_notes',
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  'id,first_name,last_name,email,avatar,dealership_id',
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid
) ON CONFLICT DO NOTHING;

-- Mottakskontrollør: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '8270f1c5-4277-466f-849d-c994ca07c366'::uuid
) ON CONFLICT DO NOTHING;


=== BOOKING POLICY ===

-- Booking: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'status,scheduled_technical_date,scheduled_technical_time,assigned_mechanic_id,estimated_technical_hours,scheduled_cosmetic_date,scheduled_cosmetic_time,assigned_detailer_id,estimated_cosmetic_hours,ready_for_delivery_at,delivered_to_dealership_at',
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid
) ON CONFLICT DO NOTHING;

-- Booking: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid
) ON CONFLICT DO NOTHING;

-- Booking: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid
) ON CONFLICT DO NOTHING;

-- Booking: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid
) ON CONFLICT DO NOTHING;

-- Booking: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid
) ON CONFLICT DO NOTHING;

-- Booking: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '2a624d27-4c31-4657-ae22-ef0e4a60a718'::uuid
) ON CONFLICT DO NOTHING;


=== MEKANIKER POLICY ===

-- Mekaniker: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"assigned_mechanic_id": {"_eq": "$CURRENT_USER"}}, {"_or": [{"status": {"_eq": "planlagt_teknisk"}}, {"status": {"_eq": "teknisk_p\u00e5g\u00e5r"}}]}]}',
  NULL,
  NULL,
  'status,technical_started_at,technical_completed_at,technical_notes',
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid
) ON CONFLICT DO NOTHING;

-- Mekaniker: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid
) ON CONFLICT DO NOTHING;

-- Mekaniker: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  'id,first_name,last_name,email,avatar,dealership_id',
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid
) ON CONFLICT DO NOTHING;

-- Mekaniker: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid
) ON CONFLICT DO NOTHING;

-- Mekaniker: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid
) ON CONFLICT DO NOTHING;

-- Mekaniker: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  'fb31586f-437b-4986-a1f7-d1d8abebed99'::uuid
) ON CONFLICT DO NOTHING;


=== BILPLEIESPESIALIST POLICY ===

-- Bilpleiespesialist: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"prep_center_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"assigned_detailer_id": {"_eq": "$CURRENT_USER"}}, {"_or": [{"status": {"_eq": "planlagt_kosmetisk"}}, {"status": {"_eq": "kosmetisk_p\u00e5g\u00e5r"}}]}]}',
  NULL,
  NULL,
  'status,cosmetic_started_at,cosmetic_completed_at,cosmetic_notes',
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  'id,first_name,last_name,email,avatar,dealership_id',
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: CREATE directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'create',
  NULL,
  NULL,
  NULL,
  '*',
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid
) ON CONFLICT DO NOTHING;

-- Bilpleiespesialist: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '31880988-8f2c-4528-9fb7-4a5da69a265f'::uuid
) ON CONFLICT DO NOTHING;


=== DAGLIG LEDER POLICY ===

-- Daglig leder: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '2cd122c5-2c28-43b3-ac0f-dd2301516641'::uuid
) ON CONFLICT DO NOTHING;

-- Daglig leder: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '2cd122c5-2c28-43b3-ac0f-dd2301516641'::uuid
) ON CONFLICT DO NOTHING;

-- Daglig leder: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  '2cd122c5-2c28-43b3-ac0f-dd2301516641'::uuid
) ON CONFLICT DO NOTHING;

-- Daglig leder: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '2cd122c5-2c28-43b3-ac0f-dd2301516641'::uuid
) ON CONFLICT DO NOTHING;


=== ØKONOMIANSVARLIG POLICY ===

-- Økonomiansvarlig: UPDATE cars
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'cars',
  'update',
  '{"_and": [{"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}}, {"status": {"_neq": "arkivert"}}]}',
  NULL,
  NULL,
  'purchase_price,sale_price,prep_cost',
  '095acd4c-3c0e-4f17-858d-4300877c5128'::uuid
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: READ dealership
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'dealership',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '095acd4c-3c0e-4f17-858d-4300877c5128'::uuid
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: READ directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '095acd4c-3c0e-4f17-858d-4300877c5128'::uuid
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: UPDATE directus_users
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_users',
  'update',
  '{"id": {"_eq": "$CURRENT_USER"}}',
  NULL,
  NULL,
  'first_name,last_name,avatar,email,password',
  '095acd4c-3c0e-4f17-858d-4300877c5128'::uuid
) ON CONFLICT DO NOTHING;

-- Økonomiansvarlig: READ directus_files
INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)
VALUES (
  'directus_files',
  'read',
  NULL,
  NULL,
  NULL,
  '*',
  '095acd4c-3c0e-4f17-858d-4300877c5128'::uuid
) ON CONFLICT DO NOTHING;

COMMIT;

-- =============================================================================
-- Import complete!
-- =============================================================================

-- Policy UUIDs for linking to roles:
-- Nybilselger: af762edd-da63-48c4-978d-c215ff239d58
-- Bruktbilselger: 68ac5207-84ff-41d9-a936-dfcb8258cd93
-- Delelager: fcb8459f-0364-42b2-9e85-42c2bfe0f464
-- Mottakskontrollør: 8270f1c5-4277-466f-849d-c994ca07c366
-- Booking: 2a624d27-4c31-4657-ae22-ef0e4a60a718
-- Mekaniker: fb31586f-437b-4986-a1f7-d1d8abebed99
-- Bilpleiespesialist: 31880988-8f2c-4528-9fb7-4a5da69a265f
-- Daglig leder: 2cd122c5-2c28-43b3-ac0f-dd2301516641
-- Økonomiansvarlig: 095acd4c-3c0e-4f17-858d-4300877c5128
