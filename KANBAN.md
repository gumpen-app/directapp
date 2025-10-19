# DirectApp - Project Board

**Project:** Norwegian Car Dealership Multi-Site ERP System
**GitHub Project:** https://github.com/orgs/gumpen-app/projects/1 (33 items)
**Last Synced:** 2025-10-19 03:45 UTC

---

## 🔴 Blocked

*Issues waiting on external dependencies*

- Issue #29 - PDF parsing (venter på beslutning om teknologi)
- Issue #30 - Nøkkeltag scanning (venter på info om tag-format)

---

## 📋 Backlog

*Future work not yet prioritized*

### Phase 5: Advanced Features (Later)
- Issue #10: Ask Cars AI module (OpenAI natural language queries)
- Issue #11: Dealership branding (CSS vars per forhandler)
- Issue #12: Auto-archiving av leverte biler
- Issue #13: Vehicle bank med visibility levels
- Issue #14: Daily enrichment Flow (Statens Vegvesen)

### Phase 6: MCP Integration (Weeks 9-10)
- [ ] Research official Directus MCP server
- [ ] Deploy MCP server
- [ ] Create custom tools (car search, workflow queries)
- [ ] Test AI assistant integration

### Phase 8: Documentation & Training (Weeks 11-12)
- [ ] Create user documentation (role-specific guides)
- [ ] Create admin documentation
- [ ] Create developer documentation
- [ ] Train admin users
- [ ] Train end users
- [ ] Create support materials

---

## 📝 Todo

*Ready to start - organized by phase*

### Phase 1: Multi-Site Schema Implementation (Weeks 1-2) ✅ **COMPLETED**

**Critical Path:**
1. ~~Issue #20: 🗄️ Kjør database migrations (4t)~~ ✅ COMPLETED
   - 001: Extend dealership
   - 002: Add dealership_id to users
   - 003: Extend cars with workflow
   - 004: Create notifications
   - 005: Create resource management

2. ~~Issue #21: 🏢 Opprett initielle forhandlere (2t)~~ ✅ COMPLETED
   - Seed alle Gumpen-forhandlere
   - Setup resource sharing (499 → 495/324/326)
   - Brand colors

3. ~~Issue #22: ⚙️ Konfigurer Directus UI (8t)~~ ✅ COMPLETED
   - Translations
   - Interfaces (dropdowns, m2o, datetime)
   - Conditional field visibility
   - Tabs og layouts

4. ~~Issue #23: 👥 Opprett test-brukere (2t)~~ ✅ COMPLETED
   - En bruker per rolle per forhandler
   - Produktive roller med tidsbank

**Total Phase 1:** ~16 timer (✅ 100% COMPLETE - All 4 tasks done!)

---

### Phase 2: Workflow & Permissions (Weeks 2-3) 🔴 HIGH PRIORITY

5. Issue #24: 🔄 Implementer workflow hook (12t)
   - Status transition validering
   - Automatiske timestamp updates
   - Read-only når arkivert
   - Notification triggers

6. Issue #26: 🔐 Rolle-basert felttilgang (16t)
   - Field-level permissions per rolle
   - Dealership isolation filters
   - Cross-dealership søk for bruktbilselger
   - Testing med alle roller

7. Issue #1: 🔴 CRITICAL - Remove unscoped DELETE (DONE i schema-exported/roles.json)
8. Issue #2: 🔴 CRITICAL - Restrict password/email (DONE i schema-exported/roles.json)
9. Issue #3: ⚠️ HIGH - Enable TFA (DONE i schema-exported/roles.json)
10. Issue #5: 🔴 CRITICAL - Dealership isolation (dekkes av #26)

**Total Phase 2:** ~28 timer

---

### Phase 3: Notifications & Automation (Week 4) ⚠️ MEDIUM PRIORITY

11. Issue #25: 🔔 Implementer notification Flows (10t)
    - Ny ordre → delelager
    - Tilbehør endret → delelager
    - Mottakskontroll → selger + booking
    - Klar for planlegging → booking
    - Klargjøring ferdig → selger
    - Tidsbank full → booking

12. Issue #8: Flows for key events (overlap med #25)
    - Email integration med Resend
    - In-app notifications

**Total Phase 3:** ~10 timer

---

### Phase 4: UI/UX Enhancements (Weeks 5-6) ⚠️ MEDIUM PRIORITY

13. Issue #27: 📅 Kalendervisning for bookinger (20t)
    - Dag/uke view
    - Drag & drop
    - Kapasitetsindikator
    - Filtrering

