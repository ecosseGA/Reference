# Common XenForo Add-on Mistakes (XF 2.3+)

This document lists the most frequent mistakes developers make when building or fixing XenForo add-ons.

---

## 1. Wrong folder structure
XenForo requires:
src/addons/Vendor/AddOnId/

Anything else breaks autoloading.

---

## 2. Namespace does not match folder path
Namespaces must mirror folders exactly.

---

## 3. addon.json missing or incorrect
addon_id must be Vendor/AddOnId and version_id must be numeric.

---

## 4. _data XML file named incorrectly
XF imports by filename, not contents.

---

## 5. Wrong XML root node
Root nodes must match importer expectations.

---

## 6. Templates stored as raw HTML
Templates inside XML must be entity-escaped.

---

## 7. Missing <xf:css> include
CSS templates are not auto-loaded.

---

## 8. Duplicate HTML attributes
Only one class attribute is allowed.

---

## 9. Unbalanced xf:if / xf:foreach blocks
Always close XF tags properly.

---

## 10. Cron entries with run_rules = null
run_rules must always be an array.

---

## 11. Widget class exists but no widget definition
Widgets need widget_definitions.xml to appear in ACP.

---

## 12. Zipping the wrong folder level
ZIP must start at src/addons/.
