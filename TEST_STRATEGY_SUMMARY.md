# DirectApp Test Strategy - Executive Summary

**Created**: 2025-10-29
**Author**: Agent 3: Test Strategy Designer
**Status**: Complete - Ready for IMP-022 Implementation

---

## Overview

This comprehensive test strategy defines a **5-layer testing approach** for the DirectApp implementation roadmap, addressing findings from Agent 1 (validator) and Agent 2 (segmentation).

**Total Testing Effort**: 40 hours (included in 88.35h development budget)
**Test Count**: 390-425 tests across all layers
**Coverage Targets**: 80% unit, 60% integration, 10-15 E2E scenarios

---

## 5-Layer Test Strategy

### Layer 1: Unit Tests (Extensions & Hooks)
- **Target**: 80%+ code coverage
- **Focus**: workflow-guard, vehicle-lookup, vehicle-search, ask-cars-ai
- **Tools**: Vitest, @directus/errors mocks
- **When**: Phase 2a (Week 2-3, IMP-022)
- **Effort**: 16 hours
- **Tests**: 120-150 unit tests

**Key Test Areas**:
- workflow-guard: 22 nybil states + 13 bruktbil states validation
- Vehicle lookup API integration
- Error handling and edge cases
- Timestamp auto-fill logic
- Notification creation

### Layer 2: Integration Tests (API & Database)
- **Target**: 60%+ critical path coverage
- **Focus**: Collection CRUD with RBAC, flow operations, database constraints
- **Tools**: Directus SDK, Test PostgreSQL database
- **When**: Phase 2a (Week 2-3, IMP-022)
- **Effort**: 12 hours
- **Tests**: 60-80 integration tests

**Key Test Areas**:
- cars collection CRUD with dealership isolation
- RBAC enforcement (Nybilselger sees only own dealership)
- Workflow guard integration (status transitions)
- Relation integrity checks

### Layer 3: E2E Tests (User Workflows)
- **Target**: 10-15 critical user journeys
- **Focus**: Nybilselger registration, Mechanic completion, Booking capacity
- **Tools**: Playwright, Staging Directus instance
- **When**: Phase 2b (Week 4)
- **Effort**: 8 hours
- **Tests**: 10-15 scenarios

**Key Scenarios**:
- E2E-001: Nybilselger complete car registration with vehicle lookup (5 min)
- E2E-002: Mekaniker view assigned cars and mark complete (3 min)
- E2E-003: Booking check capacity and schedule klargjøring (2 min)
- E2E-004: Daglig leder view workflow status dashboard (2 min)
- (6 more critical scenarios)

### Layer 4: Security Tests (RBAC & Data Isolation)
- **Target**: 100% role coverage, selective collection sampling
- **Focus**: Data isolation (IMP-001), RBAC policies (IMP-010), Production data (IMP-025)
- **Tools**: Manual testing, Directus SDK scripts, Postman
- **When**: Phase 1 (Week 1), Phase 2a (Week 2-3), Phase 3 (Week 5-6)
- **Effort**: 18 hours
- **Tests**: 160 total (40 IMP-001 + 60 IMP-010 + 80 IMP-025)

**Test Matrices**:
- **IMP-001**: 40 tests (10 roles × 4 CRUD operations)
  - Example: Nybilselger CREATE car → dealership_id auto-filled
  - Example: Bruktbilselger READ cross-dealership → read-only for others
  - Example: Mekaniker UPDATE tech_completed_date → allowed on assigned cars

- **IMP-025**: 80 tests (selective from 280 total: 10 roles × 4 CRUD × 7 collections)
  - Prioritize: Admin, Mekaniker, Booking (high-risk roles)
  - Collections: cars, resource_bookings, dealership (critical data)
  - Sample: 100% high-risk, 50% medium-risk, 20% low-risk

