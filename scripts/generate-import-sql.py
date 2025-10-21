#!/usr/bin/env python3
"""
Generate SQL import script with real UUIDs from JSON policy template
"""

import json
import uuid
from pathlib import Path

# Load policies JSON
policies_file = Path(__file__).parent / '../schema/policies/complete-role-policies.json'
with open(policies_file) as f:
    data = json.load(f)

# Generate real UUIDs for each policy
policy_uuid_map = {}
for policy in data['policies']:
    policy_uuid_map[policy['id']] = str(uuid.uuid4())

print("-- Import Role-Based Access Control Policies")
print("-- Generated from schema/policies/complete-role-policies.json")
print("-- AUTO-GENERATED with real UUIDs\n")
print("BEGIN;\n")

print("-- =============================================================================")
print("-- CREATE 9 ROLE POLICIES")
print("-- =============================================================================\n")

for policy in data['policies']:
    policy_id = policy_uuid_map[policy['id']]
    name = policy['name']
    description = policy['description']

    print(f"-- {name} Policy")
    print(f"INSERT INTO directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access)")
    print(f"VALUES (")
    print(f"  '{policy_id}'::uuid,")
    print(f"  '{name}',")
    print(f"  'badge',")
    print(f"  '{description}',")
    print(f"  NULL,")
    print(f"  true,")
    print(f"  false,")
    print(f"  true")
    print(f") ON CONFLICT (id) DO NOTHING;\n")

print("-- =============================================================================")
print("-- PERMISSIONS")
print("-- =============================================================================\n")

for permission in data['permissions']:
    # Skip comments
    if 'comment' in permission:
        print(f"\n-- {permission['comment']}\n")
        continue

    # Replace policy ID with real UUID
    policy_id = policy_uuid_map[permission['policy']]
    collection = permission['collection']
    action = permission['action']

    # Format permissions/presets/fields for SQL
    permissions_sql = 'NULL'
    if permission.get('permissions'):
        permissions_json = json.dumps(permission['permissions']).replace("'", "''")
        permissions_sql = f"'{permissions_json}'"

    validation_sql = 'NULL'
    if permission.get('validation'):
        validation_json = json.dumps(permission['validation']).replace("'", "''")
        validation_sql = f"'{validation_json}'"

    presets_sql = 'NULL'
    if permission.get('presets'):
        presets_json = json.dumps(permission['presets']).replace("'", "''")
        presets_sql = f"'{presets_json}'"

    fields_sql = 'NULL'
    if permission.get('fields'):
        if isinstance(permission['fields'], list):
            fields_str = ','.join(permission['fields'])
        else:
            fields_str = permission['fields']
        fields_sql = f"'{fields_str}'"

    policy_name = next((p['name'] for p in data['policies'] if p['id'] == permission['policy']), '')

    print(f"-- {policy_name}: {action.upper()} {collection}")
    print(f"INSERT INTO directus_permissions (collection, action, permissions, validation, presets, fields, policy)")
    print(f"VALUES (")
    print(f"  '{collection}',")
    print(f"  '{action}',")
    print(f"  {permissions_sql},")
    print(f"  {validation_sql},")
    print(f"  {presets_sql},")
    print(f"  {fields_sql},")
    print(f"  '{policy_id}'::uuid")
    print(f") ON CONFLICT DO NOTHING;\n")

print("COMMIT;\n")

print("-- =============================================================================")
print("-- Import complete!")
print("-- =============================================================================\n")

print("-- Policy UUIDs for linking to roles:")
for template_id, real_id in policy_uuid_map.items():
    policy_name = next((p['name'] for p in data['policies'] if p['id'] == template_id), template_id)
    print(f"-- {policy_name}: {real_id}")
