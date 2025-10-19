-- Migration: Seed Gumpen dealerships
-- Created: 2025-10-19
-- Description: Creates all Gumpen Auto dealerships with proper multi-site configuration

BEGIN;

-- ============================================
-- INSERT DEALERSHIPS
-- ============================================

-- 1. Gumpens Auto AS (VW) - Kristiansand Vest (Hovedkontor)
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  490,
  'Gumpens Auto AS',
  'Kristiansand Vest',
  'fullskala',
  'VW',
  NULL, -- Hovedkontor
  NULL, -- Gjør egen klargjøring
  true,
  '{"primary": "#001E50", "secondary": "#00B0F0"}'::json,
  true,
  'published'
) RETURNING id;

-- Save 490's ID for later reference
DO $$
DECLARE
  gumpens_auto_id UUID;
BEGIN
  SELECT id INTO gumpens_auto_id FROM dealership WHERE dealership_number = 490;

  -- 2. Gumpen Økonomi Service - Verksted under 490
  INSERT INTO dealership (
    dealership_number,
    dealership_name,
    location,
    dealership_type,
    brand,
    parent_dealership_id,
    prep_center_id,
    does_own_prep,
    brand_colors,
    active,
    status
  ) VALUES (
    4901, -- Sub-number under 490
    'Gumpen Økonomi Service',
    'Kristiansand Vest',
    'verksted',
    'Multi',
    gumpens_auto_id,
    NULL,
    true,
    '{"primary": "#1E3A8A", "secondary": "#F59E0B"}'::json,
    true,
    'published'
  );
END $$;

-- 3. Gumpens Auto Øst (Audi) - Sørlandsparken
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  495,
  'Gumpens Auto Øst',
  'Sørlandsparken, Kristiansand',
  'fullskala',
  'Audi',
  NULL,
  (SELECT id FROM dealership WHERE dealership_number = 499), -- Will be set after 499 is created
  false,
  '{"primary": "#BB0A30", "secondary": "#000000"}'::json,
  true,
  'published'
);

-- 4. G-bil (Skoda) - Sørlandsparken
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  324,
  'G-bil',
  'Sørlandsparken, Kristiansand',
  'fullskala',
  'Skoda',
  NULL,
  (SELECT id FROM dealership WHERE dealership_number = 499),
  false,
  '{"primary": "#4BA82E", "secondary": "#000000"}'::json,
  true,
  'published'
);

-- 5. Gumpen Motor (Multi-brand) - Sørlandsparken
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  325,
  'Gumpen Motor',
  'Sørlandsparken, Kristiansand',
  'fullskala',
  'Multi', -- Nissan, MG, Seres, Subaru
  NULL,
  (SELECT id FROM dealership WHERE dealership_number = 499),
  false,
  '{"primary": "#C3002F", "secondary": "#000000"}'::json,
  true,
  'published'
);

-- 6. Gumpen Skade og Bilpleie (Klargjøringssenter) - Sørlandsparken
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  499,
  'Gumpen Skade og Bilpleie',
  'Sørlandsparken, Kristiansand',
  'klargjøringssenter',
  'Multi',
  NULL,
  NULL, -- Gjør selv
  true,
  '{"primary": "#1E3A8A", "secondary": "#F59E0B"}'::json,
  true,
  'published'
);

-- Update 495, 324, 325 to point to 499 as prep center (now that 499 exists)
UPDATE dealership
SET prep_center_id = (SELECT id FROM dealership WHERE dealership_number = 499)
WHERE dealership_number IN (495, 324, 325);

-- 7. Gumpens Auto Grenland - Østlandet
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  501,
  'Gumpens Auto Grenland',
  'Grenland, Østlandet',
  'fullskala',
  'Multi',
  NULL,
  NULL, -- May do own prep or TBD
  true,
  '{"primary": "#1E3A8A", "secondary": "#F59E0B"}'::json,
  true,
  'published'
);

-- 8. Gumpens Auto Lyngdal - Vestover
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  502,
  'Gumpens Auto Lyngdal',
  'Lyngdal',
  'fullskala',
  'Multi',
  NULL,
  NULL,
  true,
  '{"primary": "#1E3A8A", "secondary": "#F59E0B"}'::json,
  true,
  'published'
);

