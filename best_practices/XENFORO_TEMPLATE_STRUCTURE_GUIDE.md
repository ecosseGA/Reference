# ✅ XenForo 2.3 Template Structure - Proper Guide

## What I Learned from XenAddons

### **Current WRONG Approach in Gamesroom:**

**❌ Templates have inline styles:**
```xml
<template type="public" title="gamesroom_play">
&lt;div style="color: red; padding: 10px;"&gt;
    &lt;span style="font-size: 14px;"&gt;Text&lt;/span&gt;
&lt;/div&gt;
</template>
```

**Problems:**
1. Using `&lt;` and `&gt;` entities (wrong!)
2. Inline `style="..."` attributes everywhere
3. No .less template for CSS
4. Hard to maintain/customize

---

### **CORRECT Approach (XenAddons Style):**

#### **Step 1: HTML Template with Clean Classes**

```xml
<template type="public" title="gamesroom_play" version_id="3005000" version_string="3.5.0"><![CDATA[
<xf:title>{$game.title}</xf:title>
<xf:css src="gamesroom.less" />

<div class="gamesroom-container">
    <div class="gamesroom-header">
        <h2 class="gamesroom-title">{$game.title}</h2>
    </div>
    
    <div class="gamesroom-iframe">
        <iframe src="{$game.embed_url}" 
                width="{$game.width}" 
                height="{$game.height}"></iframe>
    </div>
</div>
]]></template>
```

**Key Points:**
- ✅ Wrapped in `<![CDATA[...]]>`
- ✅ Clean class names (`gamesroom-container`, `gamesroom-header`)
- ✅ NO inline `style` attributes
- ✅ References CSS with `<xf:css src="gamesroom.less" />`
- ✅ Uses real `<` and `>` characters (not entities)

---

#### **Step 2: Separate .less Template for CSS**

```xml
<template type="public" title="gamesroom.less" version_id="3005000" version_string="3.5.0"><![CDATA[
// ########################## GAMESROOM CSS ##########################

.gamesroom-container
{
    margin: @xf-paddingLarge;
    
    .gamesroom-header
    {
        padding: @xf-paddingMedium;
        background: @xf-contentAltBg;
        border-radius: @xf-borderRadiusSmall;
        
        .gamesroom-title
        {
            font-size: @xf-fontSizeLarge;
            font-weight: @xf-fontWeightHeavy;
            color: @xf-textColor;
            margin: 0;
        }
    }
    
    .gamesroom-iframe
    {
        margin-top: @xf-paddingLarge;
        
        iframe
        {
            border: 1px solid @xf-borderColor;
            border-radius: @xf-borderRadiusSmall;
            display: block;
            margin: 0 auto;
        }
    }
}
]]></template>
```

**Key Points:**
- ✅ Also wrapped in `<![CDATA[...]]>`
- ✅ Uses LESS nesting syntax
- ✅ Uses XenForo variables:
  - `@xf-paddingLarge`, `@xf-paddingMedium`
  - `@xf-contentAltBg`
  - `@xf-borderRadiusSmall`
  - `@xf-textColor`, `@xf-borderColor`
  - `@xf-fontSizeLarge`, `@xf-fontWeightHeavy`
- ✅ Keeps styles separate from markup
- ✅ Easy to customize via XF style properties

---

## XenForo Style Variables Available

**Spacing:**
- `@xf-paddingSmall` (usually 5px)
- `@xf-paddingMedium` (usually 10px)
- `@xf-paddingLarge` (usually 20px)

**Colors:**
- `@xf-textColor` - Main text color
- `@xf-textColorDimmed` - Secondary text
- `@xf-textColorMuted` - Tertiary text
- `@xf-contentBg` - Content background
- `@xf-contentAltBg` - Alternate background
- `@xf-borderColor` - Border color
- `@xf-linkColor` - Link color
- `@xf-errorColor` - Error/danger color

**Typography:**
- `@xf-fontSizeSmall`
- `@xf-fontSizeNormal`
- `@xf-fontSizeLarge`
- `@xf-fontWeightNormal`
- `@xf-fontWeightHeavy`

