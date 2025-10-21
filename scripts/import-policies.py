#!/usr/bin/env python3
"""
Import Role Policies Script

Imports comprehensive role-based policies and permissions into Directus.
Handles authentication properly without bash escaping issues.
"""

import json
import os
import sys
import requests
from pathlib import Path

# Configuration
API_URL = os.getenv('PUBLIC_URL', 'http://localhost:8055')
ADMIN_EMAIL = os.getenv('ADMIN_EMAIL', 'admin@dev.local')
ADMIN_PASSWORD = os.getenv('ADMIN_PASSWORD', 'DevPassword123!')

# Paths
SCRIPT_DIR = Path(__file__).parent
POLICIES_FILE = SCRIPT_DIR / '../schema/policies/complete-role-policies.json'

print('📋 Importing Role-Based Access Control Policies...\n')

def authenticate():
    """Authenticate and get access token"""
    print('🔐 Authenticating as admin...')

    response = requests.post(
        f'{API_URL}/auth/login',
        json={
            'email': ADMIN_EMAIL,
            'password': ADMIN_PASSWORD
        },
        headers={'Content-Type': 'application/json'}
    )

    if not response.ok:
        print(f'❌ Authentication failed: {response.status_code}')
        print(response.text)
        sys.exit(1)

    data = response.json()
    token = data['data']['access_token']
    print('✅ Authenticated\n')
    return token

def create_policy(token, policy_data):
    """Create a policy and return its ID"""
    name = policy_data['name']
    print(f'   ➕ Creating policy: {name}')

    # Remove template ID
    policy_payload = {k: v for k, v in policy_data.items() if k != 'id'}

    response = requests.post(
        f'{API_URL}/policies',
        json=policy_payload,
        headers={
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
    )

    if response.ok:
        policy_id = response.json()['data']['id']
        print(f'      ✅ Created with ID: {policy_id}')
        return policy_id
    else:
        # Check if already exists
        existing_response = requests.get(
            f'{API_URL}/policies',
            params={'filter[name][_eq]': name},
            headers={'Authorization': f'Bearer {token}'}
        )

        if existing_response.ok:
            existing_data = existing_response.json()['data']
            if existing_data:
                policy_id = existing_data[0]['id']
                print(f'      ⚠️  Policy already exists with ID: {policy_id}')
                return policy_id

        print(f'      ❌ Failed to create policy: {response.text}')
        return None

def create_permission(token, permission_data):
    """Create a permission"""
    collection = permission_data['collection']
    action = permission_data['action']

    response = requests.post(
        f'{API_URL}/permissions',
        json=permission_data,
        headers={
            'Authorization': f'Bearer {token}',
            'Content-Type': 'application/json'
        }
    )

    if response.ok or response.status_code == 204:
        return True
    else:
        print(f'   ⚠️  Failed: {collection}.{action} - {response.text}')
        return False

def main():
    # Load policies JSON
    print('📂 Loading policies from JSON...')
    with open(POLICIES_FILE) as f:
        data = json.load(f)

    print(f'   Found {len(data["policies"])} policies and {len(data["permissions"])} permissions\n')

    # Authenticate
    token = authenticate()

    # Create policies and map IDs
    print('📦 Creating policies...\n')
    policy_id_map = {}

    for policy in data['policies']:
        template_id = policy['id']
        real_id = create_policy(token, policy)
        if real_id:
            policy_id_map[template_id] = real_id

    print(f'\n✅ Created/found {len(policy_id_map)} policies\n')

    # Create permissions
    print('🔐 Creating permissions...\n')
    permission_count = 0
    failed_count = 0

    for permission in data['permissions']:
        # Skip comment entries
        if 'comment' in permission:
            print(f'\n{permission["comment"]}')
            continue

        # Replace template policy ID with real UUID
        permission_data = permission.copy()
        template_policy_id = permission['policy']

        if template_policy_id in policy_id_map:
            permission_data['policy'] = policy_id_map[template_policy_id]

            if create_permission(token, permission_data):
                permission_count += 1
                policy_name = next((p['name'] for p in data['policies'] if p['id'] == template_policy_id), template_policy_id)
                print(f'   ✅ {permission["collection"]}.{permission["action"]} ({policy_name})')
            else:
                failed_count += 1
        else:
            print(f'   ⚠️  Skipping {permission["collection"]}.{permission["action"]} - policy not found')
            failed_count += 1

    print(f'\n✅ Created {permission_count} permissions')
    if failed_count > 0:
        print(f'⚠️  Failed to create {failed_count} permissions\n')

    # Summary
    print('\n📊 Import Summary:')
    print(f'   Policies: {len(policy_id_map)}')
    print(f'   Permissions: {permission_count}')
    print('\n🎉 Import complete!\n')

    print('Next steps:')
    print('1. Go to Settings → Roles & Permissions')
    print('2. For each role, assign the corresponding policy via the "Access" tab')
    print('3. Test with test users from Issue #23\n')

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(f'\n❌ Error: {e}')
        import traceback
        traceback.print_exc()
        sys.exit(1)
