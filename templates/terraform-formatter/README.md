# Terraform Formatter Hook

A Dockerized Terraform formatter that runs via Lefthook git hooks. Works even if developers don't have Terraform installed locally.

## What It Does

When files in `terraform/` (or your configured path) are changed:
1. Lefthook triggers the pre-commit hook
2. Docker runs a container with Terraform
3. `terraform fmt` formats all `.tf` files
4. Formatted files are staged automatically

## Setup

### 1. Install Lefthook

```bash
# Via mise (recommended)
mise install lefthook

# Or via brew
brew install lefthook

# Or via npm
npm install -g lefthook
```

### 2. Copy Files to Your Repo

```bash
cp Dockerfile .docker/terraform-fmt.Dockerfile
cp lefthook.yml lefthook.yml
cp format-terraform.sh scripts/format-terraform.sh
chmod +x scripts/format-terraform.sh
```

### 3. Install Hooks

```bash
lefthook install
```

## Usage

Once installed, the hook runs automatically on `git commit` when Terraform files change.

### Manual Run

```bash
# Format all Terraform files
./scripts/format-terraform.sh

# Or via Docker directly
docker build -f .docker/terraform-fmt.Dockerfile -t tf-fmt .
docker run --rm -v $(pwd):/workspace tf-fmt
```

## Customization

Edit `lefthook.yml` to change:
- `glob`: Which files trigger the hook (default: `terraform/**/*.tf`)
- `root`: Base directory for Terraform files

## Requirements

- Docker
- Lefthook
- No Terraform installation required!
