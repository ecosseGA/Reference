# XenForo Addon Development - Quick Reference

**Print this and keep it next to your development machine**

---

## ✅ Pre-Upload Checklist

Before uploading ANY addon version, verify:

- [ ] **XML Declaration**
  ```bash
  head -1 _data/*.xml
  # Every file should show: <?xml version='1.0' encoding='utf-8'?>
  # Single quotes, lowercase utf-8
  ```

- [ ] **XML Validity**
  ```bash
  cd _data && for f in *.xml; do xmllint --noout "$f" || echo "FAIL: $f"; done
  # All files should pass without errors
  ```

- [ ] **Unescaped Ampersands**
  ```bash
  grep -n '&[^a]' _data/templates.xml | grep -v '&amp;' | grep -v '&lt;'
  # No output = good. Any output = fix needed
  ```

- [ ] **Version Numbers Match**
  ```bash
  grep version_id addon.json
  grep version_id _data/templates.xml | head -1
  grep version_id _data/phrases.xml | head -1
  # All should show same version number
  ```

- [ ] **File Encoding**
  ```bash
  file -i _data/*.xml
  # All should show: charset=utf-8
  ```

- [ ] **No Dynamic Phrases**
  ```bash
  grep -r "phrase.*\." Entity/ Repository/
  # Review any results - should use switch statements
  ```

---

## 🚨 Critical Rules

### XML Declaration
```xml
<?xml version='1.0' encoding='utf-8'?>
```
**NEVER:**
- `<?xml version="1.0" encoding="utf-8"?>` ❌ Double quotes
- `<?xml version='1.0' encoding='UTF-8'?>` ❌ Uppercase UTF
- Any variation from the exact format above

---

### Entity Escaping in XML

| Character | Must Become | Common In |
|-----------|-------------|-----------|
| `&` | `&amp;` | LESS: `&.class`, `&:hover` |
| `<` | `&lt;` | HTML tags (outside CDATA) |
| `>` | `&gt;` | HTML tags (outside CDATA) |

**Most common mistake:**
```less
/* ❌ WRONG - will break XML */
&.active { color: red; }

/* ✅ CORRECT - escaped for XML */
&amp;.active { color: red; }
```

---

### Phrase Names Must Be Literal

**❌ WRONG:**
```php
public function getTitle() {
    return \XF::phrase('prefix.' . $this->variable);
}
```

**✅ CORRECT:**
```php
public function getTitle() {
    switch ($this->variable) {
        case 'value1':
            return \XF::phrase('prefix.value1');
        case 'value2':
            return \XF::phrase('prefix.value2');
        default:
            return $this->variable;
    }
}
```

---

## 🛠️ Safe Tools Only

### ✅ ALLOWED
- `cat >> file.xml << 'EOF'` (manual construction)
- `sed -i 's/old/new/g' file.xml` (simple replacements)
- `view /path/to/file.xml` (read-only viewing)
- `xmllint --noout file.xml` (validation only)

### ❌ FORBIDDEN
- Python ElementTree
- PHP DOMDocument with formatOutput
- `xmllint --format` (changes formatting)
- Any "pretty print" or "auto-format" tool
- IDE auto-formatters on XML files

**Why forbidden:** They change quote styles, remove indentation, and break XenForo's format requirements.

---

## 🔍 Common Error Messages

### "Invalid XML in file"

**Check these in order:**

1. **XML declaration format**
   ```bash
   head -1 phrases.xml
   # Should be: <?xml version='1.0' encoding='utf-8'?>
   ```

2. **Unescaped ampersands**
   ```bash
   grep '&[^a]' templates.xml | grep -v '&amp;'
   # Fix any matches
   ```

3. **File encoding**
   ```bash
   file -i phrases.xml
   # Should show: charset=utf-8
   ```

4. **XML structure**
   ```bash
   xmllint --noout phrases.xml
   # Will show exact error line
   ```

---

### "Phrase name must be literal"

**Problem:** Entity method concatenates phrase name

**Find it:**
```bash
grep -r "phrase.*\." Entity/ Repository/
```

**Fix it:** Replace concatenation with switch statement (see example above)

---

### "ParseError: missing closing }..."

**Problem:** Unbalanced braces in LESS CSS

**Check it:**
```bash
grep -o '{' template.less | wc -l  # Count opening
grep -o '}' template.less | wc -l  # Count closing
# Numbers should match
```

**Fix it:** Add missing closing brace at end of section

---

## 📋 Two-Step Processes

### Adding Phrased Content

**Step 1:** Add phrase to phrases.xml
```xml
<phrase title="addon_new_phrase" version_id="1000100">The phrase text</phrase>
```

**Step 2:** Reference in template
```html
<div>{{ phrase('addon_new_phrase') }}</div>
```

**Common mistake:** Only doing step 2. XenForo looks for the phrase and can't find it.

---

### Adding LESS CSS

**Step 1:** Write CSS with escaped ampersands
```less
.myClass
{
    &amp;.active { }
    &amp;:hover { }
}
```

**Step 2:** Validate before uploading
```bash
xmllint --noout templates.xml
```

**Common mistake:** Forgetting to escape `&` characters.

---

## 🎯 Quick Validation Command

**Run this before EVERY upload:**

```bash
cd upload/src/addons/Vendor/Addon/_data && \
  for f in *.xml; do xmllint --noout "$f" || exit 1; done && \
  head -1 phrases.xml && \
  echo "✅ Ready to upload"
```

If this doesn't show "✅ Ready to upload", **don't upload**.

---

## 📊 Version Number Format

**Version String:** `1.2.3`
- Major.Minor.Patch
- Example: `1.9.0.13`

**Version ID:** Integer without dots
- `1.9.0.13` → `1090013`
- `2.0.0` → `2000000`
- `1.0.0` → `1000000`

**Format:** `XXYYZZZZ`
- XX = Major (01-99)
- YY = Minor (00-99)
- ZZZZ = Patch (0000-9999)

**Must match in:**
- addon.json
- All template entries (version_id attribute)
- All phrase entries (version_id attribute)

---

## 🔧 Emergency Recovery

**If you've corrupted an XML file:**

```bash
# 1. Restore from last working version
tar -xzf Addon_v1.X.X.tar.gz
cp upload/.../phrases.xml /current/location/

# 2. Manually add new content (don't use Python!)
cat >> phrases.xml << 'EOF'
	<phrase title="new">New content</phrase>
EOF

# 3. Validate
xmllint --noout phrases.xml
```

---

## 💡 Best Practices

1. **Test incrementally** - Install after each change, don't batch 5 features
2. **Validate before upload** - 2 minutes now saves 30 minutes debugging
3. **Keep backups** - Save every working .tar.gz version
4. **Check logs first** - AdminCP > Tools > Server error log shows exact issues
5. **Use version control** - Git commits provide rollback points

---

## 📞 When Stuck

**In this order:**

1. Check server error log (shows exact error with line number)
2. Validate XML files (`xmllint --noout *.xml`)
3. Check XML declaration format (single quotes?)
4. Search for unescaped ampersands in templates.xml
5. Look for dynamic phrase calls in entity methods

**90% of errors are one of these 5 issues.**

---

## 🎓 Remember

> "The best way to debug XenForo addon XML errors is to not create them in the first place."

**Two minutes of validation prevents hours of debugging.**

---

**Last Updated:** Based on lessons from Crypto Mining v1.9.0.7-13 development
