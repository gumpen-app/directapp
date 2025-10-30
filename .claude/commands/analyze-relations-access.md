# Agent 3: Relations & Access Policy Validator

**Role:** Verify relationship integrity and role-based access control

---

## Task

You are **Agent 3** in the Multi-Agent Orchestration System for DirectApp analysis.

Your mission: Validate DirectApp's relationships and access policies comprehensively.

---

## Step-by-Step Validation

### 1. Read Access Documentation

Read these files:
- `docs/ROLE_PERMISSIONS_PLAN.md` - Role permissions plan
- `FIELD_PERMISSIONS_GUIDE.md` - Field-level permissions
- `.claude/SCHEMA_ANALYSIS.md` - Schema and relations

### 2. Query Relations

Use MCP tools to fetch all relations:
```typescript
// Get all relations
mcp__directapp-dev__relations({ action: "read" })

// Check specific collection relations
mcp__directapp-dev__schema({ keys: ["cars", "users", "dealerships", "organizations"] })
```

### 3. Validate Relationship Integrity

For each relation, check:
- **Type Correctness** - M2O, O2M, M2M, M2A properly configured?
- **Cascade Rules** - ON DELETE/UPDATE rules appropriate?
- **Referential Integrity** - Foreign keys point to valid collections?
- **Junction Tables** - M2M/M2A junction tables properly structured?
- **Field Types** - UUID fields for relations, correct types?

### 4. Audit Access Policies

For each role (admin, dealership_admin, salesperson, mechanic):
- **Collection Access** - Can read/create/update/delete which collections?
- **Field Access** - Which fields can they see/edit?
- **Filters** - Data isolation via dealership_id filters?
- **Workflow Constraints** - Can only update certain states?

### 5. Verify Data Isolation

Check multi-tenancy:
- **Dealership Isolation** - Users only see their dealership's data?
- **Filter Application** - dealership_id filters on all relevant collections?
- **Role Enforcement** - Different roles have different visibility?
- **Cross-Dealership Access** - Admins can see all, others cannot?

### 6. Identify Issues

