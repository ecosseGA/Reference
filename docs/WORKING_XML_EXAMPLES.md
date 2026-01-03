# Working XML Examples from Crypto Mining Addon

These are real, working XML files extracted from the Crypto Mining v1.9.0.13 addon. Use these as templates for your own addons.

---

## Example 1: phrases.xml (Correct Format)

```xml
<?xml version='1.0' encoding='utf-8'?>
<phrases>
	
	<phrase title="navigation.icCryptoMining" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">Crypto Mining</phrase>
	<phrase title="navigation.icCM_dashboard" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">Dashboard</phrase>
	<phrase title="navigation.icCM_shop" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">Rig Shop</phrase>
	
	<phrase title="permission_interface_group.icCMPerms" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">Crypto Mining permissions</phrase>
	
	<phrase title="permission.icCryptoMining_view" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">View crypto mining</phrase>
	<phrase title="permission.icCryptoMining_mine" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">Purchase rigs and mine crypto</phrase>
	
	<phrase title="ic_crypto_insufficient_credits" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">You do not have enough credits to purchase this mining rig.</phrase>
	<phrase title="ic_crypto_level_required" version_id="1000004" version_string="1.0.4" addon_id="IC/CryptoMining">You need to be level {level} or higher to purchase this rig.</phrase>
	
	<!-- Achievement Title Phrases -->
	<phrase title="ic_crypto_achievement_title.first_dig" version_id="1090013" version_string="1.9.0.13" addon_id="IC/CryptoMining">First Dig</phrase>
	<phrase title="ic_crypto_achievement_title.prospector" version_id="1090013" version_string="1.9.0.13" addon_id="IC/CryptoMining">Prospector</phrase>
	
	<!-- Achievement Description Phrases -->
	<phrase title="ic_crypto_achievement_desc.first_dig" version_id="1090013" version_string="1.9.0.13" addon_id="IC/CryptoMining">Purchase your first mining rig to begin your crypto journey.</phrase>
	
	<!-- Difficulty Tier Phrases -->
	<phrase title="ic_crypto_difficulty.easy" version_id="1090013" version_string="1.9.0.13" addon_id="IC/CryptoMining">Easy</phrase>
	<phrase title="ic_crypto_difficulty.medium" version_id="1090013" version_string="1.9.0.13" addon_id="IC/CryptoMining">Medium</phrase>

</phrases>
```

**Key features:**
- ✅ Single quotes in XML declaration
- ✅ Lowercase `utf-8`
- ✅ Tab indentation
- ✅ Blank line after opening tag
- ✅ Comments for organization
- ✅ Consistent attribute order
- ✅ Blank line before closing tag

---

## Example 2: routes.xml

```xml
<?xml version='1.0' encoding='utf-8'?>
<routes>
	<route route_prefix="crypto-mining" sub_name="dashboard" controller="IC\CryptoMining:Dashboard" context="public" />
	<route route_prefix="crypto-mining" sub_name="shop" controller="IC\CryptoMining:Shop" context="public" />
	<route route_prefix="crypto-mining" sub_name="market" controller="IC\CryptoMining:Market" context="public" />
	<route route_prefix="crypto-mining" sub_name="leaderboard" controller="IC\CryptoMining:Leaderboard" context="public" />
	<route route_prefix="crypto-mining" sub_name="blocks" controller="IC\CryptoMining:Blocks" context="public" />
	<route route_prefix="crypto-mining" sub_name="achievements" controller="IC\CryptoMining:Achievements" context="public" />
	<route route_prefix="crypto-mining" sub_name="transactions" controller="IC\CryptoMining:Transactions" context="public" />
</routes>
```

**Key features:**
- ✅ Uses `sub_name` for nested routes (not slashes in route_prefix)
- ✅ Each route on one line
- ✅ Consistent formatting

---

## Example 3: navigation.xml

```xml
<?xml version='1.0' encoding='utf-8'?>
<navigation>
	<navigation navigation_id="icCryptoMining" parent_navigation_id="" display_order="50" is_enabled="1">
		<child_navigation navigation_id="icCM_dashboard" display_order="10" parent_navigation_id="icCryptoMining" />
		<child_navigation navigation_id="icCM_shop" display_order="20" parent_navigation_id="icCryptoMining" />
		<child_navigation navigation_id="icCryptoMarket" display_order="30" parent_navigation_id="icCryptoMining" />
		<child_navigation navigation_id="icCryptoBlocks" display_order="40" parent_navigation_id="icCryptoMining" />
		<child_navigation navigation_id="icCryptoAchievements" display_order="45" parent_navigation_id="icCryptoMining" />
		<child_navigation navigation_id="icCryptoLeaderboard" display_order="50" parent_navigation_id="icCryptoMining" />
		<child_navigation navigation_id="icCryptoTransactions" display_order="60" parent_navigation_id="icCryptoMining" />
	</navigation>
</navigation>
```

