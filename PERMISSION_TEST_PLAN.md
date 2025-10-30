# Permission Test Plan - Data Isolation
**Task:** IMP-001-T2
**Created:** 2025-10-29
**Purpose:** Comprehensive testing strategy for dealership-based data isolation

## Test Strategy Overview

### Scope
- **Total Collections:** 6 (cars, resource_bookings, resource_capacities, dealership, notifications, directus_users)
- **Total Roles:** 10 (9 filtered + 1 admin)
- **CRUD Operations:** 4 (Create, Read, Update, Delete)
- **Total Test Cases:** 240 base tests + 50 edge cases = **290 tests**

### Test Levels
1. **Unit Tests:** Filter syntax validation
2. **Integration Tests:** Permission enforcement in Directus API
3. **End-to-End Tests:** User role workflows
4. **Security Tests:** Cross-dealership access attempts

---

## Test Environment Setup

### Prerequisites
✅ Test dealerships created:
- Dealership A (Kristiansand): `dealership_a_uuid`
- Dealership B (Mandal): `dealership_b_uuid`
- Dealership C (Parent - Franchise HQ): `dealership_c_uuid` (parent of A)

✅ Test users created (10 users total):
| Role | Dealership | Username | Purpose |
|------|-----------|----------|---------|
| Nybilselger | Dealership A | `test_nybil_a` | New car seller testing |
| Bruktbilselger | Dealership A | `test_bruktbil_a` | Used car seller testing |
| Delelager | Dealership A | `test_parts_a` | Parts warehouse testing |
| Mottakskontrollør | Dealership A | `test_inspection_a` | Inspection testing |
| Booking | Dealership A | `test_booking_a` | Scheduling testing |
| Mekaniker | Dealership A | `test_mechanic_a` | Mechanic testing |
| Bilpleiespesialist | Dealership A | `test_detailer_a` | Detailer testing |
| Daglig leder | Dealership A | `test_manager_a` | Manager testing |
| Økonomiansvarlig | Dealership A | `test_finance_a` | Finance testing |
| Admin | N/A (All) | `admin` | Admin testing |

✅ Test data created:
- 5 cars in Dealership A
- 5 cars in Dealership B
- 5 resource bookings (2 within A, 2 within B, 1 cross-dealership A↔B)
- 5 resource capacities in each dealership
- 5 notifications for each test user
- Test users populated in both dealerships

### Test Data IDs
```json
{
  "dealerships": {
    "a": "uuid-dealership-a",
    "b": "uuid-dealership-b",
    "c": "uuid-dealership-c-parent"
  },
  "cars": {
    "dealership_a": ["car-a-1", "car-a-2", "car-a-3", "car-a-4", "car-a-5"],
    "dealership_b": ["car-b-1", "car-b-2", "car-b-3", "car-b-4", "car-b-5"]
  },
  "bookings": {
    "within_a": ["booking-a-1", "booking-a-2"],
    "within_b": ["booking-b-1", "booking-b-2"],
    "cross_ab": ["booking-cross-ab-1"]
  }
}
```

---

## Test Case Categories

### Category 1: Standard Dealership Filter Tests (180 tests)

**Collections:** cars, resource_capacities, directus_users

**Test Matrix:**
| Role | Collections | CRUD Operations | Tests |
|------|-----------|-----------------|-------|
| 9 filtered roles | 3 collections | 4 CRUD | 108 tests (9×3×4) |
| 1 admin role | 3 collections | 4 CRUD | 12 tests (1×3×4) |
| **Total** | **3** | **4** | **120 tests** |

**Sample Test Case: TC-001**
```
Test ID: IMP-001-TC-001
Role: Nybilselger (Dealership A)
Collection: cars
Action: READ
Filter Applied: {dealership_id: {_eq: $CURRENT_USER.dealership_id}}

Setup:
- Login as test_nybil_a (dealership_id = dealership_a_uuid)
- 5 cars exist in Dealership A
- 5 cars exist in Dealership B

Test Steps:
1. GET /items/cars
2. Verify response contains only Dealership A cars
3. Verify Dealership B cars are NOT visible

Expected Result:
- Status: 200 OK
- Count: 5 cars
- All cars have dealership_id = dealership_a_uuid
- No cars from Dealership B returned

Pass Criteria:
✓ Only cars from user's dealership returned
✓ No cross-dealership leakage
✓ Filter applied correctly
```