Find:
- Missing cascade delete rules (orphaned records risk)
- Incorrect relation types
- Permission gaps (users can't perform required actions)
- Over-permissioned roles (users can do too much)
- Missing data isolation filters
- Inconsistent access patterns

---

## Output Format

Provide your analysis as JSON:

```json
{
  "analysis_metadata": {
    "agent": "Agent 3: Relations & Access Policy Validator",
    "timestamp": "2025-10-29T...",
    "duration_minutes": 20,
    "relations_analyzed": 45,
    "roles_audited": 4
  },
  "relations_audit": {
    "total_relations": 45,
    "valid": 42,
    "has_issues": 3,
    "by_type": {
      "m2o": 28,
      "o2m": 12,
      "m2m": 4,
      "m2a": 1
    },
    "details": [
      {
        "relation_id": "REL-001",
        "collection": "cars",
        "field": "assigned_to",
        "type": "m2o",
        "related_collection": "directus_users",
        "status": "has_issue",
        "cascade_delete": "NO ACTION",
        "cascade_update": "NO ACTION",
        "issue": "Missing ON DELETE SET NULL rule",
        "impact": "If user deleted, assigned_to becomes invalid reference",
        "recommendation": "Change to ON DELETE SET NULL",
        "severity": "medium"
      },
      {
        "relation_id": "REL-002",
        "collection": "cars",
        "field": "dealership_id",
        "type": "m2o",
        "related_collection": "dealerships",
        "status": "valid",
        "cascade_delete": "NO ACTION",
        "cascade_update": "NO ACTION",
        "rationale": "NO ACTION appropriate - dealerships should not be deleted if they have cars"
      }
    ]
  },
  "relation_issues": [
    {
      "id": "REL-ISS-001",
      "severity": "medium",
      "relation": "cars.assigned_to → directus_users",
      "issue": "Missing ON DELETE SET NULL",
      "impact": "Orphaned cars if user deleted",
      "recommendation": "Add cascade rule: ON DELETE SET NULL",
      "effort": "5 minutes"
    },
    {
      "id": "REL-ISS-002",
      "severity": "low",
      "relation": "workshop_tasks.car_id → cars",
      "issue": "ON DELETE NO ACTION",
      "impact": "Cannot delete cars with workshop tasks",
      "recommendation": "Consider CASCADE or restrict via business logic",
      "effort": "10 minutes + testing"
    }
  ],
  "access_policies": {
    "roles_audited": ["admin", "dealership_admin", "salesperson", "mechanic"],
    "total_policies": 78,
    "coverage": "95%",
    "details": [
      {
        "role": "admin",
        "access_level": "full",
        "collections": "all",
        "filters": "none (can see all dealerships)",
        "field_restrictions": "none",
        "assessment": "Properly configured"
      },
      {
        "role": "dealership_admin",
        "access_level": "dealership",
        "collections": ["cars", "workshop_tasks", "users"],
        "filters": {
          "cars": "dealership_id = $CURRENT_USER.dealership_id",
          "workshop_tasks": "car_id.dealership_id = $CURRENT_USER.dealership_id"
        },
        "field_restrictions": [
          "Cannot edit: cost (sensitive financial data)"
        ],
        "assessment": "Properly configured"
      },
      {
        "role": "salesperson",
        "access_level": "dealership",
        "collections": ["cars (read/update limited fields)"],
        "filters": {
          "cars": "dealership_id = $CURRENT_USER.dealership_id AND status IN ['ready_for_sale', 'sold']"
        },
        "field_restrictions": [
          "Cannot edit: workshop fields",
          "Cannot edit: internal_notes"
        ],
        "assessment": "Properly configured"
      },
      {
        "role": "mechanic",
        "access_level": "assigned_only",
        "collections": ["cars (read/update workshop fields only)", "workshop_tasks"],
        "filters": {
          "cars": "assigned_to = $CURRENT_USER",
          "workshop_tasks": "assigned_to = $CURRENT_USER"
        },
        "field_restrictions": [
          "Can edit: tech_status, tech_notes, tech_completed_date",
          "Cannot edit: price, sales fields"
        ],
        "issues": [
          {
            "severity": "low",
            "issue": "Cannot update tech_completed_date field",
            "impact": "Must ask admin to mark work complete",
            "recommendation": "Grant field-level update permission"
          }
        ]
      }
    ]
  },
  "permission_gaps": [
    {
      "id": "PERM-GAP-001",
      "severity": "low",
      "role": "mechanic",
      "action": "update",
      "collection": "cars",
      "field": "tech_completed_date",
      "issue": "Cannot update completion date",
      "impact": "Workflow friction - must ask admin",
      "recommendation": "Grant field-level update permission",
      "effort": "2 minutes"
    },
    {
      "id": "PERM-GAP-002",
      "severity": "medium",
      "role": "salesperson",
      "action": "read",
      "collection": "cars",
      "field": "internal_cost",
      "issue": "Cannot see cost for margin calculation",
      "impact": "Cannot calculate profit margins",
      "recommendation": "Grant read permission or create calculated field",
      "effort": "5 minutes"
    }
  ],
  "data_isolation": {
    "compliant": true,
    "mechanism": "dealership_id filter on roles",
    "coverage": "100% of multi-tenant collections",
    "details": [
      {
        "collection": "cars",
        "isolation": "dealership_id filter",
        "roles_affected": ["dealership_admin", "salesperson", "mechanic"],
        "test_status": "validated"
      },
      {
        "collection": "workshop_tasks",
        "isolation": "car_id.dealership_id filter (via relation)",
        "roles_affected": ["dealership_admin", "mechanic"],
        "test_status": "validated"
      }
    ],
    "cross_dealership_access": {
      "admin": "allowed (intentional)",
      "others": "blocked (correct)"
    }
  },
  "cascade_rules_analysis": {
    "appropriate": [
      "organizations.dealerships: ON DELETE NO ACTION (protect data)",
      "dealerships.cars: ON DELETE NO ACTION (prevent accidents)"
    ],
    "questionable": [
      {
        "relation": "cars.assigned_to",
        "current": "NO ACTION",
        "recommendation": "SET NULL",
        "reason": "Users may be removed, cars should remain"
      }
    ]
  },
  "referential_integrity": {
    "score": 9.5,
    "broken_references": 0,
    "orphaned_records": 0,
    "assessment": "Excellent - all foreign keys valid"
  },
  "findings": [
    {
      "id": "ACC-001",
      "severity": "medium",
      "category": "relations",
      "issue": "Missing SET NULL cascade on user assignments",
      "impact": "Potential orphaned car assignments",
      "recommendation": "Add ON DELETE SET NULL to cars.assigned_to",
      "effort": "5 minutes"
    },
    {
      "id": "ACC-002",
      "severity": "low",
      "category": "permissions",
      "issue": "Mechanic cannot update completion date",
      "impact": "Workflow friction",
      "recommendation": "Grant field permission",
      "effort": "2 minutes"
    }
  ],
  "strengths": [
    "Excellent data isolation between dealerships",
    "Comprehensive role-based access control",
    "No referential integrity issues",
    "Appropriate cascade rules for most relations"
  ],
  "weaknesses": [
    "Some cascade rules could be improved",
    "Minor permission gaps for mechanics",
    "No field-level audit logging for sensitive fields"
  ],
  "quick_wins": [
    "Fix cascade rules (5 min each)",
    "Grant mechanic completion date permission (2 min)",
    "Add salesperson cost read permission (5 min)"
  ],
  "metrics": {
    "relation_integrity": "93.3%",
    "permission_coverage": "95%",
    "data_isolation_compliance": "100%",
    "referential_integrity": "100%",
    "overall_security_score": "8.9/10"
  }
}
```

---

## Focus Areas

Prioritize:
1. **Data Isolation** - Ensure dealerships cannot see each other's data
2. **Referential Integrity** - No broken foreign keys
3. **Cascade Rules** - Appropriate ON DELETE/UPDATE behavior
4. **Permission Gaps** - Users blocked from required actions

---

## Output Location

Save your analysis to:
- `SYSTEM_ANALYSIS_FINDINGS.md` (append to Relations & Access section)
- Or output JSON for Agent 6 to synthesize

---

**Success Metric:** 100% relation integrity, 95%+ permission coverage, 100% data isolation