**Key features:**
- ✅ Parent navigation contains child elements
- ✅ display_order for sorting
- ✅ Proper nesting with indentation

---

## Example 4: permissions.xml

```xml
<?xml version='1.0' encoding='utf-8'?>
<permissions>
	<permission_group permission_group_id="icCMPerms" display_order="10000" />
	
	<permission permission_group_id="icCMPerms" permission_id="view" permission_type="flag" interface_group_id="icCMPerms" display_order="10" />
	<permission permission_group_id="icCMPerms" permission_id="mine" permission_type="flag" interface_group_id="icCMPerms" display_order="20" />
</permissions>
```

**Key features:**
- ✅ Permission group defined first
- ✅ Individual permissions reference the group
- ✅ Blank line separating group from permissions

---

## Example 5: cron.xml

```xml
<?xml version='1.0' encoding='utf-8'?>
<cron>
	<entry entry_id="icCryptoMiningUpdate" 
	       cron_class="IC\CryptoMining\Cron\UpdateMining" 
	       cron_method="runUpdate" 
	       run_rules='{"hours":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23],"minutes":[0]}' 
	       active="1">
		<description>Update cryptocurrency mining rewards, power costs, and durability degradation for all active rigs.</description>
	</entry>
	
	<entry entry_id="icCryptoLeaderboardUpdate" 
	       cron_class="IC\CryptoMining\Cron\UpdateLeaderboards" 
	       cron_method="runUpdate" 
	       run_rules='{"hours":[0,6,12,18],"minutes":[0]}' 
	       active="1">
		<description>Update crypto mining leaderboards.</description>
	</entry>
</cron>
```

**Key features:**
- ✅ run_rules is a JSON string (note single quotes around it)
- ✅ Multi-line formatting for readability
- ✅ Description in child element

---

## Example 6: Template with LESS CSS (Escaped Ampersands)

This shows how to properly include LESS CSS in templates.xml:

```xml
<template type="public" title="ic_crypto.less" version_id="1090013" version_string="1.9.0.13"><![CDATA[
// ====== TRANSACTION BADGES ======
.cryptoTransactions-badge
{
	display: inline-block;
	padding: 4px 8px;
	border-radius: @xf-borderRadiusSmall;
	font-size: 11px;
	font-weight: 600;
	text-transform: uppercase;
	border: 1px solid transparent;
	
	&amp;.cryptoTransactions-badge--mining
	{
		background: rgba(52, 152, 219, 0.15);
		border-color: rgba(52, 152, 219, 0.3);
		color: #3498db;
	}
	
	&amp;.cryptoTransactions-badge--achievement
	{
		background: rgba(247, 147, 26, 0.2);
		border-color: rgba(247, 147, 26, 0.4);
		color: @crypto-primary;
	}
}
]]></template>
```

**Key features:**
- ✅ Wrapped in `<![CDATA[...]]>`
- ✅ All `&` escaped as `&amp;` (nested selectors)
- ✅ XenForo LESS variables used (`@xf-borderRadiusSmall`, `@crypto-primary`)
- ✅ Proper nesting structure

---

## Example 7: HTML Template with XenForo Syntax

```xml
<template type="public" title="ic_crypto_dashboard" version_id="1090013" version_string="1.9.0.13"><![CDATA[
&lt;xf:title&gt;Crypto Mining Dashboard&lt;/xf:title&gt;
&lt;xf:css src="ic_crypto.less" /&gt;

&lt;div class="block"&gt;
    &lt;div class="block-container"&gt;
        &lt;div class="block-header"&gt;
            &lt;h2 class="block-header-text"&gt;My Mining Rigs&lt;/h2&gt;
        &lt;/div&gt;
        
        &lt;div class="block-body"&gt;
            &lt;xf:if is="$rigs.count()"&gt;
                &lt;xf:foreach loop="$rigs" value="$rig"&gt;
                    &lt;div class="cryptoRig"&gt;
                        &lt;h4&gt;{$rig.RigType.rig_name}&lt;/h4&gt;
                        &lt;div&gt;Durability: {$rig.current_durability}%&lt;/div&gt;
                    &lt;/div&gt;
                &lt;/xf:foreach&gt;
            &lt;xf:else /&gt;
                &lt;div class="blockMessage"&gt;No rigs yet. Visit the shop!&lt;/div&gt;
            &lt;/xf:if&gt;
        &lt;/div&gt;
    &lt;/div&gt;
&lt;/div&gt;
]]></template>
```

