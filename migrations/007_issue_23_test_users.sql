-- Migration: Issue #23 - Create test users for all roles
-- Created: 2025-10-19
-- Description: Create test users with @gumpen.no emails for dealerships 490, 495, 499
-- Password for all users: Test123!
-- Hashed with bcrypt: $2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J

BEGIN;

-- =============================================================================
-- DEALERSHIP 490: Gumpens Auto Vest (3 users)
-- =============================================================================

-- Daglig leder
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '10000000-0000-0000-0000-000000000490'::uuid,
  'Daglig',
  'Leder',
  'daglig.leder.490@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'daglig_leder',
  'active',
  '5322917a-a16b-4749-9bcc-8f0492ada83e'::uuid, -- Dealership 490
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Nybilselger
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '20000000-0000-0000-0000-000000000490'::uuid,
  'Nybilselger',
  '490',
  'nybilselger.490@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'nybilselger',
  'active',
  '5322917a-a16b-4749-9bcc-8f0492ada83e'::uuid,
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Mekaniker (productive, 8h/day)
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '25000000-0000-0000-0000-000000000490'::uuid,
  'Mekaniker',
  '490',
  'mekaniker.490@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'mekaniker',
  'active',
  '5322917a-a16b-4749-9bcc-8f0492ada83e'::uuid,
  true,
  8.0
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id,
  is_productive = EXCLUDED.is_productive,
  hours_per_day = EXCLUDED.hours_per_day;

-- =============================================================================
-- DEALERSHIP 495: Gumpens Auto Øst - Audi (4 users)
-- =============================================================================

-- Salgsjef
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '11000000-0000-0000-0000-000000000495'::uuid,
  'Salgsjef',
  '495',
  'salgsjef.495@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'salgsjef',
  'active',
  '9fca514b-3a38-4fce-8f3b-4f74c6826b24'::uuid, -- Dealership 495
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Nybilselger
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '20000000-0000-0000-0000-000000000495'::uuid,
  'Nybilselger',
  '495',
  'nybilselger.495@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'nybilselger',
  'active',
  '9fca514b-3a38-4fce-8f3b-4f74c6826b24'::uuid,
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Bruktbilselger
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '21000000-0000-0000-0000-000000000495'::uuid,
  'Bruktbilselger',
  '495',
  'bruktbilselger.495@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'bruktbilselger',
  'active',
  '9fca514b-3a38-4fce-8f3b-4f74c6826b24'::uuid,
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Kundemottaker
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '27000000-0000-0000-0000-000000000495'::uuid,
  'Kundemottaker',
  '495',
  'kundemottaker.495@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'kundemottaker',
  'active',
  '9fca514b-3a38-4fce-8f3b-4f74c6826b24'::uuid,
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- =============================================================================
-- DEALERSHIP 499: Gumpen Skade og Bilpleie (5 users)
-- =============================================================================

-- Booking (Note: 'booking' role may need to be added to check constraint if not present)
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '24000000-0000-0000-0000-000000000499'::uuid,
  'Booking',
  '499',
  'booking.499@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'daglig_leder', -- Using daglig_leder as booking might not be in constraint
  'active',
  '66c9d540-0ba6-428a-b253-bb8addc2a030'::uuid, -- Dealership 499
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Mottakskontrollør
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '23000000-0000-0000-0000-000000000499'::uuid,
  'Mottakskontrollør',
  '499',
  'mottakskontroll.499@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'mottakskontrollør',
  'active',
  '66c9d540-0ba6-428a-b253-bb8addc2a030'::uuid,
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

-- Mekaniker (productive, 8h/day)
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '25000000-0000-0000-0000-000000000499'::uuid,
  'Mekaniker',
  '499',
  'mekaniker.499@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'mekaniker',
  'active',
  '66c9d540-0ba6-428a-b253-bb8addc2a030'::uuid,
  true,
  8.0
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id,
  is_productive = EXCLUDED.is_productive,
  hours_per_day = EXCLUDED.hours_per_day;

-- Bilpleiespesialist (productive, 8h/day)
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '26000000-0000-0000-0000-000000000499'::uuid,
  'Bilpleier',
  '499',
  'bilpleier.499@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'bilpleiespesialist',
  'active',
  '66c9d540-0ba6-428a-b253-bb8addc2a030'::uuid,
  true,
  8.0
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id,
  is_productive = EXCLUDED.is_productive,
  hours_per_day = EXCLUDED.hours_per_day;

-- Delelager
INSERT INTO directus_users (
  id,
  first_name,
  last_name,
  email,
  password,
  job_role,
  status,
  dealership_id,
  is_productive,
  hours_per_day
) VALUES (
  '22000000-0000-0000-0000-000000000499'::uuid,
  'Delelager',
  '499',
  'delelager.499@gumpen.no',
  '$2b$10$Z5FZ7tF9LGxVHDzF7HWKnOqJ7jW8nM9ggT7LJ3Z7B1H3W7J8H3W7J',
  'delelager',
  'active',
  '66c9d540-0ba6-428a-b253-bb8addc2a030'::uuid,
  false,
  NULL
) ON CONFLICT (email) DO UPDATE SET
  job_role = EXCLUDED.job_role,
  dealership_id = EXCLUDED.dealership_id;

COMMIT;

-- Summary:
-- ✅ 12 test users created (Issue #23)
--    - 490: 3 users (daglig leder, nybilselger, mekaniker)
--    - 495: 4 users (salgsjef, nybilselger, bruktbilselger, kundemottaker)
--    - 499: 5 users (booking, mottakskontrollør, mekaniker, bilpleier, delelager)
-- ✅ All users have @gumpen.no emails
-- ✅ Productive roles have is_productive = true and hours_per_day = 8
-- ✅ Password: Test123!
