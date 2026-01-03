# XenForo XML Validation Guide

**Critical Rules for XenForo 2.3+ Addon Development**

This document contains hard-learned lessons from real addon development failures. Follow these rules to avoid XML import errors, template compilation failures, and hours of debugging.

---

## 1. XML Declaration Format

### ✅ CORRECT (REQUIRED)
```xml
<?xml version='1.0' encoding='utf-8'?>
<phrases>
    <phrase title="example">Text here</phrase>
</phrases>
```

**Key requirements:**
- Use **single quotes** around version and encoding
- Lowercase `utf-8` (not UTF-8)
- No spaces around equals signs
- Must be first line (no BOM, no blank lines before)

### ❌ WRONG (Will cause "Invalid XML" error)
```xml
<?xml version="1.0" encoding="utf-8"?>  ❌ Double quotes
<?xml version='1.0' encoding='UTF-8'?>  ❌ Uppercase UTF-8
<?xml version = '1.0' encoding = 'utf-8'?>  ❌ Spaces around =
```

---

## 2. Entity Escaping in XML Files

XML has 5 reserved characters that MUST be escaped when used in content:

| Character | Escape As | Common In |
|-----------|-----------|-----------|
| `&` | `&amp;` | LESS nested selectors (`&.class`, `&:hover`) |
| `<` | `&lt;` | HTML tags in templates |
| `>` | `&gt;` | HTML tags in templates |
| `"` | `&quot;` | Attributes (rarely needed in CDATA) |
| `'` | `&apos;` | Attributes (rarely needed in CDATA) |

### Critical Example: LESS CSS in templates.xml

**❌ WRONG (Causes XML parse error):**
```xml
<template type="public" title="example.less"><![CDATA[
.myClass
{
    &.active { color: red; }      ❌ Unescaped ampersand
    &:hover { color: blue; }      ❌ Unescaped ampersand
}
]]></template>
```

**✅ CORRECT:**
```xml
<template type="public" title="example.less"><![CDATA[
.myClass
{
    &amp;.active { color: red; }  ✅ Escaped ampersand
    &amp;:hover { color: blue; }  ✅ Escaped ampersand
}
]]></template>
```

### HTML Templates

**❌ WRONG:**
```xml
<template type="public" title="example"><![CDATA[
<div class="example">
    {$content}
</div>
]]></template>
```

**✅ CORRECT:**
```xml
<template type="public" title="example"><![CDATA[
&lt;div class="example"&gt;
    {$content}
&lt;/div&gt;
]]></template>
```

**Exception:** Content inside `<![CDATA[...]]>` blocks doesn't need `<` and `>` escaped, but **ampersands still do**.

---

## 3. Phrase Name Literal Requirement

XenForo's template compiler requires all phrase names to be **literal strings**. This applies even to entity methods called from templates.

### ✅ CORRECT

**Entity Method:**
```php
public function getTitle()
{
    switch ($this->key)
    {
        case 'first_item':
            return \XF::phrase('addon_title.first_item');
        case 'second_item':
            return \XF::phrase('addon_title.second_item');
        default:
            return $this->key;
    }
}
```

**Template:**
```html
<h1>{$item.title}</h1>  <!-- Calls getTitle(), which uses literal phrases -->
```

### ❌ WRONG (Causes "Phrase name must be literal" error)

**Entity Method:**
```php
public function getTitle()
{
    // ❌ String concatenation
    return \XF::phrase('addon_title.' . $this->key);
}

public function getDifficultyText()
{
    // ❌ Variable interpolation
    return \XF::phrase("addon_difficulty_{$this->difficulty}");
}

public function getLabel()
{
    // ❌ Dynamic phrase name
    $phraseName = 'addon_label_' . $this->type;
    return \XF::phrase($phraseName);
}
```

**Why This Fails:**

XenForo's template compiler traces through entity getter methods and validates that all `\XF::phrase()` calls use literal strings. This enables:
1. Compile-time phrase optimization
2. Proper phrase caching
3. Phrase management tools to work correctly

**The Solution:** Always use switch statements with explicit cases.

