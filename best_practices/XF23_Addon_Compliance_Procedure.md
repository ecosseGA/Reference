# XenForo 2.3 Add-on Packaging (Manual / No-CLI) — Practical Procedure

This document is a **hands-on checklist** for taking an add-on from “has a `Setup.php`” to a **clean, XF 2.3-compliant** package with correct folders, `_data` XML, and properly encoded templates — **without relying on the legacy `_output` workflow**.

---

## 0) The goal (what “compliant” means in practice)

A manually packaged XF2.3 add-on should:

- Install/upgrade from a ZIP cleanly via **Admin CP → Add-ons → Install/upgrade from archive**
- Live in the correct path and namespace:
  - `src/addons/<Vendor>/<AddOnId>/`
  - PHP namespaces start with `namespace <Vendor>\<AddOnId>;`
- Have a correct `addon.json`
- Contain **importable** `_data/*.xml` files (valid XML, correct file names, correct root nodes)
- Store templates as XML with **entities escaped** (`&lt;` etc.) rather than raw `<xf:...>` markup
- Use the standard runtime folders (`Widget/`, `Entity/`, `Repository/`, `Service/`, `Pub/Controller/`, `Admin/Controller/`, etc.)

---

## 1) Correct folder structure (from Setup.php outward)

### Required minimum

```
src/
  addons/
    Vendor/
      AddOnId/
        addon.json
        Setup.php
        _data/
          phrases.xml (optional)
          templates.xml (optional)
          admin_navigation.xml (optional)
          routes.xml (optional)
          permissions.xml (optional)
          admin_permissions.xml (optional)
          cron_entries.xml (optional)
          widget_definitions.xml (optional)
```

### Common code folders (add as needed)

```
Admin/Controller/
Pub/Controller/
Entity/
Repository/
Service/
Finder/
Job/
Cron/
Listener/
Widget/
Template/
  Templater/
```

**Key rule:** Folder names and namespaces must match.  
Example class file:

`src/addons/Vendor/AddOnId/Pub/Controller/Foo.php`

```php
namespace Vendor\AddOnId\Pub\Controller;

class Foo extends \XF\Pub\Controller\AbstractController
{
}
```

---

## 2) Setup.php essentials

`Setup.php` must be at:

`src/addons/Vendor/AddOnId/Setup.php`

Minimum working skeleton:

```php
<?php

namespace Vendor\AddOnId;

use XF\AddOn\AbstractSetup;
use XF\AddOn\StepRunnerInstallTrait;
use XF\AddOn\StepRunnerUpgradeTrait;
use XF\AddOn\StepRunnerUninstallTrait;

class Setup extends AbstractSetup
{
    use StepRunnerInstallTrait;
    use StepRunnerUpgradeTrait;
    use StepRunnerUninstallTrait;

    // Add installStepX / upgradeStepX / uninstallStepX methods only if needed
}
```

### When you actually add steps
- Create DB tables
- Add columns/indexes
- Insert default options
- Rebuild caches after changing routes/permissions (rare; usually XF handles most data imports)

If you don’t need DB/schema changes, **keep Setup.php simple**.

---

## 3) addon.json must be correct

Located at:

`src/addons/Vendor/AddOnId/addon.json`

Example:

```json
{
  "title": "My Add-on",
  "description": "What it does.",
  "version_id": 1000031,
  "version_string": "1.0.0",
  "dev": "IdleChatter",
  "dev_url": "",
  "addon_id": "Vendor/AddOnId",
  "require": {
    "XF": [2030000, "XenForo 2.3.0+"]
  }
}
```

**Common mistakes**
- `addon_id` missing or wrong (should be `Vendor/AddOnId`)
- Require version too old/new
- `version_id` not an integer

---

## 4) Why there is no `_output` folder (and what replaces it)

### The old workflow
Historically, developers used `_output/` to store uncompiled templates, phrases, etc. and then ran CLI export/build steps to generate `_data/*.xml`.

### In manual packaging / repair work
You often **won’t have** `_output` at all, because:
- You are receiving an add-on from someone else
- It was built without dev-mode tooling
- It was zipped directly from the runtime structure

### What matters instead
For installable archives, XF cares about:
- runtime code files + templates **in `_data/*.xml`**
- correct paths and namespaces

So: **no `_output` is fine**. You just need valid `_data` XML.

---

## 5) `_data` XML: file naming rules that trip people up

XF imports specific data types from specific filenames. The importer expects the **right filename** and the **right root node**.

Here are common ones (not exhaustive):