---

### Category 2: Resource Bookings OR Filter Tests (40 tests)

**Collection:** resource_bookings (uses special _or filter)

**Test Matrix:**
| Role | Collection | CRUD Operations | Tests |
|------|-----------|-----------------|-------|
| 9 filtered roles | 1 collection | 4 CRUD | 36 tests (9×1×4) |
| 1 admin role | 1 collection | 4 CRUD | 4 tests (1×1×4) |
| **Total** | **1** | **4** | **40 tests** |

**Sample Test Case: TC-041**
```
Test ID: IMP-001-TC-041
Role: Booking (Dealership A)
Collection: resource_bookings
Action: READ
Filter Applied: {_or: [{provider_dealership_id: {_eq: $CURRENT_USER.dealership_id}}, {consumer_dealership_id: {_eq: $CURRENT_USER.dealership_id}}]}

Setup:
- Login as test_booking_a (dealership_id = dealership_a_uuid)
- 2 bookings where Dealership A is provider (within_a)
- 2 bookings where Dealership B is provider (within_b)
- 1 booking where A is provider and B is consumer (cross_ab)

Test Steps:
1. GET /items/resource_bookings
2. Verify response contains bookings where A is provider OR consumer
3. Verify internal Dealership B bookings are NOT visible

Expected Result:
- Status: 200 OK
- Count: 3 bookings
  - 2 from within_a (A provides, A consumes)
  - 1 from cross_ab (A provides, B consumes)
- Dealership B internal bookings (within_b) NOT visible

Pass Criteria:
✓ User sees bookings where their dealership is involved (provider OR consumer)
✓ Cross-dealership resource sharing visible
✓ Other dealerships' internal bookings hidden
```

---

### Category 3: Dealership Table Access Tests (40 tests)

**Collection:** dealership (users see own + parent)

**Test Matrix:**
| Role | Collection | Operations | Tests |
|------|-----------|-----------|-------|
| 9 filtered roles | 1 collection | 4 (mostly read) | 36 tests (9×1×4) |
| 1 admin role | 1 collection | 4 CRUD | 4 tests (1×1×4) |
| **Total** | **1** | **4** | **40 tests** |

**Sample Test Case: TC-081**
```
Test ID: IMP-001-TC-081
Role: Daglig leder (Dealership A, parent = Dealership C)
Collection: dealership
Action: READ
Filter Applied: {_or: [{id: {_eq: $CURRENT_USER.dealership_id}}, {id: {_eq: $CURRENT_USER.dealership.parent_dealership_id}}]}

Setup:
- Login as test_manager_a (dealership_id = dealership_a_uuid, parent = dealership_c_uuid)
- Dealership A exists (user's dealership)
- Dealership B exists (sibling dealership)
- Dealership C exists (parent/franchise HQ)

Test Steps:
1. GET /items/dealership
2. Verify response contains Dealership A (own)
3. Verify response contains Dealership C (parent)
4. Verify Dealership B is NOT visible (sibling)

Expected Result:
- Status: 200 OK
- Count: 2 dealerships
  - Dealership A (own)
  - Dealership C (parent)
- Dealership B NOT visible

Pass Criteria:
✓ User sees own dealership
✓ User sees parent dealership (franchise structure)
✓ Sibling dealerships hidden
```

---

### Category 4: Notifications User Filter Tests (40 tests)

**Collection:** notifications (user-specific, not dealership-specific)

**Test Matrix:**
| Role | Collection | CRUD Operations | Tests |
|------|-----------|-----------------|-------|
| 9 filtered roles | 1 collection | 4 CRUD | 36 tests (9×1×4) |
| 1 admin role | 1 collection | 4 CRUD | 4 tests (1×1×4) |
| **Total** | **1** | **4** | **40 tests** |

**Sample Test Case: TC-121**
```
Test ID: IMP-001-TC-121
Role: Mekaniker (Dealership A)
Collection: notifications
Action: READ
Filter Applied: {user_id: {_eq: $CURRENT_USER.id}}

Setup:
- Login as test_mechanic_a (user_id = test_mechanic_a_uuid)
- 5 notifications for test_mechanic_a
- 5 notifications for test_detailer_a (same dealership, different user)
- 5 notifications for test_mechanic_b (different dealership, same role)

Test Steps:
1. GET /items/notifications
2. Verify response contains only notifications for current user
3. Verify other users' notifications are NOT visible

Expected Result:
- Status: 200 OK
- Count: 5 notifications
- All notifications have user_id = test_mechanic_a_uuid
- No notifications from other users

Pass Criteria:
✓ User sees only their own notifications
✓ Same-dealership users' notifications hidden
✓ Cross-dealership users' notifications hidden
```

---

### Category 5: Admin Unrestricted Access Tests (24 tests)

**All Collections:** Admin sees everything (permissions: null)

**Test Matrix:**
| Role | Collections | CRUD Operations | Tests |
|------|-----------|-----------------|-------|
| Admin | 6 collections | 4 CRUD | 24 tests (1×6×4) |

**Sample Test Case: TC-161**
```
Test ID: IMP-001-TC-161
Role: Admin
Collection: cars
Action: READ
Filter Applied: null (no filter - unrestricted)

Setup:
- Login as admin (no dealership_id restriction)
- 5 cars in Dealership A
- 5 cars in Dealership B

Test Steps:
1. GET /items/cars
2. Verify response contains ALL cars from ALL dealerships

Expected Result:
- Status: 200 OK
- Count: 10 cars
- Cars from both Dealership A and B visible
- No filtering applied

Pass Criteria:
✓ Admin sees cars from all dealerships
✓ No data isolation for admin
✓ permissions: null working correctly
```

---

## Edge Case Tests (50 tests)

### EC-1: NULL dealership_id in User Record
```
Test ID: IMP-001-EC-001
Scenario: User has NULL dealership_id
Expected: User sees NO data (filter fails gracefully)
Validation: Ensure all users have dealership_id before go-live
```

### EC-2: Circular Parent Dealership Reference
```
Test ID: IMP-001-EC-002
Scenario: Dealership A has parent = Dealership C, Dealership C has parent = Dealership A
Expected: No infinite loop - only direct parent visible
Validation: Database constraints prevent circular references
```

### EC-3: Cross-Dealership Resource Booking Edge Cases
```
Test ID: IMP-001-EC-003
Scenario: Booking where provider_dealership_id = consumer_dealership_id (same dealership)
Expected: Visible to both (OR filter matches both conditions)
Validation: Booking appears once, not twice
```

### EC-4: User Switches Dealership
```
Test ID: IMP-001-EC-004
Scenario: User's dealership_id changes from A to B
Expected: User immediately sees only Dealership B data
Validation: No cached permissions, filter uses runtime context
```

### EC-5: Deleted Dealership
```
Test ID: IMP-001-EC-005
Scenario: User's dealership is soft-deleted (status = archived)
Expected: User can still access data OR gets graceful error
Validation: Decide on behavior - restrict or allow
```

### EC-6: Parent Dealership is NULL
```
Test ID: IMP-001-EC-006
Scenario: Dealership has no parent (parent_dealership_id = null)
Expected: Filter handles NULL gracefully, user sees own dealership only
Validation: OR filter with NULL parent works correctly
```

### EC-7: Field-Level Permissions (Future)
```
Test ID: IMP-001-EC-007
Scenario: Role can read collection but specific fields are hidden
Expected: Field-level permissions layer on top of collection permissions
Validation: Not implemented in this phase - document for future
```

