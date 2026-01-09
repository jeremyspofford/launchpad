# Templates

Reusable tooling templates for copying into other repositories.

## Available Templates

| Template | Description |
|----------|-------------|
| [logger.sh](./logger.sh) | Shared bash logger with colors, sections, key-value logging |
| [terraform-formatter](./terraform-formatter/) | Lefthook + Docker hook for `terraform fmt` without local install |

## Usage

1. Browse the template directory
2. Read the README for setup instructions
3. Copy the files to your target repository
4. Customize paths/settings as needed

## Contributing Templates

When adding a new template:

1. Create a directory under `templates/`
2. Include a `README.md` with setup instructions
3. Make scripts executable (`chmod +x`)
4. Test in a real repository before committing