| Purpose | File | Root node |
|---|---|---|
| Public templates | `_data/templates.xml` | `<templates>` |
| Admin templates | `_data/admin_templates.xml` (if used) | `<admin_templates>` |
| Phrases | `_data/phrases.xml` | `<phrases>` |
| Routes | `_data/routes.xml` | `<routes>` |
| Permissions | `_data/permissions.xml` | `<permissions>` |
| Admin permissions | `_data/admin_permissions.xml` | `<admin_permissions>` |
| Cron entries | `_data/cron_entries.xml` | `<cron_entries>` |
| Widget definitions | `_data/widget_definitions.xml` | `<widget_definitions>` |
| Admin nav | `_data/admin_navigation.xml` | `<admin_navigation>` |

**Common failure mode:** the file is named slightly differently (e.g. `cron.xml`) or has the wrong root node, and install fails during add-on data import.

---

## 6) Templates: why you see `&lt;` and `&gt;` in templates.xml

When templates are stored inside XML, the XML must remain valid. Raw `<xf:...>` markup would be treated as XML tags and break parsing.

So XF stores template HTML as **escaped entities**:

- `<` becomes `&lt;`
- `>` becomes `&gt;`
- `&` becomes `&amp;`

That’s correct and expected.

### What “proper” templates.xml looks like
A typical entry:

```xml
<templates>
  <template title="my_template" type="public">
    <description></description>
    <template><![CDATA[
&lt;xf:title&gt;Hello&lt;/xf:title&gt;
&lt;div class=&quot;block&quot;&gt;...&lt;/div&gt;
    ]]></template>
  </template>
</templates>
```

### Key points
- Template content is usually inside `<![CDATA[ ... ]]>`
- Inside that, the XenForo template markup is **entity-escaped**
- Do **not** “unescape” it when packaging. If you do, the XML can break.

---

## 7) Correcting broken templates (common issues)

### A) Unbalanced HTML tags
XF template compilation can fail if:
- `</div>` missing
- `<xf:if>` not closed
- `<xf:foreach>` not closed

**Fix method**
- Validate nesting manually
- Use consistent indentation
- Keep each `xf:` block visually paired

### B) Duplicate `class` attributes, invalid attributes
Example mistake:

```html
<select class="input" class="other">
```

Only one `class` attribute is allowed. Merge them:

```html
<select class="input other">
```

### C) CSS templates not loaded
If `.less` exists but styling does nothing, ensure the page template includes:

```html
<xf:css src="your_addon.less" />
```

And make sure `your_addon.less` is created as a **CSS template** in XF terms.

---

## 8) Widgets folder: what it is and how it relates to widget_definitions.xml

### Code folder
Widget renderer classes live in:

`src/addons/Vendor/AddOnId/Widget/`

Example:

`Widget/LatestDeals.php`

```php
namespace Vendor\AddOnId\Widget;

use XF\Widget\AbstractWidget;

class LatestDeals extends AbstractWidget
{
    public function render()
    {
        return $this->renderer('public:vendor_widget_latest_deals', []);
    }
}
```

### Data definition
Widget “definitions” (what appears in ACP widget manager) are imported from:

`_data/widget_definitions.xml`

This file tells XF:
- widget key
- title
- renderer class
- options schema (if any)

**You can have Widget classes without widget_definitions.xml**, but then you won’t be able to add them through the ACP widget manager as a normal widget type.

---

## 9) Packaging the ZIP (what the archive should contain)

Your ZIP should contain the add-on folder **starting at `src/addons/...`**.

Correct ZIP internal layout:

```
src/
  addons/
    Vendor/
      AddOnId/
        addon.json
        Setup.php
        ...
```

**Incorrect (common):** zipping the add-on folder alone without `src/addons/` prefix.  
XF expects the internal paths to match.

---

## 10) Install test checklist (fast)

1. Upload ZIP: **Admin CP → Add-ons → Install/upgrade from archive**
2. If it errors during install batch:
   - Look at the stack trace:
     - `CronEntry::verifyRunRules()` usually means `cron_entries.xml` missing/invalid run_rules
     - Template errors usually mean malformed templates.xml content
3. Confirm routes/controllers:
   - Load the public page
   - Check dev tools for 404/500
4. Check CSS:
   - Confirm `<xf:css src="...">` is present
   - Hard refresh / cache-bust

---

## 11) The “top 5” rules that prevent 95% of compliance problems

- **Path:** Always `src/addons/Vendor/AddOnId/…`
- **Namespace:** Always `Vendor\AddOnId\…`
- **addon.json:** has correct `addon_id` and requires XF version
- **_data filenames + root nodes:** must be correct
- **templates.xml uses escaped entities:** never raw `<xf:...>` inside XML

---

## Appendix: quick troubleshooting patterns

### “Argument must be array, verbunden, null given” during install
Usually a broken `_data/*.xml` that imported a `null` value into an array-typed entity field.
Most common: `cron_entries.xml` has missing/empty `<run_rules>`.

Fix: ensure run_rules imports as an array (or empty).

### Styling doesn’t apply
- CSS template not included via `<xf:css src="...">`
- CSS template is wrong type (not a CSS template)
- Selector scope mismatch (missing wrapper class)
