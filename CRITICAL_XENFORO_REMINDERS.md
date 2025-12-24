# ⚠️ CRITICAL: XenForo Addon Development Rules

**PASTE THIS INTO NEW CHAT IMMEDIATELY**

---

## 🚨 STOP! READ THIS FIRST

You are working on a **XenForo 2.3 ADDON**, not a standalone web app!

---

## ✅ CORRECT XenForo Addon Structure:

```
upload/src/addons/IC/NFLHub/
├── addon.json
├── Setup.php
├── Entity/
│   └── *.php files
├── Repository/
│   └── *.php files
├── Pub/Controller/
│   └── *.php files
├── Cron/
│   └── *.php files
└── _data/
    ├── templates.xml ← Templates go HERE (not .html files!)
    ├── phrases.xml
    ├── routes.xml
    ├── cron.xml
    ├── permissions.xml
    └── navigation.xml
```

---

## ❌ WRONG (Don't Do This):

- ❌ Creating standalone .html files
- ❌ Creating individual XML files for each template
- ❌ Providing PHP files without packaging them
- ❌ Not creating ZIP file for installation

---

## ✅ RIGHT (Always Do This):

1. **Create/Edit XML Files Using Python Scripts**
   ```python
   import xml.etree.ElementTree as ET
   tree = ET.parse('templates.xml')
   # Add/edit templates
   tree.write('templates.xml', encoding='utf-8', xml_declaration=True)
   ```

2. **Templates Go in templates.xml**
   ```xml
   <template title="ic_nfl_rankings" type="public">
     <![CDATA[
       <!-- HTML content here -->
     ]]>
   </template>
   ```

3. **Always Create ZIP File**
   ```bash
   cd /home/claude/addon-name
   zip -r /mnt/user-data/outputs/AddonName_v1.0.0.zip upload/
   ```

4. **Use present_files Tool**
   ```
   Present the ZIP file so user can download and install!
   ```

---

## 📋 STANDARD WORKFLOW:

### For New Features:

1. ✅ Create/edit PHP files in proper directories
2. ✅ Edit XML files using Python (templates, phrases, routes, etc.)
3. ✅ Update addon.json version
4. ✅ Create ZIP package
5. ✅ Present ZIP to user
6. ✅ Provide upgrade instructions

### Example from Previous Work:

```python
# Edit templates.xml
cd /home/claude/nfl-hub/upload/src/addons/IC/NFLHub/_data
python3 << 'PYTHON'
import xml.etree.ElementTree as ET
tree = ET.parse('templates.xml')
root = tree.getroot()

# Add new template
new_template = ET.SubElement(root, 'template')
new_template.set('title', 'ic_nfl_new_feature')
new_template.set('type', 'public')
new_template.text = '<div>New feature content</div>'

tree.write('templates.xml', encoding='utf-8', xml_declaration=True)
PYTHON

# Package addon
cd /home/claude/nfl-hub
zip -r /mnt/user-data/outputs/IC_NFLHub_v1.X.X.zip upload/

# Present to user
present_files tool with the ZIP path
```

---

## 🎯 WHAT USER EXPECTS:

1. **Working addon ZIP file** that they can install in XenForo
2. **All files in correct structure** (upload/src/addons/...)
3. **XML files properly formatted** (not individual .html files)
4. **Upgrade instructions** if updating existing addon
5. **SQL queries** if database changes needed

---

## 📚 REFERENCE THE KNOWLEDGE TRANSFER DOC:

The user uploaded `NFL_HUB_COMPLETE_KNOWLEDGE_TRANSFER.md` which contains:
- ✅ Correct file structure
- ✅ Development patterns
- ✅ What works vs what doesn't
- ✅ Example Python scripts
- ✅ Version history with working solutions

**READ IT CAREFULLY!**

---

## 🔧 IF YOU'VE ALREADY MADE MISTAKES:

Say this to the user:
"I apologize - I was creating files incorrectly. Let me restart with proper XenForo addon structure using XML files and Python scripts as shown in your knowledge transfer document."

Then follow the correct workflow above.

---

## ⚡ QUICK CHECKLIST:

Before responding to user:
- [ ] Am I editing XML files (not creating .html)?
- [ ] Am I using Python to edit XML?
- [ ] Am I creating proper addon structure?
- [ ] Am I packaging everything into a ZIP?
- [ ] Am I using present_files to share the ZIP?

If any answer is "no", stop and fix it!

---

## 🎯 EXAMPLE CORRECT RESPONSE:

"I'll create the power rankings redesign as a proper XenForo addon update:

[Uses Python to edit templates.xml]
[Creates PHP files in correct directories]
[Updates addon.json version]
[Creates ZIP package]
[Presents ZIP file to user]

Here's IC_NFLHub_v1.5.0.zip with the redesigned power rankings table!"

---

## ❌ EXAMPLE WRONG RESPONSE:

"Here's the new rankings template:
[Creates ic_rankings.html file]
[Creates individual XML file]
[Doesn't package anything]
[Doesn't present ZIP]"

**This is WRONG!** Follow the correct workflow above.

---

**MEMORIZE THIS AND FOLLOW IT FOR EVERY REQUEST!**

The user has been working on this addon for hours/days. They expect proper XenForo addon structure, not loose files.

---

## 📖 KEY DOCUMENTS TO REFERENCE:

1. **NFL_HUB_COMPLETE_KNOWLEDGE_TRANSFER.md** - Full project context
2. **Stock Market addon** - Styling reference
3. **This document** - Development rules

**Read them. Follow them. Package properly. Present ZIPs.**

---

**Now, start over with the correct approach!** 🎯
