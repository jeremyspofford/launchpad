# Automated Rollback Mechanisms Implementation Plan

## Overview
Implement automated rollback mechanisms for FT Quoting deployments based on health checks and failure criteria. The system will use AWS CodeDeploy for Lambda versioned deployments with automatic rollback triggered by CloudWatch alarms, integrated with GitLab CI/CD pipeline.

**Timeline:** 10-12 weeks (comprehensive implementation with testing and validation)
**Strategy:** Fully automated rollback using CodeDeploy + CloudWatch alarms
**Scope:** All phases (health checks, monitoring, backend rollback, frontend rollback, smoke tests)

---

## Current State Analysis

### Existing Infrastructure
- **Backend:** Express.js on Lambda (Node.js 20), API Gateway REST API
- **Frontend:** React 19 + Vite, deployed to S3 + CloudFront
- **CI/CD:** GitLab with 5 stages (lint → build → test → plan → deploy)
- **Monitoring:** CloudWatch alarms exist but not used for deployment decisions
- **Health Check:** Simple `/health` endpoint (status + timestamp only)

### Key Gaps
1. ❌ No Lambda versioning or aliases
2. ❌ No post-deployment health verification
3. ❌ No automated rollback on deployment failure
4. ❌ Health endpoint doesn't check dependencies (DynamoDB, S3)
5. ❌ No smoke tests for deployment verification
6. ❌ Frontend has no versioning or rollback capability

---

## Architecture Changes

### 1. Lambda Versioning + Aliases + CodeDeploy

**What:**
- Enable Lambda versioning (immutable versions on each deployment)
- Create `live` alias pointing to current version
- Create `previous` alias for manual rollback
- Configure AWS CodeDeploy deployment group for managed deployments
- Integrate CloudWatch alarms as rollback triggers

**Why:**
- Lambda versions are immutable (safe rollback target)
- Aliases enable instant rollback (update pointer, no redeployment)
- CodeDeploy provides native Lambda traffic shifting and automatic rollback
- CloudWatch alarm integration triggers rollback automatically

**How:**
- Create new CDK construct: `infrastructure/lib/constructs/deployment/lambda-deployment.ts`
- Update `ComputeStack` to use versioned Lambda with CodeDeploy
- Configure deployment strategy: `Linear10PercentEvery1Minute` for prod, `AllAtOnce` for dev/stage
- Attach existing CloudWatch alarms as CodeDeploy rollback triggers

### 2. Enhanced Health Check System

**What:**
- `/health` - Liveness check (basic app health)
- `/health/ready` - Readiness check with dependency validation (DynamoDB, S3)
- `/health/deep` - Detailed component status with latencies and error details

