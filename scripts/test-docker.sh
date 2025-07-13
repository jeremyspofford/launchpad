#!/usr/bin/env bash

set -euo pipefail

# ============================================================================ #
# Docker Testing Script for Dotfiles
# ============================================================================ #

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test functions
test_minimal() {
    log "Testing minimal installation..."
    
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" build test-minimal; then
        success "Minimal installation build succeeded"
    else
        error "Minimal installation build failed"
        return 1
    fi
    
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" run --rm test-minimal; then
        success "Minimal installation test passed"
    else
        error "Minimal installation test failed"
        return 1
    fi
}

test_full() {
    log "Testing full installation..."
    
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" build test-full; then
        success "Full installation build succeeded"
    else
        error "Full installation build failed"
        return 1
    fi
    
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" run --rm test-full; then
        success "Full installation test passed"
    else
        error "Full installation test failed"
        return 1
    fi
}

test_ubuntu_versions() {
    log "Testing on different Ubuntu versions..."
    
    local versions=("20" "22" "24")
    local failed_versions=()
    
    for version in "${versions[@]}"; do
        log "Testing Ubuntu ${version}.04..."
        
        if docker-compose -f "$PROJECT_DIR/docker-compose.yml" build "ubuntu-${version}"; then
            if docker-compose -f "$PROJECT_DIR/docker-compose.yml" run --rm "ubuntu-${version}"; then
                success "Ubuntu ${version}.04 test passed"
            else
                error "Ubuntu ${version}.04 test failed"
                failed_versions+=("${version}")
            fi
        else
            error "Ubuntu ${version}.04 build failed"
            failed_versions+=("${version}")
        fi
    done
    
    if [[ ${#failed_versions[@]} -gt 0 ]]; then
        error "Failed Ubuntu versions: ${failed_versions[*]}"
        return 1
    else
        success "All Ubuntu versions passed"
    fi
}

test_production() {
    log "Testing production build..."
    
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" build production; then
        success "Production build succeeded"
    else
        error "Production build failed"
        return 1
    fi
    
    # Test that the production container can start
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" run --rm production zsh -c "echo 'Production container works'"; then
        success "Production container test passed"
    else
        error "Production container test failed"
        return 1
    fi
}

cleanup() {
    log "Cleaning up Docker resources..."
    
    # Stop and remove containers
    docker-compose -f "$PROJECT_DIR/docker-compose.yml" down --remove-orphans 2>/dev/null || true
    
    # Remove dangling images
    docker image prune -f 2>/dev/null || true
    
    success "Cleanup completed"
}

start_development() {
    log "Starting development environment..."
    
    if docker-compose -f "$PROJECT_DIR/docker-compose.yml" build development; then
        success "Development environment built"
        log "Starting interactive development container..."
        log "Use 'exit' to leave the container"
        docker-compose -f "$PROJECT_DIR/docker-compose.yml" run --rm development
    else
        error "Failed to build development environment"
        return 1
    fi
}

show_usage() {
    cat << EOF
Usage: $0 [COMMAND]

Test dotfiles installation using Docker containers.

COMMANDS:
    minimal         Test minimal installation only
    full            Test full installation
    ubuntu          Test on different Ubuntu versions
    production      Test production build
    all             Run all tests (default)
    dev             Start interactive development environment
    cleanup         Clean up Docker resources
    help            Show this help message

EXAMPLES:
    $0              # Run all tests
    $0 minimal      # Test minimal installation only
    $0 dev          # Start development environment
    $0 cleanup      # Clean up Docker resources

EOF
}

main() {
    cd "$PROJECT_DIR"
    
    local command="${1:-all}"
    
    case "$command" in
        minimal)
            test_minimal
            ;;
        full)
            test_full
            ;;
        ubuntu)
            test_ubuntu_versions
            ;;
        production)
            test_production
            ;;
        all)
            log "Running all Docker tests..."
            test_minimal
            test_full
            test_ubuntu_versions
            test_production
            success "All Docker tests completed"
            ;;
        dev|development)
            start_development
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Check if Docker and docker-compose are available
if ! command -v docker >/dev/null 2>&1; then
    error "Docker is not installed or not in PATH"
    exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    error "docker-compose is not installed or not in PATH"
    exit 1
fi

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi