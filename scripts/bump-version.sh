#!/bin/bash
#
# Semantic Version Bump Script
# Analyzes conventional commits since last tag and bumps version accordingly
#
# Commit types that trigger version bumps:
# - feat/feature: Minor version bump (1.0.0 -> 1.1.0)
# - fix/patch: Patch version bump (1.0.0 -> 1.0.1)
# - feat!/fix! (with !): Major version bump (1.0.0 -> 2.0.0)
# - Other types (docs, chore, refactor, etc.): No version bump

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
VERBOSE=false
SKIP_TAG=false
SKIP_PUSH=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --skip-tag)
            SKIP_TAG=true
            shift
            ;;
        --skip-push)
            SKIP_PUSH=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run     Show what would be done without making changes"
            echo "  -v, --verbose Show detailed commit analysis"
            echo "  --skip-tag    Don't create git tag"
            echo "  --skip-push   Don't push tag to remote"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Get the latest tag
get_latest_tag() {
    git describe --tags --abbrev=0 2>/dev/null || echo ""
}

# Parse version string into components
parse_version() {
    local version=$1
    # Remove 'v' prefix if present
    version=${version#v}

    local major minor patch
    IFS='.' read -r major minor patch <<< "$version"

    echo "$major $minor $patch"
}

# Determine version bump type based on commits
analyze_commits() {
    local since_ref=$1
    local bump_type="none"
    local has_breaking=false
    local has_feat=false
    local has_fix=false

    if [ -z "$since_ref" ]; then
        # No tags yet, analyze all commits
        commits=$(git log --pretty=format:"%s" --no-merges)
    else
        # Analyze commits since last tag
        commits=$(git log "${since_ref}..HEAD" --pretty=format:"%s" --no-merges)
    fi

    if [ -z "$commits" ]; then
        log_warning "No new commits since last tag"
        return 1
    fi

    # Check for breaking changes (feat!: or fix!: syntax)
    if echo "$commits" | grep -qiE "^(feat|feature|fix|patch)!(\(.+\))?:"; then
        has_breaking=true
    fi

    # Check for feat/feature commits
    if echo "$commits" | grep -qiE "^(feat|feature)(\(.+\))?:"; then
        has_feat=true
    fi

    # Check for fix/patch commits
    if echo "$commits" | grep -qiE "^(fix|patch)(\(.+\))?:"; then
        has_fix=true
    fi

    # Determine bump type
    if [ "$has_breaking" = true ]; then
        bump_type="major"
    elif [ "$has_feat" = true ]; then
        bump_type="minor"
    elif [ "$has_fix" = true ]; then
        bump_type="patch"
    fi

    if [ "$VERBOSE" = true ]; then
        log_info "Commit analysis:"
        echo "$commits" | while IFS= read -r commit; do
            echo "  - $commit"
        done
        echo ""
        log_info "Breaking changes: $has_breaking"
        log_info "Features: $has_feat"
        log_info "Fixes: $has_fix"
        echo ""
    fi

    echo "$bump_type"
}

# Calculate new version
bump_version() {
    local current_version=$1
    local bump_type=$2

    # Parse current version
    read -r major minor patch <<< "$(parse_version "$current_version")"

    # Handle empty version (first tag)
    if [ -z "$major" ]; then
        major=0
        minor=1
        patch=0
    fi

    # Bump according to type
    case $bump_type in
        major)
            ((major++))
            minor=0
            patch=0
            ;;
        minor)
            ((minor++))
            patch=0
            ;;
        patch)
            ((patch++))
            ;;
        *)
            log_error "Invalid bump type: $bump_type"
            exit 1
            ;;
    esac

    echo "${major}.${minor}.${patch}"
}

# Create git tag
create_tag() {
    local version=$1
    local tag="v${version}"

    if [ "$DRY_RUN" = true ]; then
        log_info "[DRY RUN] Would create tag: $tag"
        return 0
    fi

    if [ "$SKIP_TAG" = true ]; then
        log_warning "Skipping tag creation (--skip-tag)"
        echo "$tag"
        return 0
    fi

    # Create annotated tag
    git tag -a "$tag" -m "Release $tag"
    log_success "Created tag: $tag"

    # Push tag to remote
    if [ "$SKIP_PUSH" = false ]; then
        git push origin "$tag"
        log_success "Pushed tag to remote"
    else
        log_warning "Skipping push to remote (--skip-push)"
    fi

    echo "$tag"
}

# Main execution
main() {
    log_info "Semantic Version Bump"
    echo ""

    # Ensure we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not a git repository"
        exit 1
    fi

    # Get latest tag
    latest_tag=$(get_latest_tag)

    if [ -z "$latest_tag" ]; then
        log_warning "No existing tags found. Will create initial version."
        current_version="0.0.0"
    else
        current_version="${latest_tag#v}"
        log_info "Current version: v${current_version}"
    fi

    # Analyze commits and determine bump type
    bump_type=$(analyze_commits "$latest_tag")

    if [ "$bump_type" = "none" ] || [ -z "$bump_type" ]; then
        log_warning "No version bump needed (no feat/fix commits found)"
        exit 0
    fi

    log_info "Bump type: $bump_type"

    # Calculate new version
    new_version=$(bump_version "$current_version" "$bump_type")

    echo ""
    log_success "Version bump: v${current_version} → v${new_version}"

    # Create tag
    if [ "$DRY_RUN" = false ]; then
        echo ""
        new_tag=$(create_tag "$new_version")
        echo ""
        log_success "Release complete: $new_tag"
    else
        echo ""
        log_info "[DRY RUN] Run without --dry-run to create the tag"
    fi
}

main