### EC-8: Empty Permissions Object vs NULL
```
Test ID: IMP-001-EC-008
Scenario: permissions: {} (empty object) vs permissions: null
Expected: {} = deny all, null = allow all
Validation: Ensure admin uses null, not empty object
```

### EC-9: Bruktbilselger Cross-Dealership Search
```
Test ID: IMP-001-EC-009
Scenario: Used car seller needs to search inventory across dealerships
Expected: Current filter restricts to own dealership (future enhancement needed)
Validation: Document as known limitation, plan separate search endpoint
```

### EC-10: Resource Types Global vs Dealership-Specific
```
Test ID: IMP-001-EC-010
Scenario: resource_types collection has no dealership_id field
Expected: Resource types are global (shared across dealerships)
Validation: Confirm business requirement - currently global
```

---

## Performance Tests (20 tests)

### PT-1: Query Performance with Filters
```
Test ID: IMP-001-PT-001
Metric: API response time for filtered queries
Baseline: No filter (unrestricted access)
With Filter: {dealership_id: {_eq: $CURRENT_USER.dealership_id}}

Expected Improvement:
- Baseline: ~100ms (returns all records)
- Filtered: ~10-30ms (returns 10-20% of records)
- Improvement: 70-90% faster

Database Indexes Required:
- idx_cars_dealership_id
- idx_resource_bookings_provider_dealership_id
- idx_resource_bookings_consumer_dealership_id
- idx_resource_capacities_dealership_id
- idx_directus_users_dealership_id

Validation:
✓ Response time decreases with filtering
✓ Database uses indexes (EXPLAIN query)
✓ No full table scans
```

### PT-2: OR Filter Performance (resource_bookings)
```
Test ID: IMP-001-PT-002
Metric: API response time for OR filter
Filter: {_or: [{provider_dealership_id: ...}, {consumer_dealership_id: ...}]}

Expected:
- Both indexes used (provider + consumer)
- Response time < 50ms
- No performance degradation vs single field filter

Validation:
✓ EXPLAIN shows index usage on both fields
✓ Query optimizer handles OR efficiently
```

---

## Security Tests (30 tests)

### ST-1: Cross-Dealership Access Attempt
```
Test ID: IMP-001-ST-001
Attack Scenario: User manually crafts API request to access other dealership's data
Request: GET /items/cars/car-b-1 (Dealership B car)
User: test_nybil_a (Dealership A)

Expected Result:
- Status: 403 Forbidden OR 404 Not Found
- Error: "Forbidden" or item not accessible
- No data leakage

Validation:
✓ Directus enforces permissions at API layer
✓ Cannot bypass filter with direct ID access
✓ Error message doesn't reveal existence of data
```

### ST-2: SQL Injection in Filter
```
Test ID: IMP-001-ST-002
Attack Scenario: Attempt SQL injection via user context
Manipulated dealership_id: "' OR '1'='1"

Expected Result:
- Directus sanitizes all inputs
- Filter fails gracefully
- No SQL injection possible

Validation:
✓ Prepared statements used
✓ User context values validated
✓ No direct SQL concatenation
```

### ST-3: Token Tampering
```
Test ID: IMP-001-ST-003
Attack Scenario: Modify JWT token to change dealership_id
Modified Token: {user_id: "A", dealership_id: "B"}

Expected Result:
- Token signature validation fails
- Request rejected (401 Unauthorized)
- No access granted

Validation:
✓ JWT signature verified
✓ Token cannot be tampered
✓ Server-side validation
```

---

## Test Execution Plan

### Phase 1: Filter Syntax Validation (Week 1)
- Validate all JSON filter syntax
- Test against Directus schema
- Ensure no syntax errors

### Phase 2: Unit Tests (Week 1)
- Test each filter in isolation
- Verify filter logic (standard, OR, parent)
- Validate $CURRENT_USER context variables

### Phase 3: Integration Tests (Week 2)
- Deploy permissions to test environment
- Test all 240 base test cases
- Automated API testing