### Layer 5: Performance Tests (Query Optimization)
- **Target**: All critical queries < 100ms
- **Focus**: Dealership status (500ms→45ms), Mechanic workload (350ms→52ms), Capacity (280ms→70ms)
- **Tools**: PostgreSQL EXPLAIN ANALYZE, k6, Chrome DevTools
- **When**: Phase 1 (Week 1, IMP-006), Phase 2b (Week 4, dashboard launch)
- **Effort**: 4 hours
- **Tests**: 10 performance tests

**Key Optimizations**:
- Composite index: (dealership_id, status) → 91% faster
- Index: (assigned_mechanic_id) → 85% faster
- Composite index: (dealership_id, resource_type_id, date) → 75% faster
- Dashboard load time: < 2s (Chrome DevTools Performance tab)

---

## Bug Severity Classification

### Critical
**Definition**: System unusable, data loss, or security breach
**Examples**: Data isolation bypass, workflow-guard deletion bug, unauthorized role escalation
**Action**: Blocks deployment, immediate fix required (< 4 hours)

### High
**Definition**: Major functionality broken, significant workflow impact
**Examples**: Mekaniker cannot update tech_completed_date, vehicle lookup 500 error, dashboard fails
**Action**: Fix before next deployment (< 24 hours)

### Medium
**Definition**: Minor functionality broken, workaround available
**Examples**: Display template syntax error, field validation missing, notification delay
**Action**: Fix in next sprint (< 1 week)

### Low
**Definition**: Cosmetic issue, no functionality impact
**Examples**: Button text not translated, icon misalignment, color inconsistency
**Action**: Fix when convenient (< 1 month)

---

## Performance Measurement Methodology

### Dashboard Load Time Measurement
**Target**: < 2000ms

**Process**:
1. **Tool**: Chrome DevTools Performance tab
2. **Start Event**: Navigation start (route change)
3. **End Event**: First meaningful paint (dashboard data visible)
4. **Environment**: Staging with production data volume (10,000 cars)
5. **Test Conditions**: 5 runs, median value
6. **Network**: Fast 3G throttling (1.6 Mbps download, 750 Kbps upload)
7. **Threshold**: < 2000ms

**Acceptance Criteria**:
- Median load time < 2000ms
- 95th percentile < 3000ms
- No blocking resources > 500ms

---

## Test Execution Schedule

| Week | Phase | Test Focus | Effort | Pass Criteria |
|------|-------|------------|--------|---------------|
| **Week 1** | Phase 1 | Data isolation, DELETE restrictions | 4h | All 40 isolation tests pass, 0 security issues |
| **Week 2-3** | Phase 2a | Unit + Integration + RBAC | 24h | 80% unit coverage, 60% integration, all RBAC pass |
| **Week 4** | Phase 2b | E2E + Performance + Dashboards | 8h | All E2E pass, dashboard < 2s, queries < 100ms |
| **Week 5-6** | Phase 3 | Production data + RBAC validation | 12h | 80/80 RBAC production tests pass, 0 regressions |
| **Week 7-8** | Phase 4 | UAT + Final validation | 6h | UAT sign-off, 0 critical bugs, production ready |

**Total Effort**: 54 hours testing (40h in roadmap + 14h additional validation)

---

## Test Data Requirements

### Security Tests (IMP-001)
- 2 dealerships (Kristiansand, Mandal)
- 10 users (1 per role)
- 20 cars (10 per dealership, various statuses)
- 10 resource_bookings (5 per dealership)

### E2E Tests
- 3 dealerships (Kristiansand, Mandal, Gumpen Skade prep center)
- 15 users (at least 1 per role, some 2)
- 50 cars (complete workflow dataset)
- 30 resource_bookings (realistic booking patterns)

### Performance Tests
- 7 dealerships (all production)
- 50+ users (realistic user base)
- 10,000+ cars (production data volume)
- 1,000+ resource_bookings
- **Anonymization required**: customer_name, customer_phone, customer_email

---

## Tools & Frameworks

