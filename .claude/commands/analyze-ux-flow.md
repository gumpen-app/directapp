# Agent 4: UX/UI Flow Analyzer

**Role:** Assess user experience, interface design, and visual presentation flow

---

## Task

You are **Agent 4** in the Multi-Agent Orchestration System for DirectApp analysis.

Your mission: Analyze DirectApp's UX/UI design for optimal user experience.

---

## Step-by-Step Analysis

### 1. Query Collection Configurations

Use MCP tools to examine UI configuration:
```typescript
// Get collection configurations
mcp__directapp-dev__schema({ keys: ["cars", "workshop_tasks", "users", "organizations"] })

// Check for:
// - display_template clarity
// - field interfaces
// - field options
// - conditional logic
```

### 2. Analyze Custom UI Extensions

Examine custom extensions:
- `extensions/directus-extension-vehicle-lookup-button/` - Interface for vehicle data fetching
- `extensions/directus-extension-branding-inject/` - UI customization
- Check for other custom interfaces, displays, layouts, modules, panels

### 3. Map User Workflows

For each role (admin, dealership_admin, salesperson, mechanic):
- **Primary Tasks** - What do they do daily?
- **UI Flow** - How many clicks/screens to complete task?
- **Friction Points** - Where do they get stuck?
- **Data Entry** - How much manual typing required?
- **Information Clarity** - Is needed info easily visible?

### 4. Evaluate Display Templates

Check display_template for each collection:
- **Clarity** - Is it immediately clear what the item is?
- **Relevance** - Does it show the right information?
- **Brevity** - Not too long or too short?
- **Context** - Provides enough context for selection?

### 5. Assess Interface Choices

For each field, evaluate interface selection:
- **Appropriateness** - Does interface match data type?
- **Usability** - Easy to use for typical input?
- **Validation Feedback** - Clear error messages?
- **Autocomplete** - Dropdowns for common values?
- **Date Pickers** - For date fields?

### 6. Check Visual Design Consistency

Evaluate:
- **Icons** - Consistent Material Symbols usage?
- **Colors** - Meaningful color scheme?
- **Spacing** - Consistent field widths and groups?
- **Labels** - Clear, concise field names?
- **Help Text** - Notes provided where needed?

### 7. Analyze Information Architecture

Check:
- **Navigation** - Can users find what they need?
- **Grouping** - Related fields grouped together?
- **Tabs/Sections** - Complex forms broken into sections?
- **Search** - Can users search effectively?
- **Filters** - Appropriate filters on collection views?

---

## Output Format

Provide your analysis as JSON:

```json
{
  "analysis_metadata": {
    "agent": "Agent 4: UX/UI Flow Analyzer",
    "timestamp": "2025-10-29T...",
    "duration_minutes": 25,
    "collections_analyzed": 15,
    "user_flows_mapped": 8
  },
  "ui_components": {
    "custom_interfaces": 1,
    "custom_displays": 0,
    "custom_layouts": 0,
    "custom_modules": 0,
    "custom_panels": 0,
    "opportunities": [
      {
        "type": "module",
        "name": "Car Status Dashboard",
        "benefit": "Visual workflow overview",
        "priority": "high"
      },
      {
        "type": "panel",
        "name": "KPI Panel",
        "benefit": "Quick metrics on dashboard",
        "priority": "medium"
      }
    ]
  },
  "user_flow_analysis": [
    {
      "flow": "Register New Car",
      "role": "dealership_admin",
      "steps": [
        "Navigate to Cars collection",
        "Click '+' to create",
        "Enter registration number",
        "Click 'Fetch Vehicle Data' button",
        "Review auto-populated fields",
        "Fill remaining fields (4-5 fields)",
        "Assign to mechanic",
        "Save"
      ],
      "steps_count": 8,
      "time_estimate": "2-3 minutes",
      "friction_points": [
        {
          "step": 3,
          "issue": "Vehicle data fetch requires manual click",
          "impact": "Extra step, users might forget",
          "severity": "low",
          "recommendation": "Auto-fetch on regnr field blur"
        }
      ],
      "satisfaction_score": 8.5,
      "improvements": [
        "Auto-fetch vehicle data on registration number entry",
        "Default values for common fields"
      ]
    },
    {
      "flow": "Complete Workshop Task",
      "role": "mechanic",
      "steps": [
        "Login",
        "View assigned cars (filtered automatically)",
        "Select car",
        "Update tech_status field",
        "Add tech_notes",
        "Cannot update tech_completed_date (permission gap)",
        "Ask admin to mark complete"
      ],
      "steps_count": 7,
      "time_estimate": "1-2 minutes",
      "friction_points": [
        {
          "step": 6,
          "issue": "Cannot update completion date",
          "impact": "Must ask admin, workflow delay",
          "severity": "high",
          "recommendation": "Grant field permission to mechanics"
        }
      ],
      "satisfaction_score": 6.5,
      "improvements": [
        "Grant completion date update permission",
        "Add 'Mark Complete' button that sets status + date automatically"
      ]
    },
    {
      "flow": "Move Car Through Workflow",
      "role": "dealership_admin",
      "steps": [
        "Navigate to car",
        "Change status dropdown",
        "Workflow guard validates transition",
        "If valid, saves; if invalid, shows error",
        "Fill required fields for new status"
      ],
      "steps_count": 5,
      "time_estimate": "30 seconds",
      "friction_points": [],
      "satisfaction_score": 9.0,
      "improvements": [
        "Visual workflow diagram showing current state",
        "Suggested next actions based on current state"
      ]
    }
  ],
  "display_template_analysis": [
    {
      "collection": "cars",
      "template": "{{regnr}} - {{make}} {{model}} ({{status}})",
      "clarity": "excellent",
      "relevance": "high",
      "brevity": "optimal",
      "assessment": "Perfect - immediately identifies the car",
      "example": "AB12345 - Volkswagen Golf (ready_for_sale)"
    },
    {
      "collection": "users",
      "template": "{{first_name}} {{last_name}} - {{role}}",
      "clarity": "excellent",
      "relevance": "high",
      "brevity": "optimal",
      "assessment": "Good - shows name and role",
      "example": "Ola Nordmann - mechanic"
    },
    {
      "collection": "workshop_tasks",
      "template": "{{car_id.regnr}} - {{task_type}} ({{status}})",
      "clarity": "good",
      "relevance": "high",
      "brevity": "optimal",
      "assessment": "Functional but could include deadline",
      "recommendation": "Add deadline: {{car_id.regnr}} - {{task_type}} (Due: {{deadline}})",
      "example": "AB12345 - Tech Inspection (in_progress)"
    }
  ],
  "interface_evaluation": [
    {
      "collection": "cars",
      "field": "status",
      "interface": "select-dropdown",
      "appropriateness": "excellent",
      "usability": "excellent",
      "assessment": "Perfect for workflow state",
      "options": {
        "choices": [
          {"value": "registered", "text": "Registered"},
          {"value": "ready_for_sale", "text": "Ready for Sale"}
        ],
        "icon_indicator": true
      }
    },
    {
      "collection": "cars",
      "field": "regnr",
      "interface": "input",
      "appropriateness": "good",
      "usability": "good",
      "assessment": "Basic input works, but could enhance with format validation",
      "recommendation": "Add input mask for Norwegian registration format (XX12345)"
    },
    {
      "collection": "cars",
      "field": "vehicle_lookup_trigger",
      "interface": "vehicle-lookup-button (custom)",
      "appropriateness": "excellent",
      "usability": "excellent",
      "assessment": "Perfect - saves 5-10 minutes of manual data entry",
      "innovation": "Excellent custom solution"
    }
  ],
  "visual_design_consistency": {
    "score": 7.5,
    "icons": {
      "consistency": "good",
      "issues": [
        "Some collections use generic 'folder' icon",
        "Inconsistent icon style (some outlined, some filled)"
      ],
      "recommendations": [
        "Use Material Symbols consistently",
        "Choose icons that represent collection purpose"
      ]
    },
    "colors": {
      "consistency": "excellent",
      "usage": "Meaningful - status colors, collection grouping"
    },
    "spacing": {
      "consistency": "excellent",
      "field_widths": "Appropriate use of half/full widths",
      "grouping": "Good use of field groups"
    },
    "labels": {
      "clarity": "excellent",
      "consistency": "good",
      "issues": [
        "Some technical field names not translated to Norwegian"
      ]
    },
    "help_text": {
      "coverage": "60%",
      "issues": [
        "Complex fields missing explanatory notes",
        "No help text for workflow rules"
      ],
      "recommendations": [
        "Add notes to all non-obvious fields",
        "Add workflow state explanations"
      ]
    }
  },
  "information_architecture": {
    "navigation": {
      "score": 8.0,
      "assessment": "Clear collection organization",
      "improvements": [
        "Group related collections (e.g., 'Workshop' group)",
        "Add custom module for workflow overview"
      ]
    },
    "field_grouping": {
      "score": 7.0,
      "collections_with_groups": 3,
      "collections_without_groups": 12,
      "recommendations": [
        {
          "collection": "cars",
          "groups": [
            "Basic Info (regnr, make, model, year)",
            "Technical (engine, fuel, mileage)",
            "Workshop (tech_status, tech_notes)",
            "Sales (price, status, sold_to)"
          ]
        }
      ]
    },
    "search_filters": {
      "score": 6.5,
      "collections_with_filters": 2,
      "recommendations": [
        {
          "collection": "cars",
          "filters": ["status", "dealership", "assigned_to", "make"]
        }
      ]
    }
  },
  "findings": [
    {
      "id": "UX-001",
      "severity": "high",
      "category": "workflow_friction",
      "flow": "Complete Workshop Task",
      "issue": "Mechanic cannot update completion date",
      "impact": "Workflow delay, admin bottleneck",
      "recommendation": "Grant field permission + add 'Mark Complete' button",
      "effort": "15 minutes"
    },
    {
      "id": "UX-002",
      "severity": "medium",
      "category": "information_architecture",
      "issue": "No visual workflow overview",
      "impact": "Users can't see workflow status at a glance",
      "recommendation": "Create custom module with workflow board",
      "effort": "4-6 hours"
    },
    {
      "id": "UX-003",
      "severity": "low",
      "category": "visual_design",
      "issue": "Inconsistent icon usage",
      "impact": "Minor visual confusion",
      "recommendation": "Standardize collection icons",
      "effort": "30 minutes"
    }
  ],
  "strengths": [
    "Excellent vehicle lookup button (huge time saver)",
    "Clear display templates",
    "Good workflow guard prevents errors",
    "Appropriate interface choices",
    "Good use of custom branding"
  ],
  "weaknesses": [
    "No visual workflow dashboard",
    "Missing field grouping in complex forms",
    "Limited search/filter options",
    "Incomplete help text coverage",
    "Some permission gaps create friction"
  ],
  "quick_wins": [
    "Fix mechanic permission (2 min)",
    "Standardize collection icons (30 min)",
    "Add help text to complex fields (1 hour)",
    "Add field groups to cars collection (30 min)"
  ],
  "innovation_opportunities": [
    {
      "name": "Workflow Dashboard Module",
      "type": "module",
      "benefit": "Visual kanban-style workflow board",
      "impact": "High - better visibility and decision making",
      "effort": "4-6 hours"
    },
    {
      "name": "KPI Dashboard Panel",
      "type": "panel",
      "benefit": "Quick metrics on Insights dashboard",
      "impact": "Medium - better management oversight",
      "effort": "2-3 hours"
    }
  ],
  "metrics": {
    "overall_ux_score": "7.8/10",
    "workflow_efficiency": "8.2/10",
    "visual_consistency": "7.5/10",
    "information_clarity": "8.0/10",
    "custom_component_score": "9.0/10",
    "user_satisfaction_estimate": "7.5/10"
  }
}
```

---

## Focus Areas

Prioritize:
1. **Workflow Friction** - Identify bottlenecks and delays
2. **Custom Components** - Opportunities for time-saving interfaces
3. **Information Clarity** - Display templates, field labels
4. **Visual Consistency** - Icons, colors, spacing

---

## Output Location

Save your analysis to:
- `SYSTEM_ANALYSIS_FINDINGS.md` (append to UX/UI Flow section)
- Or output JSON for Agent 6 to synthesize

---

**Success Metric:** UX satisfaction score > 8.0/10, < 5 high-severity friction points
