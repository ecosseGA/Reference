# Crypto Mining v1.9.0.7-13 - Lessons from Failed Builds

**What Went Wrong & How to Avoid It**

This document chronicles 7 failed addon versions and what we learned from each failure. These are real mistakes from real development, not theoretical problems.

---

## Timeline Overview

| Version | Problem | Root Cause | Time Lost |
|---------|---------|------------|-----------|
| v1.9.0.7 | CSS parse error | Missing closing brace | 15 min |
| v1.9.0.8 | Phrasing incomplete | Added phrase calls without definitions | 20 min |
| v1.9.0.9 | Invalid XML | Python ElementTree corrupted file | 30 min |
| v1.9.0.10 | Invalid XML | XML declaration quote format | 10 min |
| v1.9.0.11 | Invalid XML | Still wrong quote format | 10 min |
| v1.9.0.12 | Invalid XML | Unescaped ampersands in LESS | 15 min |
| v1.9.0.13 | Phrase literal error | Dynamic phrase concatenation | 30 min |

**Total time lost:** ~2 hours on preventable errors

---

## v1.9.0.7: CSS Syntax Error - Missing Closing Brace

### The Error
```
ParseError: missing closing `}` in public:ic_crypto.less on line 4860
```

### What Happened

When adding achievement CSS to `ic_crypto.less`, I added new sections after an existing `@media` query but forgot to close the query before starting the new section:

```less
@media (max-width: 768px)
{
    .cryptoMarket-eventAlert-meta
    {
        // ... styles ...
    }
    // ❌ MISSING CLOSING BRACE HERE

// ====== ACHIEVEMENTS PAGE ======
.cryptoAchievementList
{
    // ... new code ...
}
```

### The Fix

Added the missing closing brace:

```less
@media (max-width: 768px)
{
    .cryptoMarket-eventAlert-meta
    {
        // ... styles ...
    }
}  // ✅ ADDED THIS

// ====== ACHIEVEMENTS PAGE ======
```

### Lesson Learned

**Always count braces when editing LESS/CSS files.**

**Prevention:**
1. Use an editor with brace matching
2. After adding CSS, do a quick brace count:
   ```bash
   grep -o '{' ic_crypto.less | wc -l  # Count opening
   grep -o '}' ic_crypto.less | wc -l  # Count closing
   # Numbers should match
   ```
3. Or use a LESS validator:
   ```bash
   lessc ic_crypto.less /dev/null  # Validates without output
   ```

---

## v1.9.0.8: Incomplete Phrasing Implementation

### The Error

Achievements page showed NULL values or raw database text instead of phrased content.

### What Happened

I updated templates to USE phrases:
```html
<h4>{{ phrase('ic_crypto_achievement_title.' . $achievement.achievement_key) }}</h4>
```

But **forgot to create the phrase definitions** in phrases.xml.

XenForo looked for `ic_crypto_achievement_title.first_dig` and found nothing.

### The Fix

Added 36 missing phrases to phrases.xml:
- 15 achievement titles
- 15 achievement descriptions
- 6 difficulty tiers

### Lesson Learned

**Changing templates to use phrases requires creating the phrase definitions.**

It's a two-step process:
1. Template references the phrase
2. Phrase must exist in phrases.xml

**Prevention:**
```bash
# After updating templates, check for undefined phrases:
grep "phrase('ic_crypto_" templates.xml | \
  sed "s/.*phrase('\([^']*\)').*/\1/" | \
  sort -u > used_phrases.txt

# Then verify each phrase exists in phrases.xml
while read phrase; do
    grep -q "title=\"$phrase\"" phrases.xml || echo "Missing: $phrase"
done < used_phrases.txt
```

---

## v1.9.0.9: Python ElementTree Corrupted XML

### The Error
```
InvalidArgumentException: Invalid XML in file
```

### What Happened

I used Python's ElementTree library to add phrases:

```python
import xml.etree.ElementTree as ET
tree = ET.parse('phrases.xml')
root = tree.getroot()

# Add new phrase
new_phrase = ET.SubElement(root, 'phrase')
new_phrase.set('title', 'example')
new_phrase.text = 'Example text'

tree.write('phrases.xml', encoding='utf-8', xml_declaration=True)
```

**This completely destroyed the file:**

Before (correct):
```xml
<?xml version='1.0' encoding='utf-8'?>
<phrases>
	<phrase title="example_one">Text</phrase>
	<phrase title="example_two">Text</phrase>
</phrases>
```

After ElementTree (broken):
```xml
<?xml version="1.0" encoding="utf-8"?>
<phrases><phrase title="example_one">Text</phrase><phrase title="example_two">Text</phrase><phrase title="example_three">Text</phrase></phrases>
```