### Phase 4: Edge Case & Security Tests (Week 2)
- Manual testing of edge cases
- Security penetration testing
- Performance benchmarking

### Phase 5: End-to-End Workflow Tests (Week 3)
- Test complete user workflows
- Cross-role collaboration scenarios
- User acceptance testing (UAT)

---

## Test Data Cleanup

After testing:
```sql
-- Remove test data
DELETE FROM cars WHERE vin LIKE 'TEST-%';
DELETE FROM resource_bookings WHERE notes LIKE '%TEST%';
DELETE FROM directus_users WHERE email LIKE 'test_%@%';

-- Verify cleanup
SELECT COUNT(*) FROM cars WHERE vin LIKE 'TEST-%';
-- Expected: 0
```

---

## Success Criteria

### Functional Requirements
- ✅ All 240 base tests pass
- ✅ 90%+ edge case tests pass
- ✅ No cross-dealership data leakage
- ✅ Admin sees all data (unrestricted)
- ✅ All filters use $CURRENT_USER context (no hardcoded IDs)

### Performance Requirements
- ✅ API response time improves by 70-90%
- ✅ Database indexes used for all filtered queries
- ✅ No full table scans on production queries

### Security Requirements
- ✅ All security tests pass
- ✅ No SQL injection vulnerabilities
- ✅ No direct ID access bypasses permissions
- ✅ Token tampering prevented

---

## Rollback Plan

If tests fail:
1. Restore from backup: `/backups/permissions-backup-phase1-pre.json`
2. Remove all permissions from database
3. System reverts to default admin-only access
4. **Time to rollback:** < 5 minutes

---

## Test Report Template

```markdown
# Permission Test Report - IMP-001-T2

**Date:** YYYY-MM-DD
**Tester:** [Name]
**Environment:** Development

## Summary
- Total Tests: 290
- Passed: X
- Failed: Y
- Blocked: Z
- Pass Rate: X%

## Failed Tests
| Test ID | Description | Expected | Actual | Severity |
|---------|------------|----------|--------|----------|
| TC-XXX | ... | ... | ... | Critical |

## Recommendations
[List of issues and recommendations]

## Sign-Off
- [ ] All critical tests passed
- [ ] Performance requirements met
- [ ] Security requirements met
- [ ] Ready for production deployment

**Approved By:** [Name]
**Date:** YYYY-MM-DD
```

---

## Appendix A: API Test Scripts

### Bash Script for Automated Testing
```bash
#!/bin/bash
# test-permissions.sh

BASE_URL="http://localhost:8055"
TOKEN_NYBIL=""
TOKEN_ADMIN=""

# Test Case TC-001: Nybilselger sees only own dealership cars
test_tc001() {
  echo "Running TC-001..."
  RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN_NYBIL" "$BASE_URL/items/cars")
  COUNT=$(echo "$RESPONSE" | jq '.data | length')

  if [ "$COUNT" -eq 5 ]; then
    echo "✓ TC-001 PASSED"
  else
    echo "✗ TC-001 FAILED: Expected 5 cars, got $COUNT"
  fi
}

# Run all tests
test_tc001
# ... more tests
```

---

## Appendix B: Performance Monitoring Queries

### Check Index Usage
```sql
EXPLAIN ANALYZE
SELECT * FROM cars
WHERE dealership_id = 'test-dealership-uuid';

-- Expected: Index Scan using idx_cars_dealership_id
```

### Query Performance Comparison
```sql
-- Before (no filter)
EXPLAIN ANALYZE SELECT * FROM cars;

-- After (with filter)
EXPLAIN ANALYZE SELECT * FROM cars WHERE dealership_id = 'test-uuid';

-- Compare execution time and plan
```

---

## Sign-Off

**Test Plan Status:** ✅ Complete and ready for execution
**Estimated Test Duration:** 3 weeks
**Test Environment:** Development (http://localhost:8055)

**Created By:** Dev 1
**Date:** 2025-10-29
**Task:** IMP-001-T2