-- 9. Gumpens Auto Notodden
INSERT INTO dealership (
  dealership_number,
  dealership_name,
  location,
  dealership_type,
  brand,
  parent_dealership_id,
  prep_center_id,
  does_own_prep,
  brand_colors,
  active,
  status
) VALUES (
  503,
  'Gumpens Auto Notodden',
  'Notodden',
  'fullskala',
  'Multi',
  NULL,
  NULL,
  true,
  '{"primary": "#1E3A8A", "secondary": "#F59E0B"}'::json,
  true,
  'published'
);

-- ============================================
-- RESOURCE SHARING CONFIGURATION
-- ============================================

-- 499 (Gumpen Skade og Bilpleie) shares resources with Sørlandsparken dealerships

-- Get UUIDs
DO $$
DECLARE
  dealership_499_id UUID;
  dealership_495_id UUID;
  dealership_324_id UUID;
  dealership_325_id UUID;
  mekanisk_type_id UUID;
  kosmetisk_type_id UUID;
  mottakskontroll_type_id UUID;
BEGIN
  -- Get dealership IDs
  SELECT id INTO dealership_499_id FROM dealership WHERE dealership_number = 499;
  SELECT id INTO dealership_495_id FROM dealership WHERE dealership_number = 495;
  SELECT id INTO dealership_324_id FROM dealership WHERE dealership_number = 324;
  SELECT id INTO dealership_325_id FROM dealership WHERE dealership_number = 325;

  -- Get resource type IDs
  SELECT id INTO mekanisk_type_id FROM resource_types WHERE code = 'mekanisk';
  SELECT id INTO kosmetisk_type_id FROM resource_types WHERE code = 'kosmetisk';
  SELECT id INTO mottakskontroll_type_id FROM resource_types WHERE code = 'mottakskontroll';

  -- 499 → 495 (Audi) - High priority (40h/week allocation)
  INSERT INTO resource_sharing (
    provider_dealership_id,
    consumer_dealership_id,
    resource_type_id,
    enabled,
    priority,
    max_hours_per_week
  ) VALUES
    (dealership_499_id, dealership_495_id, mekanisk_type_id, true, 1, 40.00),
    (dealership_499_id, dealership_495_id, kosmetisk_type_id, true, 1, 40.00),
    (dealership_499_id, dealership_495_id, mottakskontroll_type_id, true, 1, 20.00);

  -- 499 → 324 (Skoda) - Medium priority (30h/week allocation)
  INSERT INTO resource_sharing (
    provider_dealership_id,
    consumer_dealership_id,
    resource_type_id,
    enabled,
    priority,
    max_hours_per_week
  ) VALUES
    (dealership_499_id, dealership_324_id, mekanisk_type_id, true, 2, 30.00),
    (dealership_499_id, dealership_324_id, kosmetisk_type_id, true, 2, 30.00),
    (dealership_499_id, dealership_324_id, mottakskontroll_type_id, true, 2, 15.00);

  -- 499 → 325 (Motor) - Lower priority (20h/week allocation)
  INSERT INTO resource_sharing (
    provider_dealership_id,
    consumer_dealership_id,
    resource_type_id,
    enabled,
    priority,
    max_hours_per_week
  ) VALUES
    (dealership_499_id, dealership_325_id, mekanisk_type_id, true, 3, 20.00),
    (dealership_499_id, dealership_325_id, kosmetisk_type_id, true, 3, 20.00),
    (dealership_499_id, dealership_325_id, mottakskontroll_type_id, true, 3, 10.00);
END $$;

-- ============================================
-- VERIFICATION
-- ============================================

-- Verify dealerships created
DO $$
DECLARE
  dealership_count INTEGER;
  sharing_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO dealership_count FROM dealership;
  SELECT COUNT(*) INTO sharing_count FROM resource_sharing;

  RAISE NOTICE 'Created % dealerships', dealership_count;
  RAISE NOTICE 'Created % resource sharing rules', sharing_count;

  IF dealership_count <> 9 THEN
    RAISE EXCEPTION 'Expected 9 dealerships, got %', dealership_count;
  END IF;

  IF sharing_count <> 9 THEN
    RAISE EXCEPTION 'Expected 9 resource sharing rules, got %', sharing_count;
  END IF;
END $$;

COMMIT;
