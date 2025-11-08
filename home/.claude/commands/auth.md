---
description: Authenticate with AWS SSO for alert-dev profile and export credentials
---

# AWS SSO Authentication Workflow

Automate AWS SSO login and credential export for the alert-dev profile.

## What This Does

This command will execute your AWS authentication workflow:

1. ✅ Run AWS SSO login for alert-dev profile
2. ✅ Select profile option 5 via sso alias
3. ✅ Export AWS environment variables
4. ✅ Run alert-dev alias to complete setup

## Task Instructions

Execute the following bash commands in sequence:

### Step 1: AWS SSO Login

```bash
aws sso login --profile alert-dev
```

### Step 2: Run sso alias with option 5

```bash
echo "5" | sso
```

### Step 3: Export environment variables

After the sso command displays environment variables, parse and export each one shown on screen.

The output typically looks like:

```
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
export AWS_REGION=...
```

Run each export command shown.

### Step 4: Run alert-dev alias

```bash
alert-dev
```

## Important Notes

- Make sure you have the `sso` and `alert-dev` aliases defined in your shell
- The AWS SSO login may open a browser window for authentication
- Environment variables are exported in the current shell session
- If any step fails, report the error and stop the workflow

## Execution

**Execute these commands now in sequence, waiting for each to complete before proceeding to the next.**