---

## 4. File Structure & Formatting

### Indentation
- Use **tabs**, not spaces
- One element per line
- Consistent nesting

**✅ CORRECT:**
```xml
<?xml version='1.0' encoding='utf-8'?>
<phrases>
	
	<phrase title="example_one" version_id="1000000" version_string="1.0.0">First phrase</phrase>
	<phrase title="example_two" version_id="1000000" version_string="1.0.0">Second phrase</phrase>
	
</phrases>
```

**❌ WRONG:**
```xml
<?xml version='1.0' encoding='utf-8'?>
<phrases><phrase title="example_one" version_id="1000000" version_string="1.0.0">First phrase</phrase><phrase title="example_two" version_id="1000000" version_string="1.0.0">Second phrase</phrase></phrases>
```

### Encoding
- Files MUST be UTF-8 **without BOM**
- Use Unix line endings (LF, not CRLF)

**Check encoding:**
```bash
file phrases.xml
# Should show: XML 1.0 document, Unicode text, UTF-8 text
```

---

## 5. Tools to NEVER Use

### ❌ Python ElementTree
```python
# ❌ DO NOT USE - Corrupts XenForo XML
import xml.etree.ElementTree as ET
tree = ET.parse('phrases.xml')
# This will:
# - Change XML declaration to double quotes
# - Remove indentation
# - Compress everything to one line
# - Break XenForo import
```

### ❌ Any Auto-Formatting XML Tool
- PHP's DOMDocument with formatOutput
- xmllint --format
- IDE auto-formatters
- Any library that "pretty prints" XML

**Why:** These tools reformat XML to their own standards, which don't match XenForo's requirements.

### ✅ Tools That Are Safe

**1. Manual string construction:**
```bash
cat >> phrases.xml << 'EOF'
	<phrase title="new_phrase" version_id="1000100">New text</phrase>
EOF
```

**2. sed for simple replacements:**
```bash
sed -i 's/version_id="1000000"/version_id="1000100"/g' phrases.xml
```

**3. The view tool (read-only):**
```bash
view /path/to/file.xml
```

**4. xmllint for validation ONLY:**
```bash
xmllint --noout phrases.xml  # Validates without changing file
```

---

## 6. Validation Commands

### Check All XML Files
```bash
cd upload/src/addons/YourVendor/YourAddon/_data

for file in *.xml; do
    echo "Checking $file..."
    xmllint --noout "$file" 2>&1 || echo "❌ FAILED: $file"
done
```

### Check for Unescaped Ampersands
```bash
# In templates.xml (most common issue)
grep -n '&[^a]' templates.xml | \
  grep -v '&amp;' | \
  grep -v '&lt;' | \
  grep -v '&gt;' | \
  grep -v '&quot;' | \
  grep -v '&apos;'

# Any output = unescaped ampersands found
```

### Check XML Declaration
```bash
head -1 phrases.xml
# Should show: <?xml version='1.0' encoding='utf-8'?>
# Single quotes, lowercase utf-8
```

### Check File Encoding
```bash
file -i *.xml
# Should show: charset=utf-8 for all files
```

### Verify No Phrase Concatenation
```bash
# Check entity files for dynamic phrase calls
grep -r "phrase.*\." Entity/
# Any matches should be reviewed - likely need switch statements
```

---

## 7. Common Error Messages & Solutions

### Error: "Invalid XML in file"

**Cause 1:** Wrong XML declaration format
```bash
# Check first line
head -1 phrases.xml
```
**Fix:** Change to `<?xml version='1.0' encoding='utf-8'?>`

**Cause 2:** Unescaped ampersands
```bash
# Find unescaped &
grep -n '&[^a]' templates.xml | grep -v '&amp;'
```
**Fix:** Replace `&` with `&amp;` (especially in LESS CSS)

**Cause 3:** Malformed XML structure
```bash
# Validate structure
xmllint --noout templates.xml
```
**Fix:** Check error line number, verify closing tags

---

### Error: "Phrase name must be literal"

**Cause:** Dynamic phrase concatenation in entity methods

