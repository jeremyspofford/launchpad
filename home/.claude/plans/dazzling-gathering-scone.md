# Fix Plan: GitLab CI mr_stage_to_prod Job Failure

## Problem Summary

The `mr_stage_to_prod` job is failing with exit code 1 after refactoring the promotion jobs to use a shared template.

**Key Finding:** The job **used to work** before refactoring, but broke after:
1. Creating a shared `.promotion` template
2. Using `SOURCE_BRANCH` and `TARGET_BRANCH` variables instead of direct `$DEV_BRANCH`/`$STAGE_BRANCH` references
3. **Adding a new `glab mr list` command** to check for existing MRs before creating new ones

## Root Cause Analysis

### What Changed Between Working and Broken Versions

**BEFORE (working - commit a9543be6):**
```yaml
mr_stage_to_prod:
  script:
    - echo "Creating Merge Request from $STAGE_BRANCH to $PROD_BRANCH..."
    - glab mr create --source-branch $STAGE_BRANCH --target-branch $PROD_BRANCH ...
```

**AFTER (broken - commit f55dd66a):**
```yaml
.promotion:
  script:
    - echo "Creating Merge Request from $SOURCE_BRANCH to $TARGET_BRANCH..."
    - |
      # NEW: Check if an open MR already exists
      EXISTING_MR=$(glab mr list --source-branch "$SOURCE_BRANCH" --target-branch "$TARGET_BRANCH" --state opened 2>/dev/null | head -1)
      if [ -n "$EXISTING_MR" ]; then
        echo "✅ MR already exists: $EXISTING_MR"
        exit 0
      fi
      # Create new MR
      glab mr create --source-branch $SOURCE_BRANCH --target-branch $TARGET_BRANCH ...

mr_stage_to_prod:
  extends: [ .promotion, .rules:stage:commit ]
  variables:
    SOURCE_BRANCH: $STAGE_BRANCH
    TARGET_BRANCH: $PROD_BRANCH
```

### The Actual Issue

**Two potential issues:**

1. **Variable Expansion Problem**: `SOURCE_BRANCH: $STAGE_BRANCH` might not be expanding correctly in the GitLab CI variable inheritance chain
   - OR the variables are empty strings
   - OR they're not being passed to the shell script properly

2. **Authentication Problem**: The NEW `glab mr list` command requires proper authentication that `glab mr create` doesn't need
   - `assign_reviewers` works because it runs in MR context with implicit authentication
   - The old promotion jobs worked because `glab mr create` has different auth requirements than `glab mr list`

### Why assign_reviewers Works But .promotion Fails

| Aspect | assign_reviewers | .promotion jobs |
|--------|------------------|-----------------|
| **Context** | Runs in MR pipeline with `CI_MERGE_REQUEST_IID` | Runs in branch push context |
| **Command** | `glab mr update` (operates on existing MR) | `glab mr list` then `glab mr create` |
| **Implicit Auth** | MR context provides implicit project/server context | Branch push context has less implicit context |
| **before_script** | Empty (`[]`) | Empty (`[]`) |

The key difference is that **MR pipeline context** provides more implicit information to `glab` than **branch push context**.

## Debugging Steps Needed

Need to determine which issue is causing the failure:

1. **Remove error suppression** to see actual error message
2. **Add debug output** to verify variable values
3. **Test authentication** explicitly

## Solution

### Step 1: Add Debugging (Immediate)

Modify `.gitlab/ci/ops.gitlab-ci.yml` line 38-54:

```yaml
.promotion:
  stage: .post
  image: registry.gitlab.com/gitlab-org/cli:latest
  before_script: []
  dependencies: []
  script:
    - echo "Creating Merge Request from $SOURCE_BRANCH to $TARGET_BRANCH..."
    # DEBUG: Show what variables we have
    - echo "DEBUG - SOURCE_BRANCH=$SOURCE_BRANCH"
    - echo "DEBUG - TARGET_BRANCH=$TARGET_BRANCH"
    - echo "DEBUG - CI_SERVER_URL=$CI_SERVER_URL"
    - echo "DEBUG - GITLAB_TOKEN is set: ${GITLAB_TOKEN:+yes}"
    - |
      # Check if an open MR already exists for this source branch
      # TEMP: Remove 2>/dev/null to see actual errors
      echo "DEBUG - Running: glab mr list --source-branch $SOURCE_BRANCH --target-branch $TARGET_BRANCH --state opened"
      EXISTING_MR=$(glab mr list --source-branch "$SOURCE_BRANCH" --target-branch "$TARGET_BRANCH" --state opened | head -1)
      if [ -n "$EXISTING_MR" ]; then
        echo "✅ MR already exists: $EXISTING_MR"
        exit 0
      fi
      # Create new MR
      glab mr create --source-branch $SOURCE_BRANCH --target-branch $TARGET_BRANCH --title "Promote $SOURCE_BRANCH to $TARGET_BRANCH" --description "Automatic promotion from $SOURCE_BRANCH to $TARGET_BRANCH initiated by pipeline $CI_PIPELINE_ID." --yes --remove-source-branch=false
      echo "✅ MR created successfully"
  allow_failure: true
  interruptible: false
```

### Step 2: Add Explicit glab Authentication (Likely Fix)

Based on the difference between working `assign_reviewers` (MR context) and failing `.promotion` (branch context), add explicit authentication:

```yaml
.promotion:
  stage: .post
  image: registry.gitlab.com/gitlab-org/cli:latest
  before_script:
    - glab config set --host $CI_SERVER_URL --token $GITLAB_TOKEN
  dependencies: []
  script:
    - echo "Creating Merge Request from $SOURCE_BRANCH to $TARGET_BRANCH..."
    - |
      # Check if an open MR already exists for this source branch
      EXISTING_MR=$(glab mr list --source-branch "$SOURCE_BRANCH" --target-branch "$TARGET_BRANCH" --state opened 2>/dev/null | head -1)
      if [ -n "$EXISTING_MR" ]; then
        echo "✅ MR already exists: $EXISTING_MR"
        exit 0
      fi
      # Create new MR
      glab mr create --source-branch $SOURCE_BRANCH --target-branch $TARGET_BRANCH --title "Promote $SOURCE_BRANCH to $TARGET_BRANCH" --description "Automatic promotion from $SOURCE_BRANCH to $TARGET_BRANCH initiated by pipeline $CI_PIPELINE_ID." --yes --remove-source-branch=false
      echo "✅ MR created successfully"
  allow_failure: true
  interruptible: false
```

### Alternative: Fix Variable Expansion (If variables are empty)

If debugging shows that `SOURCE_BRANCH` and `TARGET_BRANCH` are empty, the issue is variable expansion. Fix by using string literals:

```yaml
mr_stage_to_prod:
  extends: [ .promotion, .rules:stage:commit ]
  variables:
    SOURCE_BRANCH: "stage"     # Use literal string instead of $STAGE_BRANCH
    TARGET_BRANCH: "prod"      # Use literal string instead of $PROD_BRANCH
```

But this is less DRY and should only be used if variable expansion is confirmed broken.

## Critical Files

- `.gitlab/ci/ops.gitlab-ci.yml` (lines 38-68) - Contains `.promotion` template and promotion jobs
- `.gitlab-ci.yml` (lines 64-79) - Defines global branch name variables
- `.gitlab/ci/shared/shared.gitlab-ci.yml` (lines 165-168) - Defines `.rules:stage:commit`

## Testing & Verification

After applying the fix:

1. **Trigger the job**: Push a commit to the `stage` branch
2. **Check job output**: Verify the debug messages show correct variable values
3. **Verify authentication**: glab commands should succeed without errors
4. **Confirm MR creation**: An MR from stage→prod should be created automatically
5. **Test idempotency**: Push another commit to stage, job should detect existing MR and skip creation

## Expected Outcome

After fixing authentication and/or variable expansion:
- `mr_stage_to_prod` job completes successfully
- Automatic MR is created from stage → prod branch
- Subsequent runs detect existing MR and exit gracefully
- Same fix applies to `mr_dev_to_stage` job
