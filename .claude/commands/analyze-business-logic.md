# Agent 1: Business Logic Analyzer

**Role:** Extract and validate business rules from DirectApp codebase documentation

---

## Task

You are **Agent 1** in the Multi-Agent Orchestration System for DirectApp analysis.

Your mission: Analyze DirectApp's Norwegian car dealership business logic comprehensively.

---

## Step-by-Step Analysis

### 1. Read Documentation

Read these files in order:
- `GUMPEN_SYSTEM_DESIGN.md` - Core system design and business requirements
- `USER_STORIES_COLLECTION_MAPPING.md` - User stories and collection mappings
- `KANBAN.md` - Current development status and priorities
- `CARS_COLLECTION_COMPLETION.md` - Cars workflow completion status
- `.claude/SCHEMA_ANALYSIS.md` - Schema analysis

### 2. Extract Business Rules

Identify and document:
- Workflow state transitions (e.g., registered → booking → workshop_received)
- Business constraints (e.g., "cannot skip workflow states")
- Validation rules (e.g., "sold cars cannot be modified")
- Deadline enforcement (e.g., workshop completion deadlines)
- Data isolation rules (e.g., dealership data separation)
- Assignment logic (e.g., who can be assigned to cars)

### 3. Map User Stories to Implementation

For each user story:
- Identify which collection(s) implement it
- Check if fully implemented, partially implemented, or not started
- Note any gaps or missing features
- Verify business logic is enforced

### 4. Validate Workflow Logic

Check:
- Valid state transitions
- Invalid state transitions (should be blocked)
- Required fields per state
- Workflow guard implementation
- Audit logging

### 5. Identify Gaps

Find:
- Documented requirements not implemented
- Business rules not enforced
- Missing validations
- Workflow holes
- Integration gaps

---

## Output Format

Provide your analysis as JSON:

```json
{
  "analysis_metadata": {
    "agent": "Agent 1: Business Logic Analyzer",
    "timestamp": "2025-10-29T...",
    "duration_minutes": 15,
    "files_analyzed": 5
  },
  "business_rules": [
    {
      "id": "BR-001",
      "domain": "workflow",
      "rule": "Cars cannot move from registered to sold without intermediate states",
      "source": "GUMPEN_SYSTEM_DESIGN.md:Lines 45-67",
      "implemented": true,
      "location": "extensions/directus-extension-workflow-guard/src/index.ts",
      "validation": "Tested and working"
    },
    {
      "id": "BR-002",
      "domain": "access_control",
      "rule": "Mechanics can only see cars assigned to them",
      "source": "USER_STORIES_COLLECTION_MAPPING.md",
      "implemented": true,
      "location": "Role permissions for 'mechanic' role",
      "validation": "Confirmed via permissions audit"
    }
  ],
  "workflow_analysis": {
    "states": [
      "registered", "booking", "workshop_received", "tech_completed",
      "cosmetic_completed", "quality_check", "ready_for_sale", "sold"
    ],
    "valid_transitions": [
      "registered → booking",
      "booking → workshop_received",
      "quality_check → tech_completed (rework allowed)"
    ],
    "blocked_transitions": [
      "registered → ready_for_sale (skipping states)",
      "sold → any state (finalized)"
    ],
    "enforcement": "Implemented in workflow-guard hook"
  },
  "user_story_coverage": {
    "total_stories": 45,
    "fully_implemented": 38,
    "partially_implemented": 5,
    "not_started": 2,
    "coverage_percentage": 84.4,
    "details": [
      {
        "story_id": "US-001",
        "title": "Register incoming car",
        "status": "fully_implemented",
        "collections": ["cars"],
        "features": ["Basic fields", "Vehicle lookup", "Dealership assignment"]
      },
      {
        "story_id": "US-015",
        "title": "Workshop deadline tracking",
        "status": "partially_implemented",
        "collections": ["cars"],
        "features": ["Deadline field exists"],
        "gaps": ["No automated monitoring", "No notifications"]
      }
    ]
  },
  "gaps": [
    {
      "id": "GAP-001",
      "severity": "high",
      "category": "validation",
      "description": "Missing validation for workshop deadline enforcement",
      "impact": "Mechanics may miss deadlines without notification",
      "affected_user_stories": ["US-015"],
      "recommendation": "Add deadline validation hook or flow operation"
    },
    {
      "id": "GAP-002",
      "severity": "medium",
      "category": "business_logic",
      "description": "No automatic quality check assignment",
      "impact": "Manual assignment creates bottlenecks",
      "affected_user_stories": ["US-022"],
      "recommendation": "Add flow to auto-assign quality checks"
    }
  ],
  "strengths": [
    "Comprehensive workflow guard prevents invalid state transitions",
    "Good data isolation between dealerships",
    "Vehicle lookup integration reduces manual data entry"
  ],
  "weaknesses": [
    "Limited automation in workflow transitions",
    "No deadline monitoring system",
    "Manual quality check assignment"
  ],
  "metrics": {
    "business_rule_coverage": "92%",
    "workflow_enforcement_score": "9.0/10",
    "user_story_implementation": "84.4%",
    "validation_completeness": "85%"
  }
}
```

---

## Focus Areas

Prioritize:
1. **Critical Business Rules** - Payment, workflow state, data isolation
2. **User Story Gaps** - Features documented but not implemented
3. **Workflow Validation** - State transitions, required fields
4. **Automation Opportunities** - Manual processes that should be automated

---

## Output Location

Save your analysis to:
- `SYSTEM_ANALYSIS_FINDINGS.md` (append to Business Logic section)
- Or output JSON for Agent 6 to synthesize

---

**Success Metric:** 100% of documented business rules mapped to implementation status