14. Issue #28: 📊 Rolle-spesifikke dashboards (16t)
    - Dashboard per rolle
    - Directus Insights + custom panels
    - AI-assistert rapportering for daglig leder

15. Issue #9: Role-based forms (dekkes av #22)

**Total Phase 4:** ~36 timer

---

### Phase 5: Advanced Automation (Weeks 7-8) 📌 LOWER PRIORITY

16. Issue #29: 📄 PDF parsing for ordreimport (12t)
    - Upload interface
    - Auto-parse VIN, ordrenr, kunde
    - Forhåndsvisning før lagring

17. Issue #30: 🔑 Nøkkeltag scanning (16t)
    - OCR av nøkkeltag
    - Auto-koble til bil
    - Mottakskontroll integration

18. Issue #6: Enriched statuses med colors/translations (4t)
19. Issue #7: Automatic status transitions (dekkes av #24)

**Total Phase 5:** ~32 timer

---

### Legacy Issues (Old Schema - Reference Only)

**NOTE:** Disse er basert på gammelt schema. Behold som referanse.

- Issue #4: ⚠️ Add unique constraints (VIN, order_number)
  - **Status:** DONE i migration 003
- [ ] Add VIN validation (ISO 3779 regex)
- [ ] Add license plate validation (Norwegian format)
- [ ] Create database indexes
- [ ] Add audit logging
- [ ] Fix foreign key cascades

---

## 🏗️ In Progress

*Currently being worked on*

**Ready to start Phase 2: Workflow & Permissions**

---

