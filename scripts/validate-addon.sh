#!/bin/bash
# XenForo Addon Validation Script
# Run this before uploading any addon version
# Place in: scripts/validate-addon.sh

set -e

ADDON_PATH="${1:-upload/src/addons/IC/CryptoMining}"
DATA_PATH="$ADDON_PATH/_data"

echo "================================================"
echo "XenForo Addon Validation Script"
echo "================================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check if data directory exists
if [ ! -d "$DATA_PATH" ]; then
    echo -e "${RED}❌ ERROR: _data directory not found at $DATA_PATH${NC}"
    exit 1
fi

cd "$DATA_PATH"

echo "Checking addon at: $DATA_PATH"
echo ""

# ============================================================================
# TEST 1: XML File Validation
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 1: Validating XML Structure"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for file in *.xml; do
    if [ -f "$file" ]; then
        echo -n "Checking $file... "
        if xmllint --noout "$file" 2>/dev/null; then
            echo -e "${GREEN}✅ Valid${NC}"
        else
            echo -e "${RED}❌ INVALID XML${NC}"
            xmllint --noout "$file" 2>&1 | head -5
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""

# ============================================================================
# TEST 2: XML Declaration Format
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 2: Checking XML Declarations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CORRECT_DECLARATION="<?xml version='1.0' encoding='utf-8'?>"

for file in *.xml; do
    if [ -f "$file" ]; then
        FIRST_LINE=$(head -1 "$file")
        echo -n "Checking $file... "
        
        if [ "$FIRST_LINE" == "$CORRECT_DECLARATION" ]; then
            echo -e "${GREEN}✅ Correct${NC}"
        else
            echo -e "${RED}❌ WRONG DECLARATION${NC}"
            echo "   Expected: $CORRECT_DECLARATION"
            echo "   Found:    $FIRST_LINE"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""

# ============================================================================
# TEST 3: File Encoding Check
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 3: Checking File Encodings"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for file in *.xml; do
    if [ -f "$file" ]; then
        echo -n "Checking $file... "
        ENCODING=$(file -i "$file" | grep -o 'charset=[^ ]*' | cut -d= -f2)
        
        if [ "$ENCODING" == "utf-8" ] || [ "$ENCODING" == "us-ascii" ]; then
            echo -e "${GREEN}✅ UTF-8${NC}"
        else
            echo -e "${RED}❌ WRONG ENCODING: $ENCODING${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""

# ============================================================================
# TEST 4: Unescaped Ampersands in templates.xml
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 4: Checking for Unescaped Ampersands"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "templates.xml" ]; then
    echo -n "Scanning templates.xml... "
    
    # Find lines with & that aren't entity references
    UNESCAPED=$(grep -n '&[^a]' templates.xml | \
                grep -v '&amp;' | \
                grep -v '&lt;' | \
                grep -v '&gt;' | \
                grep -v '&quot;' | \
                grep -v '&apos;' || true)
    
    if [ -z "$UNESCAPED" ]; then
        echo -e "${GREEN}✅ No unescaped ampersands${NC}"
    else
        echo -e "${RED}❌ FOUND UNESCAPED AMPERSANDS${NC}"
        echo "$UNESCAPED" | head -10
        if [ $(echo "$UNESCAPED" | wc -l) -gt 10 ]; then
            echo "... and $(($(echo "$UNESCAPED" | wc -l) - 10)) more"
        fi
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}⚠️  templates.xml not found (skipping)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================================================
# TEST 5: Brace Counting in LESS Templates
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 5: Counting Braces in LESS Templates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "templates.xml" ]; then
    # Extract LESS templates and check brace balance
    LESS_TEMPLATES=$(grep 'title=".*\.less"' templates.xml | sed 's/.*title="\([^"]*\)".*/\1/')
    
    for template in $LESS_TEMPLATES; do
        echo -n "Checking $template... "
        
        # This is a simplified check - counts braces in entire templates.xml
        # A more sophisticated version would extract each template separately
        OPEN=$(grep -o '{' templates.xml | wc -l)
        CLOSE=$(grep -o '}' templates.xml | wc -l)
        
        if [ "$OPEN" -eq "$CLOSE" ]; then
            echo -e "${GREEN}✅ Balanced ($OPEN pairs)${NC}"
        else
            echo -e "${RED}❌ UNBALANCED (open: $OPEN, close: $CLOSE)${NC}"
            ERRORS=$((ERRORS + 1))
        fi
        break  # Only check once for all LESS templates
    done