| Test Type | Tool | Reason |
|-----------|------|--------|
| **Unit** | Vitest | Fast, modern, TypeScript-first |
| **Integration** | Vitest + Directus SDK | Same tool for consistency, SDK for API |
| **E2E** | Playwright | Modern, reliable, great debugging |
| **Security** | Postman + SDK scripts | Manual + automated validation |
| **Performance** | k6 + EXPLAIN ANALYZE | Load testing + query optimization |
| **CI/CD** | GitHub Actions | Already configured (.github/workflows/directus-ci.yml) |

---

## Success Metrics

### Coverage Targets
- Unit tests: **80%+** code coverage (extensions)
- Integration tests: **60%+** API endpoint coverage
- E2E tests: **10-15** critical user journeys
- Security tests: **100%** role coverage, **80/280** RBAC tests (selective)
- Performance tests: **100%** critical query coverage

### Defect Rates
- Critical bugs: **0** (block deployment)
- High bugs: **< 3** (fix before next deployment)
- Medium bugs: **< 10** (fix in next sprint)
- Low bugs: **< 20** (backlog)

### Performance Targets
- Dealership status query: **< 100ms** (target: 45ms)
- Mechanic workload query: **< 100ms** (target: 52ms)
- Capacity query: **< 100ms** (target: 70ms)
- Dashboard load time: **< 2000ms**
- Vehicle lookup API: **< 1000ms** (95th percentile)

### Security Targets
- Data isolation: **100%** enforcement (0 cross-dealership leaks)
- RBAC coverage: **100%** (all 10 roles implemented)
- Permission coverage: **95%+** (collection + field-level)
- Security score: **9.0/10** (up from 2.5/10)

---

## IMP-001 Test Matrix (40 Test Cases)

**Breakdown**: 10 roles × 4 CRUD operations = 40 tests

**Sample Test Cases**:

| Test ID | Role | Action | Expected Result |
|---------|------|--------|-----------------|
| ISO-001 | Nybilselger | CREATE car | dealership_id=Kristiansand (auto-filled) |
| ISO-002 | Nybilselger | READ cars | Only Kristiansand cars visible |
| ISO-003 | Nybilselger | UPDATE Mandal car | 403 Forbidden (cross-dealership blocked) |
| ISO-004 | Nybilselger | DELETE Mandal car | 403 Forbidden (cross-dealership blocked) |
| ISO-006 | Bruktbilselger | READ cars | All bruktbil visible (cross-dealership read-only) |
| ISO-010 | Mekaniker | READ cars | Only assigned cars visible (assigned_mechanic_id = user) |
| ISO-011 | Mekaniker | UPDATE tech_completed_date | Update successful (on assigned car) |
| ISO-038 | Admin | READ cars | All dealerships visible (no filter) |
| ISO-040 | Admin | DELETE any car | Delete successful (admin override) |

**Acceptance Criteria**: All 40 tests must pass for IMP-001 to be considered complete.

---

## IMP-025 Test Matrix (80 Selective from 280 Total)

**Total Potential Tests**: 10 roles × 4 CRUD × 7 collections = 280 tests
**Selective Sample**: 80 tests (28.6% of total)

**Sampling Strategy**:
- **High-risk** (100% coverage): Admin, Mekaniker, Booking, Nybilselger, Økonomiansvarlig
- **High-risk collections**: cars, resource_bookings, dealership, directus_users
- **High-risk operations**: DELETE, UPDATE with cross-dealership, READ with price fields
- **Medium-risk** (50% coverage): Mottakskontrollør, Delelager, Bilpleiespesialist
- **Low-risk** (20% coverage): Remaining role/collection combinations

**Sample Test Cases**:

| Test ID | Role | Collection | Action | Field | Expected Result |
|---------|------|------------|--------|-------|-----------------|
| RBAC-PROD-001 | Mekaniker | cars | UPDATE | tech_completed_date | Update successful |
| RBAC-PROD-002 | Booking | resource_bookings | DELETE | - | 403 Forbidden (completed bookings) |
| RBAC-PROD-003 | Nybilselger | cars | READ | workshop_tasks | Field hidden |
| RBAC-PROD-004 | Økonomiansvarlig | cars | READ | purchase_price | Field visible |
| RBAC-PROD-005 | Admin | directus_users | DELETE | - | Blocked by FK constraint |

**Production Data Requirements**:
- 10,000+ cars (realistic data volume)
- 7 dealerships (matching production)
- 50+ users across all roles
- Anonymized customer PII

---

## Risk Mitigation

### High-Risk Areas

1. **Data isolation breaks existing functionality**
   - Probability: Medium | Impact: High
   - Mitigation: Test with all 10 roles, verify Admin sees all, rollback plan ready

2. **RBAC complexity causes delays**
   - Probability: High | Impact: Medium
   - Mitigation: Follow ROLE_PERMISSIONS_PLAN.md exactly, allocate buffer time, incremental implementation

3. **Dashboard performance issues**
   - Probability: Low | Impact: High
   - Mitigation: Optimize queries with indices, server-side aggregation, pagination, caching, load test

4. **Production schema import fails**
   - Probability: Medium | Impact: Critical
   - Mitigation: Test on staging first, full backup, validate integrity, anonymize PII, run RBAC tests

---

## Next Steps for IMP-022 (Testing Framework)

### Immediate Actions (Week 2-3)
1. Set up Vitest configuration in extensions workspace
2. Create test utilities and mocks (@directus/errors, @directus/extensions-sdk)
3. Write unit tests for workflow-guard (highest priority)
4. Set up test PostgreSQL database for integration tests
5. Create test data seed scripts (SQL)

### Week 4
1. Write E2E tests with Playwright
2. Set up staging environment with production data volume
3. Performance test dashboards (Chrome DevTools)
4. Validate query optimizations (EXPLAIN ANALYZE)

### Week 5-6
1. Import production schema to staging
2. Run RBAC tests with production data (80 cases)
3. Performance test with 10,000+ cars
4. Regression testing (all previous tests)

### Week 7-8
1. UAT with all roles
2. Production deployment dry-run
3. Final regression test suite
4. Post-deployment monitoring plan

---

## Documentation Deliverables

1. **TEST_STRATEGY.md** (this document) ✅
2. **UNIT_TEST_GUIDE.md** (how to write unit tests for extensions)
3. **INTEGRATION_TEST_GUIDE.md** (API testing patterns)
4. **E2E_TEST_GUIDE.md** (Playwright test scenarios)
5. **PERFORMANCE_TEST_GUIDE.md** (query optimization + load testing)
6. **RBAC_TEST_MATRIX.md** (role/collection/action test cases)
7. **BUG_REPORT_TEMPLATE.md** (standardized bug reporting)
8. **TEST_DATA_SEED_SCRIPTS.sql** (SQL scripts to seed test data)
9. **CI_CD_SETUP.md** (GitHub Actions configuration)
10. **UAT_CHECKLIST.md** (user acceptance testing checklist)

---

## Complete Test Strategy JSON

The full test strategy with all test cases, test matrices, and detailed specifications is available in:

**File**: `/home/claudecode/claudecode-system/projects/active/directapp/DIRECTAPP_TEST_STRATEGY.json`

This JSON file includes:
- All 40 IMP-001 test cases (data isolation)
- All 80 IMP-025 test cases (RBAC with production data)
- All 10-15 E2E test scenarios (complete user journeys)
- Bug severity classification with examples
- Performance measurement methodology
- Test data requirements per test type
- Tools and frameworks with configurations
- Success metrics and acceptance criteria
- Risk mitigation strategies
- Complete test execution schedule

---

**Status**: Complete - Ready for implementation in IMP-022 (Testing Framework)
**Next Agent**: Agent 4 (if needed) or begin IMP-022 implementation

**Validation**: This test strategy addresses all findings from Agent 1 (validator) and Agent 2 (segmentation), providing explicit test matrices for IMP-001 (40 cases), IMP-025 (80 selective cases), and comprehensive coverage across all 5 test layers.
