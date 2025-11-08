# Dotfiles Tests

This directory contains test scripts for the dotfiles repository components.

## Running Tests

### Sync Script Tests

Test the `sync.sh` script functionality:

```bash
bash tests/test_sync.sh
```

The test suite verifies:

- Script exists and is executable
- Help functionality (`-h`, `--help`)
- Dry run mode (`-n`, `--dry-run`)
- Verbose mode (`-v`, `--verbose`)
- Force mode (`-f`, `--force`)
- Invalid flag handling
- Multiple flag combinations
- Error handling and path resolution

## Writing New Tests

Tests use a simple assertion framework defined in the test scripts:

- `assert_equal`: Check if two values are equal
- `assert_contains`: Check if a string contains a substring
- `assert_exit_code`: Check if a command exits with expected code

Example:

```bash
run_test "Test name" '
    output=$(command_to_test)
    assert_contains "$output" "expected text" "Error message if fails"
'
```

## Test Coverage

- ✅ `sync.sh` - Basic functionality and flag handling
- ⬜ Ansible playbook - Not yet implemented
- ⬜ Shell configurations - Not yet implemented

## Continuous Integration

These tests can be integrated into CI/CD pipelines to ensure changes don't break existing functionality.
