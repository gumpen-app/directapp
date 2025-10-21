/**
 * Import Role Policies Script
 *
 * Imports comprehensive role-based policies and permissions into Directus.
 * Based on complete-role-policies.json template.
 */

import { createDirectus, rest, createItem, createItems, readItems } from '@directus/sdk';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Directus connection
const directus = createDirectus(process.env.PUBLIC_URL || 'http://localhost:8055')
  .with(rest());

// Read policies JSON
const policiesPath = path.join(__dirname, '../schema/policies/complete-role-policies.json');
const policiesData = JSON.parse(fs.readFileSync(policiesPath, 'utf8'));

console.log('📋 Importing Role-Based Access Control Policies...\n');

async function importPolicies() {
  try {
    // Login as admin
    console.log('🔐 Authenticating as admin...');

    const authResponse = await fetch(`${process.env.PUBLIC_URL || 'http://localhost:8055'}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: process.env.ADMIN_EMAIL || 'admin@dev.local',
        password: process.env.ADMIN_PASSWORD || 'DevPassword123!'
      })
    });

    if (!authResponse.ok) {
      throw new Error('Authentication failed');
    }

    const { data: { access_token } } = await authResponse.json();
    console.log('✅ Authenticated\n');

    // Helper function to make authenticated requests
    const fetchAuth = async (endpoint, options = {}) => {
      const response = await fetch(`${process.env.PUBLIC_URL || 'http://localhost:8055'}${endpoint}`, {
        ...options,
        headers: {
          'Authorization': `Bearer ${access_token}`,
          'Content-Type': 'application/json',
          ...options.headers
        }
      });

      if (!response.ok) {
        const error = await response.text();
        throw new Error(`API Error: ${response.status} - ${error}`);
      }

      return response.json();
    };

    // Get existing policies to check for duplicates
    console.log('🔍 Checking existing policies...');
    const { data: existingPolicies } = await fetchAuth('/policies');
    const existingPolicyNames = new Set(existingPolicies.map(p => p.name));

    // Create policies
    console.log('📦 Creating policies...\n');
    const policyIdMap = {}; // Map template IDs to actual UUIDs

    for (const policy of policiesData.policies) {
      if (existingPolicyNames.has(policy.name)) {
        console.log(`   ⚠️  Policy "${policy.name}" already exists, skipping...`);
        // Get existing policy ID
        const existing = existingPolicies.find(p => p.name === policy.name);
        policyIdMap[policy.id] = existing.id;
        continue;
      }

      console.log(`   ➕ Creating policy: ${policy.name}`);
      const { id, ...policyData } = policy; // Remove template ID

      const { data: created } = await fetchAuth('/policies', {
        method: 'POST',
        body: JSON.stringify(policyData)
      });

      policyIdMap[policy.id] = created.id; // Map template ID to real UUID
      console.log(`      ✅ Created with ID: ${created.id}`);
    }

    console.log('\n✅ All policies created\n');

    // Create permissions for each policy
    console.log('🔐 Creating permissions...\n');
    let permissionCount = 0;

    for (const permission of policiesData.permissions) {
      // Skip comment entries
      if (permission.comment) {
        console.log(`\n${permission.comment}`);
        continue;
      }

      // Replace template policy ID with real UUID
      const permissionData = {
        ...permission,
        policy: policyIdMap[permission.policy]
      };

      try {
        await fetchAuth('/permissions', {
          method: 'POST',
          body: JSON.stringify(permissionData)
        });

        permissionCount++;
        const policyName = policiesData.policies.find(p => p.id === permission.policy)?.name || permission.policy;
        console.log(`   ✅ ${permission.collection}.${permission.action} (${policyName})`);
      } catch (error) {
        console.log(`   ⚠️  Failed: ${permission.collection}.${permission.action} - ${error.message}`);
      }
    }

    console.log(`\n✅ Created ${permissionCount} permissions\n`);

    // Summary
    console.log('📊 Import Summary:');
    console.log(`   Policies: ${Object.keys(policyIdMap).length}`);
    console.log(`   Permissions: ${permissionCount}`);
    console.log('\n🎉 Import complete! Now link policies to roles via Admin UI or update roles.\n');

    console.log('Next steps:');
    console.log('1. Go to Settings → Roles & Permissions');
    console.log('2. For each role, assign the corresponding policy');
    console.log('3. Test with test users from Issue #23\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

// Run import
importPolicies();
