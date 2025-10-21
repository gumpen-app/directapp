#!/bin/bash
# DirectApp - Unified Deployment Script
# Deploys to Dokploy environments using CLI and API
#
# Usage:
#   ./scripts/deploy.sh staging   # Deploy to staging
#   ./scripts/deploy.sh production # Deploy to production
#   ./scripts/deploy.sh --help     # Show help

set -e

# ========================================
# Configuration
# ========================================
DOKPLOY_URL="https://deploy.onecom.ai"
DOKPLOY_API_KEY="${DOKPLOY_API_KEY:-g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG}"

# Compose IDs
STAGING_COMPOSE_ID="25M8QUdsDQ97nW5YqPYLZ"
PRODUCTION_COMPOSE_ID="YKhjz62y5ikBunLd6G2BS"

# Domains
STAGING_DOMAIN="staging-gapp.coms.no"
PRODUCTION_DOMAIN="gapp.coms.no"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ========================================
# Functions
# ========================================

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        print_error "jq is not installed. Install with: sudo apt install jq"
        exit 1
    fi
    print_success "jq installed"

    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed"
        exit 1
    fi
    print_success "curl installed"

    # Check if we're in the right directory
    if [ ! -f "docker-compose.staging.yml" ]; then
        print_error "docker-compose.staging.yml not found. Run from project root."
        exit 1
    fi
    print_success "In project root directory"
}

# Validate environment file
validate_env() {
    local ENV=$1
    local ENV_FILE=".env.${ENV}"

    print_header "Validating Environment: $ENV"

    if [ ! -f "$ENV_FILE" ]; then
        print_warning "$ENV_FILE not found (will use Dokploy environment variables)"
        return 0
    fi

    # Check for required variables
    local REQUIRED_VARS=(
        "DIRECTUS_KEY"
        "DIRECTUS_SECRET"
        "DB_PASSWORD"
        "PUBLIC_URL"
    )

    local MISSING=0
    for VAR in "${REQUIRED_VARS[@]}"; do
        if ! grep -q "^${VAR}=" "$ENV_FILE"; then
            print_error "Missing required variable: $VAR"
            MISSING=1
        fi
    done

    if [ $MISSING -eq 1 ]; then
        print_error "Environment validation failed"
        exit 1
    fi

    print_success "Environment validation passed"
}

# Build extensions
build_extensions() {
    print_header "Building Extensions"

    cd extensions

    if [ ! -f "package.json" ]; then
        print_warning "No extensions to build"
        cd ..
        return 0
    fi

    print_info "Installing dependencies..."
    pnpm install --frozen-lockfile

    print_info "Building all extensions..."
    pnpm build

    cd ..
    print_success "Extensions built successfully"
}

# Deploy to Dokploy
deploy_to_dokploy() {
    local ENV=$1
    local COMPOSE_ID=$2
    local DOMAIN=$3

    print_header "Deploying to $ENV"

    # Trigger deployment via API
    print_info "Triggering deployment..."

    RESPONSE=$(curl -s -X POST "$DOKPLOY_URL/api/compose.deploy" \
        -H "x-api-key: $DOKPLOY_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"composeId\": \"$COMPOSE_ID\"}")

    if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
        print_error "Deployment failed:"
        echo "$RESPONSE" | jq .
        exit 1
    fi

    print_success "Deployment triggered"

    # Wait for deployment
    print_info "Waiting for deployment to complete..."
    sleep 30

    # Health check
    print_info "Running health check..."
    if curl -sf "https://$DOMAIN/server/health" > /dev/null; then
        print_success "Health check passed"
    else
        print_error "Health check failed"
        exit 1
    fi

    print_success "$ENV deployment completed successfully!"
}

# Deploy staging
deploy_staging() {
    print_header "DirectApp - Deploy to Staging"

    check_prerequisites
    validate_env "staging"
    build_extensions
    deploy_to_dokploy "STAGING" "$STAGING_COMPOSE_ID" "$STAGING_DOMAIN"

    echo ""
    print_success "Staging deployment complete!"
    print_info "URL: https://$STAGING_DOMAIN/admin"
    echo ""
}

# Deploy production
deploy_production() {
    print_header "DirectApp - Deploy to Production"

    print_warning "You are about to deploy to PRODUCTION"
    echo ""
    read -p "Type 'yes' to continue: " CONFIRM

    if [ "$CONFIRM" != "yes" ]; then
        print_info "Deployment cancelled"
        exit 0
    fi

    check_prerequisites
    validate_env "production"
    build_extensions
    deploy_to_dokploy "PRODUCTION" "$PRODUCTION_COMPOSE_ID" "$PRODUCTION_DOMAIN"

    echo ""
    print_success "Production deployment complete!"
    print_info "URL: https://$PRODUCTION_DOMAIN/admin"
    echo ""
    print_warning "Remember to:"
    echo "  1. Test the deployment"
    echo "  2. Monitor error logs"
    echo "  3. Check database migrations"
    echo ""
}

# Show help
show_help() {
    cat << EOF
DirectApp Deployment Script

Usage:
  ./scripts/deploy.sh <environment>

Environments:
  staging      Deploy to staging (https://staging-gapp.coms.no)
  production   Deploy to production (https://gapp.coms.no)

Options:
  --help       Show this help message

Examples:
  ./scripts/deploy.sh staging
  ./scripts/deploy.sh production

Prerequisites:
  - jq installed (sudo apt install jq)
  - curl installed
  - DOKPLOY_API_KEY environment variable (optional, has default)

Environment Files:
  .env.staging     - Staging configuration
  .env.production  - Production configuration

Notes:
  - Extensions are built automatically before deployment
  - Production requires manual confirmation
  - Health checks are performed after deployment
  - Deployment logs are shown in real-time

For more information, see: DOKPLOY_DEPLOYMENT_GUIDE.md
EOF
}

# ========================================
# Main
# ========================================

case "${1:-}" in
    staging)
        deploy_staging
        ;;
    production)
        deploy_production
        ;;
    --help|-h|help)
        show_help
        ;;
    *)
        print_error "Invalid environment: ${1:-<none>}"
        echo ""
        echo "Usage: ./scripts/deploy.sh {staging|production}"
        echo "Run './scripts/deploy.sh --help' for more information"
        exit 1
        ;;
esac
