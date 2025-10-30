# Agent 5: Extension Recommendation Engine

**Role:** Suggest custom extensions to enhance workflows and simplify operations

---

## Task

You are **Agent 5** in the Multi-Agent Orchestration System for DirectApp analysis.

Your mission: Identify opportunities for custom Directus extensions that will improve DirectApp.

---

## Step-by-Step Recommendation

### 1. Review Current Extensions

Examine existing extensions:
```bash
ls -la extensions/directus-extension-*/
```

Current extensions:
- `directus-extension-vehicle-lookup` (endpoint)
- `directus-extension-vehicle-search` (endpoint)
- `directus-extension-ask-cars-ai` (endpoint)
- `directus-extension-workflow-guard` (hook)
- `directus-extension-branding-inject` (hook)
- `directus-extension-vehicle-lookup-button` (interface)

### 2. Gather Inputs from Other Agents

Review findings from:
- **Agent 1:** Business logic gaps, automation opportunities
- **Agent 2:** Schema issues that could be solved with extensions
- **Agent 3:** Permission gaps, relation issues
- **Agent 4:** UX friction points, missing UI components

### 3. Identify Extension Opportunities

For each gap/friction point, ask:
- **Could an extension solve this?**
- **Which extension type?** (endpoint, hook, interface, operation, module, panel, display, layout)
- **What's the impact?** (time saved, errors prevented, better UX)
- **What's the effort?** (hours using templates)
- **Which template to use?** (8 templates available)

### 4. Categorize by Extension Type

**Endpoints:** External integrations, API enhancements
**Hooks:** Validation, automation, event handling
**Interfaces:** Custom field inputs, data entry improvements
**Operations:** Flow automation, scheduled tasks
**Modules:** Full-page applications, dashboards
**Panels:** Dashboard widgets, KPI displays
**Displays:** Field formatters, visual enhancements
**Layouts:** Custom collection views, alternative presentations

### 5. Prioritize Recommendations

Use this framework:
- **Critical:** Solves workflow blocker or prevents errors
- **High:** Significant time savings or UX improvement
- **Medium:** Nice to have, improves efficiency
- **Low:** Polish, minor enhancements

### 6. Create Implementation Plans

For each recommendation:
- Problem statement
- Proposed solution
- Expected impact (quantified if possible)
- Effort estimate
- Template to use
- Step-by-step implementation
- Testing approach

---

## Output Format

Provide your recommendations as JSON:

```json
{
  "analysis_metadata": {
    "agent": "Agent 5: Extension Recommendation Engine",
    "timestamp": "2025-10-29T...",
    "duration_minutes": 15,
    "opportunities_identified": 12,
    "recommendations": 8
  },
  "current_extensions": {
    "total": 6,
    "by_type": {
      "endpoints": 3,
      "hooks": 2,
      "interfaces": 1,
      "operations": 0,
      "modules": 0,
      "panels": 0,
      "displays": 0,
      "layouts": 0
    },
    "assessment": "Good coverage for integrations, missing workflow automation and dashboards"
  },
  "recommendations": [
    {
      "id": "EXT-001",
      "name": "Workshop Deadline Monitor",
      "type": "operation",
      "priority": "critical",
      "problem": {
        "description": "No automated deadline tracking for workshop tasks",
        "source": "Agent 1 - Business Logic Gap GAP-001",
        "impact": "Missed deadlines, customer dissatisfaction",
        "affected_users": "mechanics, dealership_admins"
      },
      "solution": {
        "description": "Flow operation that runs daily, checks for approaching deadlines, sends notifications",
        "functionality": [
          "Query cars with tech_deadline or cosmetic_deadline < 48 hours",
          "Check if status is not yet completed",
          "Send notification to assigned mechanic",
          "Send summary to dealership_admin",
          "Create audit log entry"
        ]
      },
      "impact": {
        "quantified": "Reduces missed deadlines by 90%",
        "time_saved": "Eliminates manual deadline tracking (15 min/day)",
        "user_satisfaction": "+15%"
      },
      "effort": {
        "estimate": "2-3 hours",
        "breakdown": [
          "30 min - Create operation from template",
          "45 min - Implement deadline query logic",
          "30 min - Configure notification flow",
          "30 min - Testing and validation"
        ]
      },
      "template": "directus-extension-template-operation",
      "implementation_plan": {
        "steps": [
          "Create operation: ./create-extension.sh workshop-deadline-monitor operation",
          "Implement handler to query cars with approaching deadlines",
          "Add ItemsService query for cars where deadline < $NOW + 48 hours",
          "Format notification data with car details, deadline, assigned user",
          "Test with sample data",
          "Create Flow with schedule trigger (daily at 8 AM)",
          "Add operation to flow",
          "Configure email/in-app notifications",
          "Deploy and monitor"
        ],
        "testing": [
          "Create test cars with deadlines in 24, 48, 72 hours",
          "Run flow manually",
          "Verify notifications sent to correct users",
          "Check audit logs created"
        ]
      }
    },
    {
      "id": "EXT-002",
      "name": "Car Status Dashboard Module",
      "type": "module",
      "priority": "high",
      "problem": {
        "description": "No visual overview of car workflow status",
        "source": "Agent 4 - UX Friction UX-002",
        "impact": "Admins can't quickly see workflow bottlenecks",
        "affected_users": "dealership_admins, admins"
      },
      "solution": {
        "description": "Custom module with kanban-style board showing cars by status",
        "functionality": [
          "Columns for each workflow state",
          "Car cards showing regnr, make, model, days in current state",
          "Drag and drop to change status (calls workflow guard)",
          "Filter by dealership, assigned user",
          "Click card to open car detail"
        ]
      },
      "impact": {
        "quantified": "Reduces status checking time by 80%",
        "time_saved": "10 min/day per admin",
        "user_satisfaction": "+20%",
        "decision_speed": "+30%"
      },
      "effort": {
        "estimate": "4-6 hours",
        "breakdown": [
          "1 hour - Create module from template",
          "2 hours - Implement kanban board UI",
          "1 hour - Add drag-and-drop logic",
          "1 hour - Testing and styling"
        ]
      },
      "template": "directus-extension-template-module",
      "implementation_plan": {
        "steps": [
          "Create module: ./create-extension.sh car-status-dashboard module",
          "Design Vue component with columns for each status",
          "Use useItems composable to fetch cars grouped by status",
          "Implement drag-drop with status update API call",
          "Add filter controls for dealership, user",
          "Style with Directus design tokens",
          "Add to module navigation",
          "Test with sample data",
          "Deploy"
        ],
        "testing": [
          "Load with 100+ cars",
          "Test drag-drop status changes",
          "Verify workflow guard validation works",
          "Test filters and search",
          "Check performance on slow connections"
        ]
      }
    },
    {
      "id": "EXT-003",
      "name": "Dealership KPI Panel",
      "type": "panel",
      "priority": "medium",
      "problem": {
        "description": "No quick KPI visibility on dashboard",
        "source": "Agent 4 - Innovation Opportunity",
        "impact": "Management lacks quick insights",
        "affected_users": "dealership_admins, admins"
      },
      "solution": {
        "description": "Dashboard panel showing key metrics",
        "functionality": [
          "Cars in progress count",
          "Avg turnaround time (days from registered to sold)",
          "Completion rate (% moved to ready_for_sale this week)",
          "Overdue tasks count",
          "Revenue this month (sum of sold car prices)"
        ]
      },
      "impact": {
        "quantified": "Instant visibility into dealership performance",
        "time_saved": "5 min/day (no manual reporting needed)",
        "user_satisfaction": "+10%"
      },
      "effort": {
        "estimate": "2-3 hours",
        "breakdown": [
          "30 min - Create panel from template",
          "1 hour - Implement KPI queries",
          "30 min - Design panel layout",
          "30 min - Testing"
        ]
      },
      "template": "directus-extension-template-panel",
      "implementation_plan": {
        "steps": [
          "Create panel: ./create-extension.sh dealership-kpi panel",
          "Add configuration options (which dealership to show)",
          "Implement API queries for each KPI",
          "Design card layout with large numbers and labels",
          "Add trend indicators (up/down arrows)",
          "Test with real data",
          "Add to Insights dashboard",
          "Configure default settings"
        ],
        "testing": [
          "Verify KPI calculations are correct",
          "Test with multiple dealerships",
          "Check performance with large datasets",
          "Validate date range filtering"
        ]
      }
    },
    {
      "id": "EXT-004",
      "name": "Currency Display Formatter",
      "type": "display",
      "priority": "low",
      "problem": {
        "description": "Inconsistent currency formatting",
        "source": "Agent 4 - Visual Consistency",
        "impact": "Minor readability issue",
        "affected_users": "all users"
      },
      "solution": {
        "description": "Custom display that formats NOK currency properly",
        "functionality": [
          "Format numbers with Norwegian locale (space separator)",
          "Add 'kr' suffix",
          "Handle null/undefined values",
          "Example: 249995 → 249 995 kr"
        ]
      },
      "impact": {
        "quantified": "Better consistency and readability",
        "time_saved": "Minimal",
        "user_satisfaction": "+2%"
      },
      "effort": {
        "estimate": "1 hour",
        "breakdown": [
          "15 min - Create display from template",
          "20 min - Implement formatting logic",
          "15 min - Testing",
          "10 min - Apply to price fields"
        ]
      },
      "template": "directus-extension-template-display",
      "implementation_plan": {
        "steps": [
          "Create display: ./create-extension.sh currency-nok display",
          "Implement formatting with Intl.NumberFormat('no-NO')",
          "Add 'kr' suffix",
          "Handle edge cases (null, zero, negative)",
          "Test with various numbers",
          "Apply to: cars.price, cars.cost, etc.",
          "Deploy"
        ],
        "testing": [
          "Test with: 0, 100, 1000, 100000, 249995.50",
          "Test with null/undefined",
          "Verify locale-specific formatting"
        ]
      }
    },
    {
      "id": "EXT-005",
      "name": "Auto-Assignment Hook",
      "type": "hook",
      "priority": "medium",
      "problem": {
        "description": "Manual task assignment creates bottlenecks",
        "source": "Agent 1 - Business Logic Gap GAP-002",
        "impact": "Delays in workflow progression",
        "affected_users": "dealership_admins, mechanics"
      },
      "solution": {
        "description": "Hook that auto-assigns tasks based on workload and expertise",
        "functionality": [
          "When car reaches workshop_received state",
          "Query available mechanics at that dealership",
          "Calculate current workload (assigned cars count)",
          "Assign to mechanic with lowest workload",
          "Send notification to assigned mechanic",
          "Create audit log"
        ]
      },
      "impact": {
        "quantified": "Eliminates manual assignment (20 min/day)",
        "time_saved": "100 hours/year per dealership",
        "user_satisfaction": "+15%"
      },
      "effort": {
        "estimate": "3-4 hours",
        "breakdown": [
          "45 min - Create hook from template",
          "1.5 hours - Implement assignment logic",
          "45 min - Add workload calculation",
          "45 min - Testing"
        ]
      },
      "template": "directus-extension-template-hook",
      "implementation_plan": {
        "steps": [
          "Create hook: ./create-extension.sh auto-assignment hook",
          "Listen to cars.update filter event",
          "Check if status changed to workshop_received",
          "Query mechanics with role='mechanic' and dealership_id match",
          "Calculate workload for each (count assigned cars)",
          "Assign to mechanic with min workload",
          "Update cars.assigned_to field",
          "Send notification",
          "Test with multiple mechanics and workloads",
          "Deploy"
        ],
        "testing": [
          "Create 3 mechanics with 0, 2, 5 assigned cars",
          "Move car to workshop_received",
          "Verify assignment goes to mechanic with 0 cars",
          "Test edge cases (no available mechanics)"
        ]
      }
    },
    {
      "id": "EXT-006",
      "name": "Workflow Timeline Layout",
      "type": "layout",
      "priority": "low",
      "problem": {
        "description": "No visual timeline of car workflow progress",
        "source": "Agent 4 - Information Architecture",
        "impact": "Hard to see workflow history",
        "affected_users": "dealership_admins"
      },
      "solution": {
        "description": "Custom layout showing cars in timeline view",
        "functionality": [
          "Horizontal timeline with dates",
          "Car milestones plotted on timeline",
          "Click to see car details",
          "Filter by date range, dealership"
        ]
      },
      "impact": {
        "quantified": "Better workflow visibility",
        "time_saved": "5 min/day",
        "user_satisfaction": "+8%"
      },
      "effort": {
        "estimate": "4-5 hours",
        "breakdown": [
          "1 hour - Create layout from template",
          "2 hours - Implement timeline UI",
          "1 hour - Add filtering and interactions",
          "1 hour - Testing"
        ]
      },
      "template": "directus-extension-template-layout"
    },
    {
      "id": "EXT-007",
      "name": "Bulk Status Update Endpoint",
      "type": "endpoint",
      "priority": "low",
      "problem": {
        "description": "No bulk operations for status changes",
        "source": "User feedback",
        "impact": "Time-consuming to update multiple cars",
        "affected_users": "dealership_admins"
      },
      "solution": {
        "description": "Endpoint for bulk status updates with validation",
        "functionality": [
          "POST /bulk-status-update",
          "Accept array of car IDs and new status",
          "Validate each transition via workflow guard logic",
          "Return success/failure for each car",
          "Create audit log"
        ]
      },
      "impact": {
        "quantified": "Saves 10 min when updating 20+ cars",
        "time_saved": "50 hours/year per dealership",
        "user_satisfaction": "+10%"
      },
      "effort": {
        "estimate": "2-3 hours",
        "breakdown": [
          "30 min - Create endpoint from template",
          "1 hour - Implement bulk update logic",
          "30 min - Add validation",
          "45 min - Testing"
        ]
      },
      "template": "directus-extension-template-endpoint"
    },
    {
      "id": "EXT-008",
      "name": "Quick Status Buttons Interface",
      "type": "interface",
      "priority": "medium",
      "problem": {
        "description": "Status dropdown requires too many clicks",
        "source": "Agent 4 - Usability",
        "impact": "Slower workflow progression",
        "affected_users": "all users"
      },
      "solution": {
        "description": "Button interface for quick status changes",
        "functionality": [
          "Show only valid next states as buttons",
          "Large, color-coded buttons",
          "Click to transition immediately",
          "Shows confirmation for final states (sold)",
          "Calls workflow guard for validation"
        ]
      },
      "impact": {
        "quantified": "Reduces status change time by 50%",
        "time_saved": "30 min/day per user",
        "user_satisfaction": "+12%"
      },
      "effort": {
        "estimate": "3-4 hours",
        "breakdown": [
          "1 hour - Create interface from template",
          "1.5 hours - Implement button logic and valid state calculation",
          "45 min - Styling and UX polish",
          "45 min - Testing"
        ]
      },
      "template": "directus-extension-template-interface"
    }
  ],
  "quick_wins": [
    {
      "id": "EXT-004",
      "name": "Currency Display Formatter",
      "reason": "Low effort (1 hour), immediate visual improvement",
      "roi": "High"
    },
    {
      "id": "EXT-001",
      "name": "Workshop Deadline Monitor",
      "reason": "Critical impact (prevents missed deadlines), moderate effort (2-3 hours)",
      "roi": "Very High"
    },
    {
      "id": "EXT-003",
      "name": "Dealership KPI Panel",
      "reason": "Moderate effort (2-3 hours), high visibility improvement",
      "roi": "High"
    }
  ],
  "coverage_gaps": {
    "before": {
      "operations": 0,
      "modules": 0,
      "panels": 0,
      "displays": 0,
      "layouts": 0
    },
    "after": {
      "operations": 1,
      "modules": 1,
      "panels": 1,
      "displays": 1,
      "layouts": 1,
      "hooks": 1,
      "interfaces": 1,
      "endpoints": 1
    },
    "assessment": "Recommendations fill all extension type gaps"
  },
  "total_impact": {
    "time_saved_per_day": "60 minutes",
    "time_saved_per_year": "250 hours",
    "user_satisfaction_increase": "+20%",
    "errors_prevented": "90% reduction in missed deadlines",
    "workflow_efficiency": "+30%"
  },
  "implementation_roadmap": {
    "phase_1_critical": {
      "extensions": ["EXT-001"],
      "duration": "1 day",
      "effort": "2-3 hours"
    },
    "phase_2_high": {
      "extensions": ["EXT-002", "EXT-005", "EXT-008"],
      "duration": "1 week",
      "effort": "10-12 hours"
    },
    "phase_3_medium": {
      "extensions": ["EXT-003"],
      "duration": "3 days",
      "effort": "2-3 hours"
    },
    "phase_4_low": {
      "extensions": ["EXT-004", "EXT-006", "EXT-007"],
      "duration": "1 week",
      "effort": "7-9 hours"
    }
  },
  "metrics": {
    "recommendations": 8,
    "critical": 1,
    "high": 3,
    "medium": 3,
    "low": 3,
    "total_effort": "21-28 hours",
    "roi_score": "9.2/10"
  }
}
```

---

## Focus Areas

Prioritize:
1. **Workflow Automation** - Operations to reduce manual work
2. **Visual Dashboards** - Modules and panels for better visibility
3. **UX Enhancements** - Interfaces and displays for better usability
4. **Validation & Safety** - Hooks to prevent errors

---

## Output Location

Save your recommendations to:
- `SYSTEM_ANALYSIS_FINDINGS.md` (append to Extension Recommendations section)
- Or output JSON for Agent 6 to synthesize

---

**Success Metric:** 5+ high-value extension recommendations with clear implementation plans