**Borders:**
- `@xf-borderRadiusSmall`
- `@xf-borderRadiusMedium`
- `@xf-borderRadiusLarge`

---

## Complete Example: Game Card

### **HTML Template:**

```xml
<template type="public" title="gamesroom_game_card" version_id="3005000" version_string="3.5.0"><![CDATA[
<div class="gamesroom-card">
    <xf:if is="$game.thumbnail_url">
        <div class="gamesroom-card-thumb">
            <img src="{$game.thumbnail_url}" alt="{$game.title}" />
        </div>
    </xf:if>
    
    <div class="gamesroom-card-body">
        <h3 class="gamesroom-card-title">
            <a href="{{ link('gamesroom/play', $game) }}">{$game.title}</a>
        </h3>
        
        <xf:if is="$game.description">
            <div class="gamesroom-card-desc">{$game.description}</div>
        </xf:if>
        
        <div class="gamesroom-card-meta">
            <span class="gamesroom-card-plays">
                <i class="fa fa-play"></i> {$game.play_count} plays
            </span>
        </div>
    </div>
</div>
]]></template>
```

### **.less Template:**

```xml
<template type="public" title="gamesroom_game_card.less" version_id="3005000" version_string="3.5.0"><![CDATA[
.gamesroom-card
{
    background: @xf-contentBg;
    border: 1px solid @xf-borderColor;
    border-radius: @xf-borderRadiusMedium;
    overflow: hidden;
    transition: box-shadow 0.2s;
    
    &:hover
    {
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    
    .gamesroom-card-thumb
    {
        aspect-ratio: 16 / 9;
        overflow: hidden;
        
        img
        {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
    }
    
    .gamesroom-card-body
    {
        padding: @xf-paddingMedium;
        
        .gamesroom-card-title
        {
            font-size: @xf-fontSizeLarge;
            font-weight: @xf-fontWeightHeavy;
            margin: 0 0 @xf-paddingSmall;
            
            a
            {
                color: @xf-textColor;
                text-decoration: none;
                
                &:hover
                {
                    color: @xf-linkColor;
                }
            }
        }
        
        .gamesroom-card-desc
        {
            font-size: @xf-fontSizeSmall;
            color: @xf-textColorDimmed;
            margin-bottom: @xf-paddingSmall;
        }
        
        .gamesroom-card-meta
        {
            font-size: @xf-fontSizeSmaller;
            color: @xf-textColorMuted;
            
            .gamesroom-card-plays
            {
                i
                {
                    margin-right: @xf-paddingSmall / 2;
                }
            }
        }
    }
}
]]></template>
```

---

## Benefits of This Approach

1. **✅ Themeable** - Users can customize via style properties
2. **✅ Maintainable** - CSS in one place, HTML in another
3. **✅ Consistent** - Uses XF's design system automatically
4. **✅ Responsive** - Can add breakpoints in .less
5. **✅ Clean** - No inline styles cluttering markup
6. **✅ Professional** - Matches XenAddons quality

---

## What Needs to Change in Gamesroom

### **Current Issues:**

1. ❌ All templates use `&lt;` and `&gt;` entities
2. ❌ Inline `style="color: red; padding: 10px;"` everywhere
3. ❌ No .less templates at all
4. ❌ Hard-coded colors/spacing values

### **Fix Required:**

1. ✅ Convert all templates to CDATA format
2. ✅ Remove ALL inline styles
3. ✅ Add semantic class names
4. ✅ Create corresponding .less templates
5. ✅ Use XF style variables

---

## Next Steps

Would you like me to:

**A.** Rebuild all Gamesroom templates properly with:
   - Clean CDATA-wrapped HTML templates
   - Separate .less templates for all CSS
   - Proper class naming (gamesroom-*)
   - XF style variables throughout

**B.** Start with just 2-3 templates as examples to verify I understand correctly before doing all of them?

I'm ready to do this properly now that I understand the structure!