**Changes made by ElementTree:**
1. ❌ Changed single quotes to double quotes in declaration
2. ❌ Removed all indentation
3. ❌ Compressed everything to one line
4. ❌ Made file unreadable and invalid for XenForo

### The Fix

Deleted corrupted file and manually reconstructed from backup:
```bash
# Restore from last working version
tar -xzf IC_CryptoMining_v1.9.0.7.tar.gz
cp upload/.../phrases.xml /current/location/

# Manually add new content
cat >> phrases.xml << 'EOF'
	<phrase title="new_phrase">New content</phrase>
EOF
```

### Lesson Learned

**NEVER use Python ElementTree (or any XML library) for XenForo XML files.**

**Why libraries fail:**
- They apply their own formatting standards
- They use double quotes (XenForo needs single)
- They remove custom indentation
- They don't preserve XenForo's specific structure

**The ONLY safe methods:**
1. Manual string construction with cat/echo
2. Simple sed replacements
3. The view tool (read-only)

### Prevention

**Add to your development rules:**
```bash
# ❌ NEVER DO THIS:
import xml.etree.ElementTree as ET  # FORBIDDEN
from lxml import etree  # FORBIDDEN
use DOMDocument  # FORBIDDEN

# ✅ ONLY DO THIS:
cat >> file.xml << 'EOF'
	<element>content</element>
EOF

sed -i 's/old/new/g' file.xml
```

---

## v1.9.0.10 & v1.9.0.11: XML Declaration Quote Format

### The Error
```
InvalidArgumentException: Invalid XML in file
```

### What Happened

After recreating phrases.xml from scratch, I used double quotes in the XML declaration:

```xml
<?xml version="1.0" encoding="utf-8"?>  ❌ Double quotes
```

XenForo requires single quotes:

```xml
<?xml version='1.0' encoding='utf-8'?>  ✅ Single quotes
```

### Why Two Failed Versions?

**v1.9.0.10:** Used create_file tool which generates double quotes by default  
**v1.9.0.11:** Tried to fix with sed but targeted wrong part of declaration

### The Fix

```bash
sed -i "1s/.*/<?xml version='1.0' encoding='utf-8'?>/" phrases.xml
```

### Lesson Learned

**XenForo XML declaration MUST use single quotes.**

This is not a preference, it's a requirement. The parser specifically checks for this format.

**Prevention:**

Always start XML files with this exact line:
```xml
<?xml version='1.0' encoding='utf-8'?>
```

**Check before uploading:**
```bash
head -1 phrases.xml
# Should show: <?xml version='1.0' encoding='utf-8'?>
# If not, fix it immediately
```

---

## v1.9.0.12: Unescaped Ampersands in LESS CSS

### The Error
```
InvalidArgumentException: Invalid XML in file
templates.xml:3971: parser error : xmlParseEntityRef: no name
	&.cryptoTransactions-badge--mining
	 ^
```

### What Happened

When I added transaction badge CSS, I used LESS nested selectors with ampersands:

```less
.cryptoTransactions-badge
{
    &.cryptoTransactions-badge--mining { }   ❌ Unescaped &
    &.cryptoTransactions-badge--block { }    ❌ Unescaped &
    &.cryptoTransactions-badge--sell { }     ❌ Unescaped &
}
```

**In XML files, `&` is a reserved character and MUST be escaped.**

### The Fix

```bash
sed -i 's/\t&\.cryptoTransactions-badge--/\t\&amp;.cryptoTransactions-badge--/g' templates.xml
```

Result:
```less
.cryptoTransactions-badge
{
    &amp;.cryptoTransactions-badge--mining { }   ✅ Escaped
    &amp;.cryptoTransactions-badge--block { }    ✅ Escaped
    &amp;.cryptoTransactions-badge--sell { }     ✅ Escaped
}
```

### Lesson Learned

**LESS nested selectors (`&`) must be escaped as `&amp;` in XML files.**

Common LESS patterns that need escaping:
- `&.classname` → `&amp;.classname`
- `&:hover` → `&amp;:hover`
- `&::before` → `&amp;::before`
- `&[attr]` → `&amp;[attr]`

**Prevention:**

After adding any LESS CSS to templates.xml:
```bash
# Check for unescaped ampersands
grep -n '&[^a]' templates.xml | \
  grep -v '&amp;' | \
  grep -v '&lt;' | \
  grep -v '&gt;'

# Any output = you have unescaped ampersands
```

**Or validate immediately:**
```bash
xmllint --noout templates.xml
# Will show parse errors if ampersands aren't escaped
```

---

## v1.9.0.13: Dynamic Phrase Concatenation

### The Error
```
Line 67: Phrase name must be literal - Template name: public:ic_crypto_achievements
```

### What Happened

Templates called `{$achievement.title}` which invoked this entity method:

```php
public function getTitle()
{
    return \XF::phrase('ic_crypto_achievement_title.' . $this->achievement_key);
    //                                              ^^^ Dynamic concatenation
}
```

XenForo's template compiler traces through entity getters and flags any `\XF::phrase()` calls that don't use literal strings.

**Even though the concatenation is in PHP code, not the template, XenForo detects it.**

### The Fix

Replaced with explicit switch statement:

```php
public function getTitle()
{
    switch ($this->achievement_key)
    {
        case 'first_dig':
            return \XF::phrase('ic_crypto_achievement_title.first_dig');
        case 'prospector':
            return \XF::phrase('ic_crypto_achievement_title.prospector');
        // ... 13 more cases ...
        default:
            return $this->achievement_key;
    }
}
```

All 15 achievement titles, 15 descriptions, and 6 difficulty tiers needed switch statements.

### Lesson Learned

**Phrase names must be literal strings, even in entity methods called from templates.**

**Why XenForo requires this:**
1. Enables compile-time phrase optimization
2. Allows proper phrase caching
3. Makes phrase management tools work
4. Prevents runtime lookup errors

**Prevention:**

Before creating entity getter methods that return phrases:

❌ **Don't do this:**
```php
\XF::phrase('prefix.' . $variable)
\XF::phrase("string_{$var}")
$name = 'phrase_' . $key;
\XF::phrase($name)
```

✅ **Do this:**
```php
switch ($variable)
{
    case 'value1':
        return \XF::phrase('exact_phrase_name');
    case 'value2':
        return \XF::phrase('another_exact_name');
}
```

**Check your code:**
```bash
# Find potentially problematic phrase calls
grep -r "phrase.*\." Entity/ Repository/ Pub/

# Review each match - if it's concatenation, needs switch
```

---

## Summary: The Critical Mistakes

### 1. Using Wrong Tools
- ❌ Python ElementTree
- ❌ XML auto-formatters
- ✅ Manual construction only

### 2. Not Validating Before Upload
```bash
# Should have run these EVERY TIME:
xmllint --noout *.xml
grep -n '&[^a]' templates.xml | grep -v '&amp;'
head -1 phrases.xml  # Check declaration
```

### 3. Not Understanding XenForo Requirements
- XML declaration needs single quotes
- Ampersands must be escaped in XML
- Phrase names must be literal
- Two-step process: template + phrase definition

### 4. Not Testing Incrementally
Could have caught issues earlier by:
- Installing after each change
- Checking server error log immediately
- Validating XML after every edit

---

## Prevention Checklist

Use this before every addon upload:

```bash
#!/bin/bash
# Pre-Upload Validation Script

cd upload/src/addons/Vendor/Addon/_data

echo "1. Validating XML files..."
for file in *.xml; do
    xmllint --noout "$file" || exit 1
done

echo "2. Checking XML declarations..."
for file in *.xml; do
    first=$(head -1 "$file")
    if [[ "$first" != "<?xml version='1.0' encoding='utf-8'?>" ]]; then
        echo "❌ Wrong declaration in $file"
        exit 1
    fi
done

echo "3. Checking for unescaped ampersands in templates.xml..."
if grep -q '&[^a]' templates.xml | grep -v '&amp;'; then
    echo "❌ Found unescaped ampersands"
    exit 1
fi

echo "4. Checking for dynamic phrase calls..."
if grep -r "phrase.*\." ../Entity/ ../Repository/ 2>/dev/null; then
    echo "⚠️  Found potential dynamic phrase calls - review manually"
fi

echo "✅ All checks passed"
```

---

## Time Savings

If I had followed these rules from the start:

- v1.9.0.7: Could have been v1.9.0.1 (CSS validated)
- v1.9.0.8-13: Never would have existed

**Actual versions needed:** 2 (one for implementation, one for CSS fix)  
**Versions created:** 7  
**Wasted iterations:** 5

**Time that could have been saved:** ~1.5 hours

---

## Key Takeaway

**The pattern in all these failures:**

1. Made a change
2. Didn't validate
3. Uploaded
4. XenForo rejected it
5. Had to debug and fix

**The solution:**

1. Make a change
2. **Validate immediately**
3. Fix any issues
4. Upload
5. Success

**Add 2 minutes of validation to save 30 minutes of debugging.**

---

## Reference: Working From v1.9.0.7

If you need a clean starting point, v1.9.0.7 was the last version that installed correctly (before phrasing was added). All subsequent versions were trying to add achievement phrases.

**What v1.9.0.7 had correct:**
- ✅ Valid XML in all files
- ✅ Proper CSS syntax
- ✅ Clean installation
- ✅ Working templates

**What was missing:**
- Achievement phrase definitions
- Phrased template output
- Transaction badge HTML/CSS

Starting from a known-good version and adding features incrementally would have prevented most issues.
