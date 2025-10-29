# Agent 2: Schema Design Auditor

**Role:** Evaluate database architecture, collection design, and configuration logic

---

## Task

You are **Agent 2** in the Multi-Agent Orchestration System for DirectApp analysis.

Your mission: Audit DirectApp's Directus schema design comprehensively.

---

## Step-by-Step Audit

### 1. Read Schema Documentation

Read these files:
- `.claude/SCHEMA_ANALYSIS.md` - Schema analysis
- `ALL_COLLECTIONS_OPTIMIZATION_COMPLETE.md` - Collection optimization status
- `CARS_COLLECTION_AUDIT.md` - Cars collection audit
- `SCHEMA_IMPROVEMENTS_SUMMARY.md` - Schema improvements

### 2. Query Live Schema

Use MCP tools to fetch current schema:
```typescript
// Get all collections
mcp__directapp-dev__schema({})

// Get detailed schema for key collections
mcp__directapp-dev__schema({ keys: ["cars", "users", "organizations", "dealerships"] })
```

### 3. Evaluate Collection Structure

For each collection, assess:
- **Purpose Clarity** - Is the collection's purpose clear?
- **Field Appropriateness** - Are field types correct for their data?
- **Naming Conventions** - Consistent kebab-case, clear names?
- **Required Fields** - Appropriate use of required/nullable?
- **Default Values** - Sensible defaults set?
- **Validation Rules** - Proper constraints in place?

### 4. Check Configuration Logic

Review collection meta configuration:
- **Display Templates** - Clear and informative?
- **Archive Configuration** - Status field, archive_value set?
- **Sort Field** - Manual ordering enabled where needed?
- **Singleton Usage** - Appropriate for settings collections?
- **Accountability** - Tracking enabled for audit trails?
- **Icons & Colors** - Consistent visual design?

### 5. Assess Design Philosophy

Evaluate:
- **Normalization Level** - Appropriate level (3NF typical)?
- **Denormalization** - Strategic denormalization where needed?
- **Performance Considerations** - Indices on filtered/sorted fields?
- **Data Integrity** - Foreign keys, constraints properly set?
- **Maintainability** - Easy to understand and extend?
- **Consistency** - Similar patterns across collections?

### 6. Identify Issues

Find:
- Missing indices on frequently queried fields
- Incorrect field types (e.g., string for numbers)
- Missing validation rules
- Inconsistent naming
- Performance bottlenecks
- Data integrity risks

---

## Output Format

Provide your analysis as JSON:

```json
{
  "analysis_metadata": {
    "agent": "Agent 2: Schema Design Auditor",
    "timestamp": "2025-10-29T...",
    "duration_minutes": 20,
    "collections_analyzed": 15
  },
  "collections_audit": {
    "total_collections": 15,
    "compliant": 12,
    "needs_minor_improvement": 2,
    "needs_major_improvement": 1,
    "details": [
      {
        "collection": "cars",
        "status": "compliant",
        "fields_count": 35,
        "relations": 8,
        "score": 9.2,
        "strengths": [
          "Comprehensive field coverage",
          "Good validation rules",
          "Clear display template"
        ],
        "issues": []
      },
      {
        "collection": "workshop_tasks",
        "status": "needs_minor_improvement",
        "fields_count": 12,
        "relations": 3,
        "score": 7.5,
        "strengths": [
          "Clear purpose",
          "Good relations"
        ],
        "issues": [
          {
            "severity": "medium",
            "field": "deadline",
            "issue": "No validation for past dates",
            "recommendation": "Add validation rule: deadline >= $NOW"
          }
        ]
      }
    ]
  },
  "design_philosophy": {
    "normalization_level": "3NF",
    "consistency_score": 8.5,
    "maintainability_score": 9.0,
    "performance_score": 7.8,
    "overall_score": 8.4,
    "assessment": "Well-designed schema with minor optimization opportunities"
  },
  "configuration_analysis": [
    {
      "collection": "cars",
      "display_template": "{{regnr}} - {{make}} {{model}} ({{status}})",
      "display_template_clarity": "excellent",
      "archive_field": "status",
      "archive_value": "archived",
      "sort_field": "sort",
      "accountability": "all",
      "icon": "directions_car",
      "color": "#2196F3",
      "assessment": "Properly configured"
    }
  ],
  "field_type_analysis": {
    "total_fields": 287,
    "correct_types": 278,
    "questionable_types": 9,
    "details": [
      {
        "collection": "cars",
        "field": "price",
        "current_type": "integer",
        "issue": "No decimal support for prices like 249,995.50 NOK",
        "recommendation": "Change to decimal type",
        "severity": "medium"
      }
    ]
  },
  "naming_consistency": {
    "score": 8.8,
    "pattern": "snake_case for fields, kebab-case for collections",
    "violations": [
      {
        "collection": "some_collection",
        "field": "OldFieldName",
        "issue": "PascalCase instead of snake_case",
        "recommendation": "Rename to old_field_name"
      }
    ]
  },
  "index_analysis": {
    "collections_with_indices": 8,
    "collections_without_indices": 7,
    "missing_indices": [
      {
        "collection": "cars",
        "fields": ["dealership_id", "status"],
        "type": "compound",
        "reason": "Frequently filtered together in dealership views",
        "impact": "Slow queries for dealership-specific car listings",
        "recommendation": "Add composite index on (dealership_id, status)"
      },
      {
        "collection": "workshop_tasks",
        "fields": ["assigned_to"],
        "type": "single",
        "reason": "Filtered on user dashboards",
        "impact": "Slower user-specific task loading",
        "recommendation": "Add index on assigned_to"
      }
    ]
  },
  "validation_analysis": {
    "collections_with_validation": 6,
    "collections_without_validation": 9,
    "missing_validations": [
      {
        "collection": "cars",
        "field": "year",
        "missing": "Range validation",
        "recommendation": "Add validation: year >= 1900 AND year <= (current_year + 1)"
      },
      {
        "collection": "workshop_tasks",
        "field": "deadline",
        "missing": "Future date validation",
        "recommendation": "Add validation: deadline >= $NOW"
      }
    ]
  },
  "data_integrity": {
    "score": 9.2,
    "foreign_keys": "properly configured",
    "cascade_rules": "appropriate for business logic",
    "issues": []
  },
  "findings": [
    {
      "id": "SCH-001",
      "severity": "medium",
      "category": "performance",
      "collection": "cars",
      "issue": "Missing compound index on (dealership_id, status)",
      "impact": "Slow queries for dealership-specific car listings (>500ms on 1000+ cars)",
      "recommendation": "Add composite index",
      "effort": "5 minutes"
    },
    {
      "id": "SCH-002",
      "severity": "low",
      "category": "field_type",
      "collection": "cars",
      "field": "price",
      "issue": "Integer type doesn't support decimal prices",
      "impact": "Prices stored as cents, requires conversion in queries",
      "recommendation": "Migrate to decimal type or document convention",
      "effort": "30 minutes (if migrating)"
    },
    {
      "id": "SCH-003",
      "severity": "medium",
      "category": "validation",
      "collection": "workshop_tasks",
      "field": "deadline",
      "issue": "No validation prevents past dates",
      "impact": "Users can set invalid deadlines",
      "recommendation": "Add validation rule",
      "effort": "5 minutes"
    }
  ],
  "strengths": [
    "Consistent naming conventions across most collections",
    "Good use of system fields (user_created, date_created, etc.)",
    "Appropriate normalization level",
    "Clear display templates",
    "Proper accountability tracking"
  ],
  "weaknesses": [
    "Missing indices on frequently queried fields",
    "Some validation rules not enforced at schema level",
    "Inconsistent validation coverage across collections"
  ],
  "quick_wins": [
    "Add missing indices (5 min each)",
    "Add date validation rules (5 min each)",
    "Document price field convention if intentional"
  ],
  "metrics": {
    "overall_design_score": "8.4/10",
    "consistency_score": "8.8/10",
    "validation_completeness": "60%",
    "index_coverage": "53%",
    "maintainability_score": "9.0/10"
  }
}
```

---

## Focus Areas

Prioritize:
1. **Performance Issues** - Missing indices causing slow queries
2. **Data Integrity** - Validation rules, foreign keys
3. **Field Types** - Incorrect types causing conversion overhead
4. **Naming Consistency** - Violations of conventions

---

## Output Location

Save your analysis to:
- `SYSTEM_ANALYSIS_FINDINGS.md` (append to Schema Design section)
- Or output JSON for Agent 6 to synthesize

---

**Success Metric:** Schema design score > 8.5/10 across all categories