**Example of problem code:**
```php
return \XF::phrase('prefix.' . $this->variable);
```

**Fix:** Replace with switch statement:
```php
switch ($this->variable)
{
    case 'value1':
        return \XF::phrase('prefix.value1');
    case 'value2':
        return \XF::phrase('prefix.value2');
    default:
        return $this->variable;
}
```

---

### Error: Template parse/compilation errors

**Cause 1:** LESS nested selectors not escaped
```less
&.active { }  ❌ Wrong in XML
```
**Fix:**
```less
&amp;.active { }  ✅ Correct
```

**Cause 2:** Missing closing tags in templates
**Fix:** Validate template HTML structure, ensure all tags close

---

## 8. Pre-Upload Checklist

Before uploading any addon version:

- [ ] Run `xmllint --noout` on all XML files
- [ ] Check XML declaration uses single quotes
- [ ] Search for unescaped `&` in templates.xml
- [ ] Verify no phrase concatenation in entity methods
- [ ] Check file encoding is UTF-8 without BOM
- [ ] Verify version_id and version_string match in:
  - [ ] addon.json
  - [ ] All phrase entries
  - [ ] All template entries
- [ ] Test install on clean XenForo instance

---

## 9. Recovery from Corrupted XML

If you've already corrupted an XML file:

1. **Restore from last working version:**
```bash
# Extract from last working .tar.gz
tar -xzf IC_AddonName_v1.X.X.tar.gz
cp upload/src/addons/Vendor/Addon/_data/phrases.xml /current/location/
```

2. **Manually add new content:**
```bash
# Use cat or echo, NOT Python/XML libraries
cat >> phrases.xml << 'EOF'
	<phrase title="new_phrase">New content</phrase>
EOF
```

3. **Fix closing tag if needed:**
```bash
# Ensure file ends with proper closing tag
tail -1 phrases.xml  # Should show </phrases>
```

---

## 10. Quick Reference Card

**Copy this to your development notes:**

```
XenForo XML Quick Rules:

Declaration: <?xml version='1.0' encoding='utf-8'?>  (single quotes!)
Ampersands:  & → &amp; (ALWAYS, especially in LESS)
Phrases:     Must be literal strings (use switch statements)
Tools:       NEVER Python ElementTree, ONLY manual/sed
Validation:  xmllint --noout file.xml
Encoding:    UTF-8 without BOM
Indentation: Tabs, one element per line

Common Errors:
- "Invalid XML" → Check XML declaration quotes
- "Invalid XML" → Check for unescaped & in LESS
- "Phrase must be literal" → Entity method using concatenation
```

---

## Appendix: Real-World Example

This example shows a complete phrases.xml file with correct formatting:

```xml
<?xml version='1.0' encoding='utf-8'?>
<phrases>
	
	<phrase title="addon_title" version_id="1000000" version_string="1.0.0" addon_id="Vendor/Addon">My Addon</phrase>
	<phrase title="addon_description" version_id="1000000" version_string="1.0.0" addon_id="Vendor/Addon">Addon description here</phrase>
	
	<!-- Navigation phrases -->
	<phrase title="nav.addon_main" version_id="1000000" version_string="1.0.0" addon_id="Vendor/Addon">Main Page</phrase>
	<phrase title="nav.addon_settings" version_id="1000000" version_string="1.0.0" addon_id="Vendor/Addon">Settings</phrase>
	
	<!-- Error messages -->
	<phrase title="addon_error.insufficient_credits" version_id="1000100" version_string="1.0.1" addon_id="Vendor/Addon">You do not have enough credits.</phrase>
	<phrase title="addon_error.not_found" version_id="1000100" version_string="1.0.1" addon_id="Vendor/Addon">Item not found.</phrase>

</phrases>
```

**Key points:**
- Single quotes in XML declaration
- Tabs for indentation
- Blank line after opening tag
- Comments for organization
- Consistent attributes order
- Blank line before closing tag
- Unix line endings (LF)

---

**Remember:** When in doubt, look at a working XML file from a successful addon, not at what an XML library generates.