else
    echo -e "${YELLOW}⚠️  templates.xml not found (skipping)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================================================
# TEST 6: Version Consistency
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 6: Checking Version Consistency"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -f "../addon.json" ]; then
    ADDON_VERSION_ID=$(grep -o '"version_id": [0-9]*' ../addon.json | grep -o '[0-9]*')
    ADDON_VERSION_STRING=$(grep -o '"version_string": "[^"]*"' ../addon.json | sed 's/"version_string": "\([^"]*\)"/\1/')
    
    echo "addon.json version: $ADDON_VERSION_STRING ($ADDON_VERSION_ID)"
    echo ""
    
    # Check template versions
    if [ -f "templates.xml" ]; then
        TEMPLATE_VERSIONS=$(grep -o 'version_id="[0-9]*"' templates.xml | sort -u)
        echo "Template version_ids found:"
        echo "$TEMPLATE_VERSIONS" | sed 's/version_id="\([0-9]*\)"/  - \1/'
        
        # Check if addon version exists in templates
        if echo "$TEMPLATE_VERSIONS" | grep -q "version_id=\"$ADDON_VERSION_ID\""; then
            echo -e "${GREEN}✅ Addon version found in templates${NC}"
        else
            echo -e "${YELLOW}⚠️  Addon version ($ADDON_VERSION_ID) not found in templates${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
    
    echo ""
    
    # Check phrase versions
    if [ -f "phrases.xml" ]; then
        PHRASE_VERSIONS=$(grep -o 'version_id="[0-9]*"' phrases.xml | sort -u)
        echo "Phrase version_ids found:"
        echo "$PHRASE_VERSIONS" | sed 's/version_id="\([0-9]*\)"/  - \1/'
        
        # Check if addon version exists in phrases
        if echo "$PHRASE_VERSIONS" | grep -q "version_id=\"$ADDON_VERSION_ID\""; then
            echo -e "${GREEN}✅ Addon version found in phrases${NC}"
        else
            echo -e "${YELLOW}⚠️  Addon version ($ADDON_VERSION_ID) not found in phrases${NC}"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
else
    echo -e "${YELLOW}⚠️  addon.json not found (skipping)${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================================================
# TEST 7: Dynamic Phrase Calls Check
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "TEST 7: Checking for Dynamic Phrase Calls"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd ..

DYNAMIC_PHRASES=$(grep -r "phrase.*\." Entity/ Repository/ Pub/ 2>/dev/null || true)

if [ -z "$DYNAMIC_PHRASES" ]; then
    echo -e "${GREEN}✅ No dynamic phrase calls detected${NC}"
else
    echo -e "${YELLOW}⚠️  Potential dynamic phrase calls found:${NC}"
    echo "$DYNAMIC_PHRASES" | head -10
    if [ $(echo "$DYNAMIC_PHRASES" | wc -l) -gt 10 ]; then
        echo "... and $(($(echo "$DYNAMIC_PHRASES" | wc -l) - 10)) more"
    fi
    echo ""
    echo "Review these manually. If they concatenate strings, use switch statements instead."
    WARNINGS=$((WARNINGS + 1))
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo "================================================"
echo "VALIDATION SUMMARY"
echo "================================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED${NC}"
    echo ""
    echo "Addon is ready for upload!"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  $WARNINGS WARNING(S) - Review recommended${NC}"
    echo ""
    echo "Addon may be ready, but review warnings above."
    exit 0
else
    echo -e "${RED}❌ $ERRORS ERROR(S) FOUND${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  $WARNINGS WARNING(S) - Review recommended${NC}"
    fi
    echo ""
    echo "Fix errors before uploading!"
    exit 1
fi
