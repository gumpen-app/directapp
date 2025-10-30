# Agent 6: Planning & Improvement Coordinator

**Role:** Synthesize all findings and create prioritized, actionable improvement plans

---

## Task

You are **Agent 6** in the Multi-Agent Orchestration System for DirectApp analysis.

Your mission: Synthesize findings from all agents into a comprehensive, prioritized improvement roadmap.

---

## Step-by-Step Coordination

### 1. Gather All Agent Outputs

Collect analysis results from:
- **Agent 1:** Business Logic Analysis (business_rules, gaps, user_story_coverage)
- **Agent 2:** Schema Design Audit (collections_audit, design_philosophy, findings)
- **Agent 3:** Relations & Access Validation (relations_audit, permission_gaps, data_isolation)
- **Agent 4:** UX/UI Flow Analysis (user_flow_analysis, friction_points, interface_evaluation)
- **Agent 5:** Extension Recommendations (recommendations, quick_wins, total_impact)

### 2. Read Current Project Status

Review:
- `KANBAN.md` - Current priorities and in-progress work
- `USER_STORIES_COLLECTION_MAPPING.md` - Remaining user stories
- Recent completion reports to understand velocity

### 3. Synthesize Findings

Combine all findings into unified view:
- Total issues found across all agents
- Categorize by severity (critical, high, medium, low)
- Identify cross-cutting concerns (issues appearing in multiple analyses)
- Calculate total potential impact
- Estimate total effort required

### 4. Prioritize Improvements

Use this prioritization framework:

**Priority = (Impact × Urgency) / Effort**

- **Impact:** 1-10 (how much does this improve the system?)
- **Urgency:** 1-10 (how soon must this be fixed?)
- **Effort:** Hours required

**Severity Classification:**
- **Critical:** Blocks workflows, causes data loss, security risk
- **High:** Significant UX/efficiency impact, >10 users affected daily
- **Medium:** Moderate impact, 5-10 users affected weekly
- **Low:** Minor polish, <5 users affected monthly

### 5. Create Implementation Phases

Group improvements into phases:
- **Phase 1: Critical** (1 week) - Must fix immediately
- **Phase 2: High** (2-3 weeks) - Important improvements
- **Phase 3: Medium** (4-6 weeks) - Efficiency gains
- **Phase 4: Low** (Ongoing) - Polish and enhancements

### 6. Estimate Resources

For each improvement:
- Developer hours required
- Dependencies on other improvements
- Skills needed (backend, frontend, design)
- Testing time
- Deployment considerations

### 7. Define Success Metrics

Set measurable KPIs:
- Business logic coverage target
- Schema design score target
- Permission coverage target
- UX satisfaction score target
- Time savings per day/week
- Error reduction percentages

---

## Output Format

Provide your coordination as JSON:

```json
{
  "analysis_metadata": {
    "agent": "Agent 6: Planning & Improvement Coordinator",
    "timestamp": "2025-10-29T...",
    "duration_minutes": 20,
    "agents_synthesized": 5
  },
  "executive_summary": {
    "total_findings": 45,
    "by_severity": {
      "critical": 3,
      "high": 12,
      "medium": 18,
      "low": 12
    },
    "by_category": {
      "business_logic": 8,
      "schema_design": 10,
      "relations_access": 7,
      "ux_ui": 12,
      "extensions": 8
    },
    "total_effort_hours": 85,
    "total_impact_score": 287,
    "average_priority_score": 6.4
  },
  "cross_cutting_concerns": [
    {
      "theme": "Deadline Management",
      "appears_in": ["Agent 1 - Business Logic", "Agent 4 - UX Flow", "Agent 5 - Extensions"],
      "description": "No automated deadline tracking or enforcement",
      "combined_impact": "Critical",
      "recommended_solution": "EXT-001 Workshop Deadline Monitor operation"
    },
    {
      "theme": "Mechanic Permissions",
      "appears_in": ["Agent 3 - Access Policies", "Agent 4 - UX Friction"],
      "description": "Mechanics cannot update completion date",
      "combined_impact": "High",
      "recommended_solution": "Grant field-level permission"
    }
  ],
  "prioritized_improvements": [
    {
      "id": "IMP-001",
      "rank": 1,
      "category": "business_logic",
      "title": "Implement workshop deadline validation and monitoring",
      "priority": "critical",
      "severity": "critical",
      "sources": ["Agent 1 - GAP-001", "Agent 5 - EXT-001"],
      "problem": "No automated deadline tracking causes missed customer commitments",
      "solution": "Create Workshop Deadline Monitor operation + notification flow",
      "impact": {
        "score": 10,
        "description": "Prevents 90% of missed deadlines",
        "users_affected": "All mechanics and admins (20+ users)",
        "time_saved": "15 min/day manual tracking"
      },
      "urgency": {
        "score": 10,
        "reason": "Customer satisfaction risk, reputation damage"
      },
      "effort": {
        "hours": 3,
        "breakdown": [
          "2 hours - Create operation using template",
          "0.5 hours - Configure notification flow",
          "0.5 hours - Testing"
        ]
      },
      "priority_score": 33.3,
      "dependencies": [],
      "skills_required": ["TypeScript", "Directus Flows"],
      "implementation_plan": {
        "phase": "Phase 1 - Critical",
        "estimated_start": "Day 1",
        "estimated_completion": "Day 1",
        "tasks": [
          "Create deadline monitor operation using template",
          "Implement ItemsService query for approaching deadlines",
          "Add notification data formatting",
          "Create Flow with schedule trigger (daily 8 AM)",
          "Add operation to flow",
          "Configure notifications",
          "Test with sample deadlines",
          "Deploy to production",
          "Monitor for 1 week"
        ],
        "testing_approach": [
          "Create test cars with deadlines in 24h, 48h, 72h",
          "Run flow manually",
          "Verify notifications sent",
          "Check audit logs"
        ],
        "rollback_plan": "Disable flow if issues, revert to manual tracking"
      }
    },
    {
      "id": "IMP-002",
      "rank": 2,
      "category": "access_control",
      "title": "Grant mechanic completion date permission",
      "priority": "high",
      "severity": "high",
      "sources": ["Agent 3 - PERM-GAP-001", "Agent 4 - UX-001"],
      "problem": "Mechanics cannot update tech_completed_date, causing workflow delays",
      "solution": "Grant field-level update permission + add 'Mark Complete' button",
      "impact": {
        "score": 8,
        "description": "Eliminates admin bottleneck, faster workflow",
        "users_affected": "All mechanics (10+ users)",
        "time_saved": "10 min per completion (5x/day = 50 min/day)"
      },
      "urgency": {
        "score": 8,
        "reason": "Daily workflow friction"
      },
      "effort": {
        "hours": 0.5,
        "breakdown": [
          "0.25 hours - Update role permissions",
          "0.25 hours - Testing"
        ]
      },
      "priority_score": 128,
      "dependencies": [],
      "skills_required": ["Directus Admin"],
      "implementation_plan": {
        "phase": "Phase 1 - Critical",
        "estimated_start": "Day 1",
        "estimated_completion": "Day 1",
        "tasks": [
          "Navigate to Settings > Roles > Mechanic",
          "Edit cars collection permissions",
          "Grant UPDATE permission on tech_completed_date field",
          "Test with mechanic test user",
          "Verify workflow still works correctly",
          "Document permission change"
        ],
        "testing_approach": [
          "Login as mechanic",
          "Update tech_completed_date on test car",
          "Verify field saves",
          "Check workflow guard still prevents invalid transitions"
        ],
        "rollback_plan": "Remove permission if issues"
      }
    },
    {
      "id": "IMP-003",
      "rank": 3,
      "category": "schema",
      "title": "Add missing database indices",
      "priority": "high",
      "severity": "medium",
      "sources": ["Agent 2 - SCH-001"],
      "problem": "Missing indices on frequently queried fields cause slow queries",
      "solution": "Add composite index on (dealership_id, status) for cars collection",
      "impact": {
        "score": 7,
        "description": "Improves query performance from 500ms to <50ms on 1000+ cars",
        "users_affected": "All dealership admins (8+ users)",
        "time_saved": "5 sec per query × 50 queries/day = 4 min/day"
      },
      "urgency": {
        "score": 6,
        "reason": "Performance degradation as data grows"
      },
      "effort": {
        "hours": 0.25,
        "breakdown": [
          "0.1 hours - Create index migration",
          "0.15 hours - Test query performance"
        ]
      },
      "priority_score": 168,
      "dependencies": [],
      "skills_required": ["Database Admin"],
      "implementation_plan": {
        "phase": "Phase 1 - Critical",
        "estimated_start": "Day 1",
        "estimated_completion": "Day 1",
        "tasks": [
          "Connect to database",
          "Create composite index: CREATE INDEX idx_cars_dealership_status ON cars(dealership_id, status)",
          "Analyze query performance before/after",
          "Monitor index usage",
          "Document index purpose"
        ],
        "testing_approach": [
          "Run EXPLAIN on dealership car listing query",
          "Verify index is used",
          "Benchmark query time with 1000+ cars",
          "Confirm < 50ms response time"
        ],
        "rollback_plan": "DROP INDEX if issues"
      }
    }
  ],
  "implementation_phases": {
    "phase_1_critical": {
      "name": "Critical Fixes",
      "duration": "1 week",
      "duration_days": 7,
      "improvements": [
        "IMP-001 - Deadline monitoring",
        "IMP-002 - Mechanic permissions",
        "IMP-003 - Database indices"
      ],
      "total_effort_hours": 3.75,
      "expected_impact": "Prevents deadline failures, eliminates workflow bottleneck, improves performance",
      "success_criteria": [
        "Zero missed deadlines",
        "Mechanic workflow time reduced by 50%",
        "Query performance < 50ms"
      ]
    },
    "phase_2_high": {
      "name": "High-Priority Improvements",
      "duration": "2 weeks",
      "duration_days": 14,
      "improvements": [
        "IMP-004 - Car Status Dashboard (module)",
        "IMP-005 - Auto-assignment hook",
        "IMP-006 - Quick status buttons (interface)",
        "IMP-007 - Validation rules for dates"
      ],
      "total_effort_hours": 15,
      "expected_impact": "Better workflow visibility, automated assignment, faster status changes",
      "success_criteria": [
        "Dashboard used daily by 100% of admins",
        "Auto-assignment saves 20 min/day",
        "Status change time reduced by 50%"
      ]
    },
    "phase_3_medium": {
      "name": "Medium-Priority Optimizations",
      "duration": "3 weeks",
      "duration_days": 21,
      "improvements": [
        "IMP-008 - Dealership KPI panel",
        "IMP-009 - Field grouping improvements",
        "IMP-010 - Help text additions",
        "IMP-011 - Icon standardization"
      ],
      "total_effort_hours": 8,
      "expected_impact": "Better insights, improved UX, visual consistency",
      "success_criteria": [
        "KPI panel on 100% of admin dashboards",
        "Field grouping on all complex forms",
        "Help text on 90% of non-obvious fields"
      ]
    },
    "phase_4_low": {
      "name": "Low-Priority Enhancements",
      "duration": "Ongoing",
      "duration_days": null,
      "improvements": [
        "IMP-012 - Currency display formatter",
        "IMP-013 - Workflow timeline layout",
        "IMP-014 - Bulk status endpoint"
      ],
      "total_effort_hours": 8,
      "expected_impact": "Polish, minor UX improvements",
      "success_criteria": [
        "Consistent currency formatting",
        "Timeline view available",
        "Bulk operations functional"
      ]
    }
  },
  "resource_allocation": {
    "total_hours": 34.75,
    "by_phase": {
      "phase_1": 3.75,
      "phase_2": 15,
      "phase_3": 8,
      "phase_4": 8
    },
    "by_skill": {
      "typescript": 20,
      "directus_admin": 5,
      "database": 2,
      "vue": 7.75
    },
    "recommended_team": [
      {
        "role": "Full-stack Developer",
        "hours_per_week": 10,
        "weeks": 4,
        "total_hours": 40
      }
    ]
  },
  "dependencies_graph": {
    "IMP-001": {
      "depends_on": [],
      "blocks": []
    },
    "IMP-002": {
      "depends_on": [],
      "blocks": ["IMP-006"]
    },
    "IMP-004": {
      "depends_on": ["IMP-003"],
      "blocks": []
    }
  },
  "risk_assessment": [
    {
      "improvement": "IMP-001",
      "risk": "Notification flood if too many deadlines",
      "probability": "low",
      "impact": "medium",
      "mitigation": "Batch notifications, add daily summary instead of per-car"
    },
    {
      "improvement": "IMP-004",
      "risk": "Performance issues with large datasets",
      "probability": "medium",
      "impact": "low",
      "mitigation": "Add pagination, lazy loading"
    }
  ],
  "success_metrics": {
    "baseline": {
      "business_logic_coverage": "84.4%",
      "schema_design_score": "8.4/10",
      "permission_coverage": "95%",
      "ux_satisfaction": "7.5/10",
      "workflow_efficiency": "70%"
    },
    "targets_phase_1": {
      "business_logic_coverage": "92%",
      "schema_design_score": "8.7/10",
      "permission_coverage": "98%",
      "ux_satisfaction": "8.2/10",
      "workflow_efficiency": "85%"
    },
    "targets_final": {
      "business_logic_coverage": "98%",
      "schema_design_score": "9.0/10",
      "permission_coverage": "99%",
      "ux_satisfaction": "8.8/10",
      "workflow_efficiency": "92%"
    },
    "kpis": [
      {
        "metric": "Missed deadlines per month",
        "baseline": 12,
        "target": 1,
        "improvement": "92%"
      },
      {
        "metric": "Time to complete workflow",
        "baseline": "7 days",
        "target": "4 days",
        "improvement": "43%"
      },
      {
        "metric": "Manual assignment time",
        "baseline": "20 min/day",
        "target": "2 min/day",
        "improvement": "90%"
      }
    ]
  },
  "quick_wins": [
    {
      "improvement": "IMP-002",
      "reason": "30 min effort, eliminates daily friction for 10+ users",
      "expected_completion": "Day 1"
    },
    {
      "improvement": "IMP-003",
      "reason": "15 min effort, immediate performance improvement",
      "expected_completion": "Day 1"
    },
    {
      "improvement": "Currency Display (IMP-012)",
      "reason": "1 hour effort, visual consistency improvement",
      "expected_completion": "Week 1"
    }
  ],
  "integration_with_planning": {
    "use_plan_plugin": true,
    "when": "After Phase 1 completion",
    "purpose": "Refine Phase 2-4 implementation details",
    "input": "This roadmap + KANBAN.md status",
    "expected_output": "Detailed step-by-step plans for each improvement"
  },
  "monitoring_plan": {
    "weekly_reviews": [
      "Progress against roadmap",
      "Success metric tracking",
      "Resource utilization",
      "Blocker identification"
    ],
    "monthly_reports": [
      "Phase completion status",
      "KPI achievement",
      "User satisfaction surveys",
      "ROI analysis"
    ]
  },
  "next_steps": [
    "Review roadmap with stakeholders",
    "Get approval for Phase 1",
    "Allocate developer resources",
    "Create KANBAN tasks for Phase 1 improvements",
    "Begin implementation",
    "Schedule weekly progress reviews"
  ]
}
```

---

## Output Documents

Create 3 comprehensive markdown documents:

### 1. SYSTEM_ANALYSIS_FINDINGS.md

Complete findings from all 6 agents with:
- Executive summary
- Business logic analysis (Agent 1)
- Schema design audit (Agent 2)
- Relations and permissions validation (Agent 3)
- UX/UI flow assessment (Agent 4)
- Extension recommendations (Agent 5)
- All metrics and scores

### 2. IMPROVEMENT_RECOMMENDATIONS.md

Prioritized list with:
- All improvements ranked by priority score
- Problem/solution pairs
- Impact and effort analysis
- Quick wins highlighted
- Dependencies mapped
- Risk assessment

### 3. IMPLEMENTATION_ROADMAP.md

Phased plan with:
- Phase 1: Critical (Week 1)
- Phase 2: High (Weeks 2-3)
- Phase 3: Medium (Weeks 4-6)
- Phase 4: Low (Ongoing)
- Resource allocation
- Success metrics
- Monitoring plan
- Gantt chart (text-based)

---

## Focus Areas

Prioritize:
1. **Critical Blockers** - Must fix immediately
2. **High-Impact Quick Wins** - Maximum ROI
3. **Cross-Cutting Concerns** - Issues appearing in multiple analyses
4. **Resource Constraints** - Balance effort vs. available capacity

---

## Success Metric

Clear, prioritized roadmap with < 5% variance from estimates, 100% of critical issues addressed in Phase 1

---

**After completing this analysis, update KANBAN.md with Phase 1 tasks and begin implementation.**
