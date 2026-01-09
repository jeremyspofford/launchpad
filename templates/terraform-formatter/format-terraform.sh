#!/usr/bin/env bash
# Format Terraform files using Docker (no local Terraform required)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Build the formatter image if needed
docker build -q -f "$REPO_ROOT/.docker/terraform-fmt.Dockerfile" -t tf-fmt "$REPO_ROOT" >/dev/null

# Run formatter
echo "Formatting Terraform files..."
docker run --rm -v "$REPO_ROOT:/workspace" tf-fmt

echo "✓ Terraform files formatted"