**Key features:**
- ✅ HTML tags escaped (`&lt;` and `&gt;`)
- ✅ XenForo template syntax (`<xf:if>`, `<xf:foreach>`)
- ✅ Proper indentation for readability
- ✅ Variables use `{$variable}` syntax

---

## Example 8: Entity Method with Literal Phrases

This shows the correct way to return phrased content from entity methods:

```php
<?php

namespace IC\CryptoMining\Entity;

use XF\Mvc\Entity\Entity;

class Achievement extends Entity
{
	/**
	 * Get achievement title phrase
	 * Template calls: {$achievement.title}
	 */
	public function getTitle()
	{
		switch ($this->achievement_key)
		{
			case 'first_dig':
				return \XF::phrase('ic_crypto_achievement_title.first_dig');
			case 'prospector':
				return \XF::phrase('ic_crypto_achievement_title.prospector');
			case 'gold_rush':
				return \XF::phrase('ic_crypto_achievement_title.gold_rush');
			// ... more cases ...
			default:
				return $this->achievement_key;
		}
	}
	
	/**
	 * Get phrased difficulty tier text
	 * Template calls: {$achievement.getDifficultyText()}
	 */
	public function getDifficultyText()
	{
		switch ($this->difficulty_tier)
		{
			case 'easy':
				return \XF::phrase('ic_crypto_difficulty.easy')->render();
			case 'medium':
				return \XF::phrase('ic_crypto_difficulty.medium')->render();
			case 'hard':
				return \XF::phrase('ic_crypto_difficulty.hard')->render();
			default:
				return $this->difficulty_tier;
		}
	}
}
```

**Key features:**
- ✅ No string concatenation in phrase calls
- ✅ Each case explicitly calls phrase with literal string
- ✅ Default case returns raw value as fallback
- ✅ Comments show how template calls the method

---

## Example 9: addon.json

```json
{
  "legacy_addon_id": "",
  "title": "Crypto Mining Simulation",
  "description": "Mine Bitcoin, build your empire, dominate the leaderboards!",
  "version_id": 1090013,
  "version_string": "1.9.0.13",
  "dev": "IdleChatter",
  "dev_url": "",
  "faq_url": "",
  "support_url": "",
  "extra_urls": [],
  "require": {
    "XF": [2030000, "XenForo 2.3.0+"],
    "php": ["8.0.0", "PHP 8.0+"]
  },
  "icon": ""
}
```

**Key features:**
- ✅ version_id matches phrases.xml and templates.xml
- ✅ version_string is human-readable
- ✅ Requires XenForo 2.3.0+
- ✅ Requires PHP 8.0+

---

## Example 10: Complete File Structure

```
upload/
  src/
    addons/
      IC/
        CryptoMining/
          addon.json
          Setup.php
          Entity/
            Achievement.php
            UserRig.php
            Wallet.php
          Repository/
            Achievement.php
            UserRig.php
          Pub/
            Controller/
              Achievements.php
              Dashboard.php
          Cron/
            UpdateMining.php
          _data/
            routes.xml
            navigation.xml
            permissions.xml
            phrases.xml
            templates.xml
            cron.xml
```

---

## Common Patterns Summary

### XML Declaration (Every File)
```xml
<?xml version='1.0' encoding='utf-8'?>
```

### Phrase Entry
```xml
<phrase title="unique_key" version_id="1000000" version_string="1.0.0" addon_id="Vendor/Addon">Text content</phrase>
```

### Template Entry (HTML)
```xml
<template type="public" title="template_name" version_id="1000000" version_string="1.0.0"><![CDATA[
&lt;div&gt;HTML content with escaped tags&lt;/div&gt;
]]></template>
```

### Template Entry (LESS)
```xml
<template type="public" title="styles.less" version_id="1000000" version_string="1.0.0"><![CDATA[
.myClass
{
	&amp;:hover { }  // Escaped ampersand
}
]]></template>
```

### Route Entry
```xml
<route route_prefix="my-addon" sub_name="page" controller="Vendor\Addon:Controller" context="public" />
```

### Entity Phrase Method
```php
public function getText()
{
	switch ($this->key) {
		case 'value': return \XF::phrase('exact.phrase.name');
		default: return $this->key;
	}
}
```

---

These examples are all from the working Crypto Mining v1.9.0.13 addon and have been tested to install successfully.