**Phase 0.5: System Redesign** ✅ COMPLETED 2025-10-19
- [x] Analysert eksisterende oppsett
- [x] Designet komplett multi-site arkitektur
- [x] Laget 5 SQL migrations
- [x] Laget 11 GitHub issues (#20-#30)
- [x] Dokumentert i GUMPEN_SYSTEM_DESIGN.md
- [x] Oppdatert KANBAN.md

---

## 👀 Review

*Awaiting review or testing*

**Schema Design Documents:**
- `GUMPEN_SYSTEM_DESIGN.md` - Komplett system design (venter på godkjenning)
- `migrations/` - 5 SQL-filer (venter på kjøring)
- `migrations/README.md` - Migration guide

---

## ✅ Done

*Completed tasks*

### Phase 1: Multi-Site Schema ✅ **COMPLETED 100%** (2025-10-19)
- [x] **Issue #20:** 🗄️ Kjør database migrations (4t)
  - All 5 migrations successfully run
  - Extended dealership, users, cars tables
  - Created notifications and resource_* tables
  - URL: https://github.com/gumpen-app/directapp/issues/20

- [x] **Issue #21:** 🏢 Opprett initielle forhandlere (2t)
  - 9 dealerships created and configured
  - Resource sharing setup complete
  - URL: https://github.com/gumpen-app/directapp/issues/21

- [x] **Issue #22:** ⚙️ Konfigurer Directus UI (8t)
  - Norwegian translations for all collections
  - Configured all interface types (dropdowns, m2o, datetime)
  - Added conditional visibility for role-based field access
  - Created 5 presentation-divider sections for visual organization
  - Configured accessories JSON list interface
  - Fixed all foreign key issues (removed special:["uuid"] from M2O fields)
  - Final schema: dev-20251019-final-fix.json
  - URL: https://github.com/gumpen-app/directapp/issues/22

- [x] **Issue #23:** 👥 Opprett test-brukere (2t)
  - 12 test users created for all roles
  - All users assigned to dealerships
  - URL: https://github.com/gumpen-app/directapp/issues/23

### System Design (2025-10-19)
- [x] Kartlagt alle 7+ forhandlere
- [x] Definert 10 brukerroller med tilganger
- [x] Designet 23 nybil-statuser + 13 bruktbil-statuser
- [x] Planlagt 7 varslingsregler
- [x] Designet generisk ressursstyring med cross-dealership support

### Critical Permission Fixes (2025-10-19)
- [x] Issue #3: TFA enforced på alle policies (roles.json)
- [x] Issue #1: DELETE permission restricted (roles.json)
- [x] Issue #2: Password/email updates restricted (roles.json)

### UI/UX Improvements (2025-10-19)
- [x] **Role-Based Form Layout**
  - Configured half-width fields for better layout (paired related fields)
  - Added helpful placeholders and icons to all input fields
  - System fields hidden (id, sort, created_at, user_created, etc.)
  - Auto-fill fields made editable with notes (dealership_id, seller_id) pending workflow hook
  - Multiline textareas for all notes fields

- [x] **Visual Organization with Presentation Dividers**
  - Replaced broken tab approach (caused SQL errors) with presentation-divider fields
  - Created 5 themed dividers: Grunnleggende info, Kundeinformasjon, Arbeidsflyt, Klargjøring, Salg/økonomi
  - Each divider has color, icon, and conditional visibility for role-based access
  - Uses `special: ["alias", "no-data"]` to prevent SQL query errors

- [x] **Role-Based Conditional Visibility**
  - Purchase/prep costs: Admin only
  - Mechanic/detailer assignment: Booking + Admin only
  - Prep center fields: Hidden completely (pending workflow hook)
  - Workflow divider: Hidden from Nybilselger
  - Prep divider: Only visible to Admin and Booking roles

- [x] **Fixed Foreign Key Issues**
  - Removed `special: ["uuid"]` from all M2O foreign key fields (prep_center_id, seller_id, assigned_mechanic_id, assigned_detailer_id)
  - Foreign key fields should NOT auto-generate UUIDs - that's only for primary keys
  - Schema exported: dev-20251019-final-fix.json

- [x] **Verified Car Creation**
  - Tested creating car via MCP - NO SQL errors about divider fields
  - Form successfully creates cars with all field validation working

### Infrastructure (2025-10-18)
- [x] Pinned Directus to 11.12.0 (MCP support)
- [x] Upgraded extensions SDK to ^16.0.2
- [x] All Docker Compose configs created
- [x] Schema-as-code workflow
- [x] CI/CD pipeline
- [x] PRODUCTION_CHECKLIST.md (200+ items)
- [x] MASTER_IMPLEMENTATION_PLAN.md

### Documentation
- [x] GUMPEN_SYSTEM_DESIGN.md
- [x] CODEX_INTEGRATION_SUMMARY.md
- [x] SYNC_SUMMARY.md
- [x] CRITICAL_SCHEMA_FIXES.md
- [x] migrations/README.md

---

## 📊 Stats

**Total Issues:** 33 (synced from GitHub Project)
**New Issues Created:** 11 (#20-#30)
**Completed:** 7 (#1, #2, #3, #20, #21, #22, #23)
**In Progress:** 0 (Phase 1 complete! Ready for Phase 2)
**Blocked:** 2 (#29, #30 - venter på avklaringer)
**Todo:** 24 issues remaining

**Estimated Work Remaining:**
- Phase 1 (Schema): ✅ 0t (16t completed: ALL DONE!)
- Phase 2 (Workflow): ~28t ← **NEXT**
- Phase 3 (Notifications): ~10t
- Phase 4 (UI/UX): ~36t
- Phase 5 (Advanced): ~32t
**Total:** ~106 timer (~13 arbeidsdager)

**Current Sprint:** Phase 1 - Multi-Site Schema Implementation ✅ **COMPLETED**
**Sprint Goal:** Kjør migrations, seed data, konfigurer UI
**Sprint Duration:** 1 dag (completed 2025-10-19)
**Sprint Status:** ✅ 100% Complete - Ready for Phase 2

**Next Sprint:** Phase 2 - Workflow & Permissions
**Next Goal:** Workflow hook, rolle-basert tilgang

---

## 🎯 Next Actions

### 🎉 Phase 1 Complete! (16t / 16t - 100%)

**All tasks completed:**
1. **✅ DONE:** ~~Issue #20: Database migrations~~ (4t)
2. **✅ DONE:** ~~Issue #21: Seed dealerships~~ (2t)
3. **✅ DONE:** ~~Issue #22: Configure UI~~ (8t)
4. **✅ DONE:** ~~Issue #23: Opprett test-brukere~~ (2t)

### 🚀 Ready to Start Phase 2 (Priority 1)

**Issue #24:** Implementer workflow hook (12t)
- Status transition validering
- Automatiske timestamp updates
- Read-only når arkivert
- Notification triggers

**Issue #26:** Rolle-basert felttilgang (16t)
- Field-level permissions per rolle
- Dealership isolation filters
- Cross-dealership søk for bruktbilselger
- Testing med alle roller

### Neste uker
- Issue #25: Notification Flows
- Issue #27: Kalendervisning
- Issue #28: Dashboards

---

## 🔗 Links

- **GitHub Project:** https://github.com/orgs/gumpen-app/projects/1
- **Repository:** https://github.com/gumpen-app/directapp
- **Issues:** https://github.com/gumpen-app/directapp/issues
- **Design Doc:** GUMPEN_SYSTEM_DESIGN.md
- **Master Plan:** MASTER_IMPLEMENTATION_PLAN.md

---

**Last Updated:** 2025-10-19 (Phase 1: ✅ 100% COMPLETE - All 4 tasks done!)
**Maintained By:** DirectApp Team