**Why:**
- Current health endpoint is too simple (doesn't catch dependency failures)
- Post-deployment verification needs dependency checks
- Synthetics Canary needs meaningful endpoint to monitor

**How:**
- Create new route handler: `apps/server/src/routes/health.ts`
- Implement dependency checks (DynamoDB connection, S3 bucket access)
- Return structured response with component status and latencies
- Add Lambda version to health response for verification

### 3. CloudWatch Synthetics Canary

**What:**
- Canary that continuously monitors `/health/ready` endpoint
- Runs every 1 minute (production) or 5 minutes (dev/stage)
- Creates CloudWatch alarm on 2 consecutive failures

**Why:**
- Continuous monitoring detects degradation post-deployment
- Integrated with CodeDeploy as automatic rollback trigger
- More reliable than one-time post-deployment check

**How:**
- Create CDK construct: `infrastructure/lib/constructs/monitoring/health-check-monitoring.ts`
- Deploy Synthetics Canary in each environment
- Configure alarm on canary failures (2 consecutive breaches)
- Add canary alarm to CodeDeploy rollback triggers

### 4. Frontend Versioned Deployment

**What:**
- Deploy frontend to versioned S3 prefixes (`/releases/{commit-sha}/`)
- Maintain `CURRENT_VERSION` and `PREVIOUS_VERSION` pointers
- Enable instant rollback by updating pointer

**Why:**
- Current S3 sync with `--delete` destroys previous version
- No way to rollback frontend without redeployment
- Coordinated backend/frontend rollback requires frontend versioning

**How:**
- Modify `apps/quoting-studio/scripts/deploy.sh` for versioned deployment
- Update CloudFront origin path or S3 website routing
- Implement frontend rollback script

---

## Implementation Phases

### Phase 1: Health Checks & Monitoring Foundation (Weeks 1-3)

**Backend Health Check Enhancement:**
- [ ] Create `apps/server/src/routes/health.ts` with enhanced health endpoints
- [ ] Implement `/health` (liveness), `/health/ready` (readiness), `/health/deep` (detailed)
- [ ] Add dependency checks: DynamoDB table query, S3 bucket access
- [ ] Return structured response with component status, latencies, errors
- [ ] Add Lambda version and environment to response metadata
- [ ] Unit tests for health check logic
- [ ] Integration tests for dependency validation

**CloudWatch Synthetics Canary:**
- [ ] Create `infrastructure/lib/constructs/monitoring/health-check-monitoring.ts`
- [ ] Implement Synthetics Canary construct (calls `/health/ready` every 1-5 min)
- [ ] Configure CloudWatch alarm on canary failures (2 consecutive breaches)
- [ ] Deploy to sandbox environment for testing
- [ ] Validate canary triggers alarm on intentional failure
- [ ] Deploy to dev and stage environments

**Critical Files:**
- `apps/server/src/routes/health.ts` (new)
- `apps/server/src/services/DynamoDbService.ts` (add health check method)
- `apps/server/src/services/S3Service.ts` (add health check method)
- `infrastructure/lib/constructs/monitoring/health-check-monitoring.ts` (new)

### Phase 2: Backend Rollback Infrastructure (Weeks 4-6)

**Lambda Versioning + CodeDeploy:**
- [ ] Create `infrastructure/lib/constructs/deployment/lambda-deployment.ts`
- [ ] Implement Lambda versioning with `currentVersion` option
- [ ] Create `live` alias (mutable pointer to current version)
- [ ] Create `previous` alias (points to prior version for manual rollback)
- [ ] Configure AWS CodeDeploy deployment group
- [ ] Set deployment strategy: `Linear10PercentEvery1Minute` for prod, `AllAtOnce` for dev/stage
- [ ] Attach CloudWatch alarms as rollback triggers:
  - Lambda error rate alarm (>1-5% depending on environment)
  - Lambda throttle alarm (>5-10 throttles)
  - Lambda duration alarm (>24-25s approaching timeout)
  - API Gateway 5xx alarm (>1-2%)
  - Synthetics Canary alarm (2 consecutive failures)

**ComputeStack Updates:**
- [ ] Update `infrastructure/lib/stacks/compute-stack.ts` to use `LambdaDeployment` construct
- [ ] Ensure Lambda function exports version and alias
- [ ] Configure CodeDeploy service role with necessary permissions
- [ ] Update Lambda execution role if needed

**ApiStack Updates:**
- [ ] Update `infrastructure/lib/stacks/api-stack.ts` to integrate with Lambda alias (not function directly)
- [ ] Ensure API Gateway routes to `live` alias
- [ ] Validate API Gateway continues working after alias switch

**Testing in Sandbox:**
- [ ] Deploy versioned Lambda to sandbox
- [ ] Verify version creation on each deployment
- [ ] Test alias switching manually
- [ ] Deploy intentionally broken Lambda (e.g., syntax error causing 100% error rate)
- [ ] Verify CodeDeploy triggers automatic rollback within 2-3 minutes
- [ ] Confirm `live` alias points back to previous version
- [ ] Validate API Gateway continues serving from rolled-back version

**Critical Files:**
- `infrastructure/lib/constructs/deployment/lambda-deployment.ts` (new)
- `infrastructure/lib/stacks/compute-stack.ts` (modify)
- `infrastructure/lib/stacks/api-stack.ts` (modify)
- `infrastructure/lib/config/local.ts` (add CodeDeploy config)
- `infrastructure/lib/config/dev.ts` (add CodeDeploy config)
- `infrastructure/lib/config/stage.ts` (add CodeDeploy config)
- `infrastructure/lib/config/prod.ts` (add CodeDeploy config)
- `infrastructure/lib/types/environment.ts` (add CodeDeploy types)

### Phase 3: GitLab CI/CD Pipeline Integration (Weeks 6-8)

**New Pipeline Stage: Verify:**
- [ ] Add `verify` stage after `deploy` stage in `.gitlab-ci.yml`
- [ ] Create `verify:backend` job to check health endpoints
- [ ] Create `verify:frontend` job to validate frontend loads
- [ ] Create `verify:integration` job to run smoke tests
- [ ] Configure jobs to fail pipeline if verification fails
- [ ] Add retry logic (max 3 attempts) for transient failures

**Verification Scripts:**
- [ ] Create `scripts/verify-deployment.sh` for backend health checks
  - Test `/health`, `/health/ready`, `/health/deep` endpoints
  - Wait for CodeDeploy deployment to complete (aws deploy wait)
  - Check CloudWatch alarms are in OK state
  - Fail if any check fails
- [ ] Create `scripts/smoke-tests.sh` for integration tests
  - Test critical API endpoints (GET /api/projects, POST /api/projects)
  - Validate authentication flow
  - Test dependency connectivity
  - Fail if any test fails

**Manual Rollback Jobs:**
- [ ] Add `rollback` stage to `.gitlab-ci.yml`
- [ ] Create `rollback:backend` manual job
  - Updates `live` alias to previous version via AWS CLI
  - Supports specifying target version via variable
  - Requires AWS credentials (self-hosted runner)
- [ ] Create `rollback:frontend` manual job
  - Updates `CURRENT_VERSION` pointer to previous release
  - Invalidates CloudFront cache
  - Requires AWS credentials
- [ ] Create `rollback:full` manual job (rollback both backend + frontend)

**Rollback Notification:**
- [ ] Enhance `notify_failure` job to detect rollback events
- [ ] Send Teams notification on automatic rollback (triggered by CodeDeploy)
- [ ] Include rollback reason (which alarm triggered)
- [ ] Link to CloudWatch dashboard and logs

**Critical Files:**
- `.gitlab-ci.yml` (add verify and rollback stages)
- `.gitlab/ci/shared/templates.gitlab-ci.yml` (add job templates)
- `.gitlab/ci/ops.gitlab-ci.yml` (add verification and rollback jobs)
- `scripts/verify-deployment.sh` (new)
- `scripts/smoke-tests.sh` (new)
- `scripts/rollback.sh` (new)

### Phase 4: Frontend Rollback Capability (Weeks 8-9)

**Versioned S3 Deployment:**
- [ ] Modify `apps/quoting-studio/scripts/deploy.sh` for versioned deployment
- [ ] Deploy to `/releases/{CI_COMMIT_SHA}/` instead of root
- [ ] Maintain `CURRENT_VERSION` file pointing to active release
- [ ] Maintain `PREVIOUS_VERSION` file for rollback
- [ ] Update S3 website hosting to serve from versioned prefix
- [ ] Alternative: Update CloudFront origin path dynamically

**Frontend Rollback Script:**
- [ ] Create `scripts/rollback-frontend.sh`
- [ ] Update `CURRENT_VERSION` pointer to `PREVIOUS_VERSION` value
- [ ] Create CloudFront invalidation for `/*`
- [ ] Wait for invalidation to complete (~1-2 minutes)
- [ ] Verify frontend loads correctly

**FrontendStack Updates:**
- [ ] Update `infrastructure/lib/stacks/frontend-stack.ts` if needed
- [ ] Configure S3 bucket for versioned deployment support
- [ ] Update CloudFront distribution config if using origin path routing

**Testing:**
- [ ] Deploy frontend to sandbox with versioned deployment
- [ ] Verify multiple versions coexist in S3
- [ ] Test manual frontend rollback
- [ ] Verify CloudFront serves correct version after rollback
- [ ] Test coordinated backend + frontend rollback

**Critical Files:**
- `apps/quoting-studio/scripts/deploy.sh` (modify)
- `scripts/rollback-frontend.sh` (new)
- `infrastructure/lib/stacks/frontend-stack.ts` (modify if needed)

### Phase 5: Smoke Tests Integration (Weeks 9-10)

**Smoke Test Suite:**
- [ ] Create `apps/server/src/__smoke_tests__/` directory
- [ ] Implement critical API endpoint tests:
  - GET /health, /health/ready, /health/deep
  - GET /api/projects (authenticated)
  - POST /api/projects (authenticated, create test project)
  - GET /api/projects/:id (authenticated, verify created project)
  - DELETE /api/projects/:id (authenticated, cleanup)
- [ ] Implement authentication flow test (Cognito login)
- [ ] Implement dependency connectivity test (DynamoDB, S3)

**CI Integration:**
- [ ] Add smoke tests to `verify:integration` job
- [ ] Run smoke tests against deployed environment (not local)
- [ ] Use environment-specific API URLs (dev/stage/prod)
- [ ] Use test user credentials from GitLab secrets
- [ ] Fail pipeline if smoke tests fail
- [ ] Generate test report (JUnit format) as artifact

**Test Utilities:**
- [ ] Create test helper for authentication token retrieval
- [ ] Create test data factory for projects and other entities
- [ ] Create cleanup helper to remove test data after tests
- [ ] Add retry logic for transient failures (max 3 retries)

**Critical Files:**
- `apps/server/src/__smoke_tests__/health.smoke.test.ts` (new)
- `apps/server/src/__smoke_tests__/projects.smoke.test.ts` (new)
- `apps/server/src/__smoke_tests__/auth.smoke.test.ts` (new)
- `apps/server/src/__smoke_tests__/utils/test-helpers.ts` (new)
- `scripts/smoke-tests.sh` (modify to run test suite)

### Phase 6: Production Rollout & Validation (Weeks 10-12)

**Week 10: Staging Validation**
- [ ] Deploy all changes to stage environment
- [ ] Run full end-to-end test:
  - Deploy new version to stage
  - Introduce artificial failure (e.g., break DynamoDB connection)
  - Verify Synthetics Canary detects failure (~2-3 minutes)
  - Verify CloudWatch alarm triggers
  - Verify CodeDeploy triggers automatic rollback
  - Confirm `live` alias switches back to previous version
  - Verify API Gateway serves from rolled-back version
  - Confirm system returns to healthy state
- [ ] Test manual rollback via GitLab UI
- [ ] Validate frontend rollback
- [ ] Test coordinated backend + frontend rollback
- [ ] Measure rollback time (target: <3 minutes)
- [ ] Document any issues and tune thresholds

**Week 11: Production Deployment (Monitoring Only)**
- [ ] Deploy Lambda versioning + aliases to production
- [ ] Deploy enhanced health endpoints to production
- [ ] Deploy Synthetics Canary to production
- [ ] **Do NOT enable automatic rollback yet**
- [ ] Configure CloudWatch alarms for notifications only (not rollback triggers)
- [ ] Monitor alarm behavior for 1 week with production traffic
- [ ] Tune thresholds based on production baseline
- [ ] Document false positives and adjust evaluation periods

**Week 12: Production Full Enablement**
- [ ] Enable CodeDeploy automatic rollback in production
- [ ] Configure rollback triggers with tuned thresholds
- [ ] Enable smoke tests in production pipeline
- [ ] Schedule low-risk deployment to validate rollback works
- [ ] Monitor first production deployment with rollback enabled
- [ ] Document lessons learned
- [ ] Create operations runbook for team
- [ ] Conduct team training on rollback procedures

**Gradual Rollout Strategy:**
1. **Monitoring Only:** Deploy infrastructure, watch alarms, no automatic action
2. **Canary Deployment:** Enable CodeDeploy with 10% traffic for 1 minute
3. **Full Automatic Rollback:** Enable all triggers with tuned thresholds

---

## Failure Criteria & Rollback Triggers

### Automatic Rollback (CodeDeploy)

**Critical Failures (Immediate Rollback):**
- Lambda error rate >1-5% (environment-specific) over 2 minutes
- API Gateway 5xx error rate >1-2% over 2 minutes
- Lambda throttling >5-10 throttles over 2 minutes
- Lambda duration >24-25s average (approaching 30s timeout)
- Synthetics Canary 2 consecutive failures (~2-4 minutes)
- Health endpoint returning 503 or timing out

**Environment-Specific Thresholds:**

| Environment | Lambda Error Rate | API 5xx Rate | Throttle Threshold | Canary Failures |
|-------------|-------------------|--------------|-------------------|-----------------|
| Dev         | 10% (relaxed)     | 5%           | 20                | Disabled        |
| Stage       | 5% (moderate)     | 2%           | 10                | 2 consecutive   |
| Prod        | 1% (strict)       | 1%           | 5                 | 2 consecutive   |

### Manual Rollback (GitLab)

**When to Use:**
- CloudWatch alarm triggered but automatic rollback disabled
- Deployment succeeded but business logic issue discovered
- Performance degradation not detected by alarms
- Emergency rollback needed outside CodeDeploy

**Procedure:**
1. Go to GitLab pipeline
2. Navigate to `rollback` stage
3. Click manual play button on `rollback:backend` or `rollback:frontend`
4. Optionally specify version in variable
5. Monitor rollback completion (~1-3 minutes)
6. Verify health checks pass

---

## Risk Mitigation Strategies

### 1. False Positive Prevention
- **Evaluation Periods:** 2 consecutive breaches required (not just 1 data point)
- **Threshold Tuning:** Environment-specific thresholds based on baseline traffic
- **Missing Data Handling:** Alarms configured to NOT breach on missing data
- **Canary Retries:** Synthetics Canary retries once before alarming

### 2. Rollback Failure Handling
- **Multiple Versions:** Maintain last 3 Lambda versions for rollback options
- **Manual Override:** GitLab manual job can rollback to any specific version
- **Emergency Procedures:** Document manual AWS Console steps as fallback
- **Rollback Monitoring:** CloudWatch alarm on rollback failures themselves

### 3. Frontend-Backend Compatibility
- **Backward Compatibility:** Backend changes MUST support old frontend versions
- **Feature Flags:** Gate breaking changes behind feature flags
- **Coordinated Rollback:** Rollback both together if compatibility breaks
- **API Versioning:** Consider API versioning for major breaking changes

### 4. Deployment Throttling
- **Deployment Lock:** Prevent concurrent deployments to same environment
- **Cooldown Period:** 10-minute cooldown after rollback before next deployment
- **Maximum Rollbacks:** Alert after 3 rollbacks in 1 hour (runaway rollback loop)
- **Pre-deployment Testing:** Require all tests passing before deployment allowed

### 5. Team Alerting & Visibility
- **Slack/Teams Notifications:** Alert on automatic rollbacks with reason
- **Dashboard Integration:** Show rollback events in Teams dashboard
- **CloudWatch Dashboard:** Dedicated dashboard for deployment health monitoring
- **Post-Rollback Review:** Automated GitLab issue creation for investigation

---

## Critical Files to Modify

### New Files (Create)
1. `infrastructure/lib/constructs/deployment/lambda-deployment.ts` - Lambda versioning + CodeDeploy
2. `infrastructure/lib/constructs/monitoring/health-check-monitoring.ts` - Synthetics Canary
3. `apps/server/src/routes/health.ts` - Enhanced health endpoints
4. `scripts/verify-deployment.sh` - Post-deployment verification
5. `scripts/smoke-tests.sh` - Smoke test runner
6. `scripts/rollback.sh` - Manual rollback script
7. `scripts/rollback-frontend.sh` - Frontend rollback
8. `apps/server/src/__smoke_tests__/` - Smoke test suite directory

### Existing Files (Modify)
1. `infrastructure/lib/stacks/compute-stack.ts` - Use LambdaDeployment construct
2. `infrastructure/lib/stacks/api-stack.ts` - Integrate with Lambda alias
3. `infrastructure/lib/config/{local,dev,stage,prod}.ts` - Add CodeDeploy config
4. `infrastructure/lib/types/environment.ts` - Add CodeDeploy types
5. `apps/server/src/lambda.ts` - Register health routes
6. `apps/quoting-studio/scripts/deploy.sh` - Versioned frontend deployment
7. `.gitlab-ci.yml` - Add verify and rollback stages
8. `.gitlab/ci/ops.gitlab-ci.yml` - Add verification and rollback jobs
9. `.gitlab/ci/shared/templates.gitlab-ci.yml` - Add job templates

---

## Verification & Testing Strategy

### Development Testing (Sandbox/Dev)
1. **Infrastructure Testing:**
   - Deploy Lambda versioning to sandbox
   - Verify version creation on each deployment
   - Test manual alias switching
   - Deploy broken Lambda, verify automatic rollback
   - Measure rollback time (<3 min target)

2. **Health Check Testing:**
   - Test all health endpoints (/, /ready, /deep)
   - Break DynamoDB connection, verify /ready returns 503
   - Break S3 connection, verify /ready returns 503
   - Test Synthetics Canary alarm triggering

3. **Smoke Test Development:**
   - Write smoke tests for critical flows
   - Test authentication, project CRUD
   - Verify smoke tests fail on broken deployments

### Staging Validation
1. **End-to-End Rollback Flow:**
   - Deploy new version to stage
   - Introduce artificial failure
   - Observe automatic rollback (measure time)
   - Verify system returns to healthy state
   - Test manual rollback via GitLab

2. **Frontend Rollback Testing:**
   - Deploy new frontend version
   - Test frontend rollback
   - Verify CloudFront serves old version

3. **Coordinated Rollback:**
   - Break backend, trigger rollback
   - Verify frontend remains compatible
   - Test coordinated backend + frontend rollback

### Production Rollout
1. **Week 1: Monitoring Only**
   - Deploy without automatic rollback
   - Monitor alarms for false positives
   - Tune thresholds based on production traffic

2. **Week 2: Canary Enabled**
   - Enable CodeDeploy with canary strategy
   - Monitor first deployment closely
   - Adjust thresholds if needed

3. **Week 3: Full Enablement**
   - Enable all automatic rollback triggers
   - Validate on low-risk deployment
   - Document lessons learned

---

## Success Criteria

### Technical Metrics
- ✅ Automatic rollback completes in <3 minutes from failure detection
- ✅ Zero user-facing downtime during rollback
- ✅ CloudWatch alarms trigger correctly (no false positives after tuning)
- ✅ Manual rollback works via GitLab UI (<5 minutes)
- ✅ All smoke tests pass after rollback
- ✅ Health endpoints return accurate dependency status

### Operational Metrics
- ✅ Team trained on rollback procedures
- ✅ Runbook documented for operations
- ✅ Rollback events visible in Teams dashboard
- ✅ Post-rollback investigation process established
- ✅ False positive rate <5% after threshold tuning

### Business Metrics
- ✅ Reduced mean time to recovery (MTTR) for failed deployments
- ✅ Increased deployment confidence (team trusts automated rollback)
- ✅ Faster release cycles (less fear of breaking production)

---

## Rollback Procedures Reference

### Automatic Rollback (CodeDeploy)
**When:** CloudWatch alarm breaches threshold
**Timeline:** ~2-3 minutes from alarm to rollback complete
**What Happens:**
1. CloudWatch alarm enters ALARM state
2. CodeDeploy detects alarm breach
3. CodeDeploy triggers rollback
4. `live` alias updated to previous Lambda version (~30s)
5. API Gateway routes to rolled-back version
6. Teams notification sent to team
7. GitLab pipeline updated with rollback status

### Manual Rollback (GitLab)
**When:** Manual intervention needed
**Timeline:** ~1-3 minutes after trigger
**Procedure:**
1. Open GitLab pipeline for deployment
2. Navigate to `rollback` stage
3. Click play button on:
   - `rollback:backend` (Lambda only)
   - `rollback:frontend` (S3 + CloudFront only)
   - `rollback:full` (both backend + frontend)
4. Optionally set `ROLLBACK_VERSION` variable
5. Monitor job output for completion
6. Verify health endpoints return 200 OK

### Emergency Rollback (AWS Console)
**When:** GitLab unavailable or CodeDeploy failure
**Timeline:** ~5-10 minutes
**Procedure:**
1. Open AWS Console → Lambda
2. Find function: `ft-quoting-{env}-lambda`
3. Navigate to Aliases tab
4. Find `live` alias
5. Click "Update alias"
6. Select previous version from dropdown
7. Save changes
8. Verify API Gateway routes correctly
9. (For frontend) Update S3 CURRENT_VERSION pointer manually

---

## Next Steps After Implementation

### Week 13: Post-Implementation
- [ ] Conduct team training session on rollback procedures
- [ ] Create operations runbook with screenshots
- [ ] Document lessons learned from production rollout
- [ ] Set up recurring review of rollback events (monthly)
- [ ] Establish false positive tracking and threshold tuning process

### Ongoing Maintenance
- [ ] Review CloudWatch alarm thresholds quarterly
- [ ] Update smoke tests as new features are added
- [ ] Monitor rollback metrics (frequency, duration, success rate)
- [ ] Tune CodeDeploy deployment strategies based on experience
- [ ] Consider advanced strategies: multi-region rollback, blue/green for frontend

---

## Dependencies & Prerequisites

### AWS Services Required
- AWS Lambda (existing)
- AWS CodeDeploy (new)
- CloudWatch Alarms (existing, enhanced)
- CloudWatch Synthetics (new)
- IAM roles for CodeDeploy service

### GitLab Requirements
- Self-hosted runners with AWS credentials (existing)
- GitLab CI/CD pipeline permissions (existing)
- Ability to create manual jobs (existing)

### Team Skills
- AWS CDK knowledge (TypeScript)
- GitLab CI/CD pipeline configuration (YAML)
- Bash scripting for deployment scripts
- CloudWatch monitoring and alarms
- Lambda versioning and aliases concepts

---

## Timeline Summary

| Phase | Weeks | Deliverables |
|-------|-------|--------------|
| Phase 1: Health Checks & Monitoring | 1-3 | Enhanced health endpoints, Synthetics Canary |
| Phase 2: Backend Rollback Infrastructure | 4-6 | Lambda versioning, CodeDeploy, automatic rollback |
| Phase 3: GitLab CI/CD Integration | 6-8 | Verification jobs, manual rollback jobs, notifications |
| Phase 4: Frontend Rollback | 8-9 | Versioned S3 deployment, frontend rollback capability |
| Phase 5: Smoke Tests | 9-10 | Smoke test suite, integration with CI pipeline |
| Phase 6: Production Rollout | 10-12 | Staging validation, production gradual rollout |
| **Total** | **12 weeks** | Fully automated rollback system in production |
