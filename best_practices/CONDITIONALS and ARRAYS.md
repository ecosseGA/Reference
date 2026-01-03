XenForo Template Conditionals — The Right Way
The core problem (why $array[1] fails)

XenForo templates are not PHP.

They use a restricted expression parser, not a full PHP interpreter. That parser:

❌ cannot evaluate array offsets like $array[1]

❌ cannot chain complex expressions

❌ cannot call functions

❌ cannot do inline math or indexing

So this will never work:

<xf:if is="$items[1]">


Even if $items is a valid array.

The golden rule

Templates can check variables, not manipulate them.

If you need to index, calculate, or derive something — do it before the template.

What does work in XenForo templates
✅ 1. Simple truthy checks
<xf:if is="$items">


✔ Works if $items is non-empty
❌ Doesn’t tell you which item exists

✅ 2. is not empty
<xf:if is="$items is not empty">


Best practice for arrays.

✅ 3. Count-based checks
<xf:if is="count($items) > 1">


✔ This does work
✔ Use this instead of $items[1]

Correct replacement for $array[1]:

<xf:if is="count($items) > 1">
    <!-- safe to assume index 1 exists -->
</xf:if>

✅ 4. Loop-based logic (preferred)

Instead of checking indexes, iterate safely:

<xf:foreach loop="$items" value="$item">
    {$item.title}
</xf:foreach>


If you need the index:

<xf:foreach loop="$items" value="$item" key="$i">
    <xf:if is="$i == 1">
        Second item
    </xf:if>
</xf:foreach>

✔ This is the XenForo-native way to “access” array positions

The correct way to handle $array[1]
❌ Wrong (template tries to think)
<xf:if is="$games[1]">

✅ Right (controller prepares data)

Controller / PHP:

$viewParams['hasSecondGame'] = isset($games[1]);
$viewParams['secondGame'] = $games[1] ?? null;

Template:

<xf:if is="$hasSecondGame">
    {$secondGame.title}
</xf:if>


This is the cleanest, safest approach.

Why XenForo enforces this

This limitation is intentional:

Prevents fragile templates
Improves performance
Keeps logic out of views
Avoids security issues
Ensures templates stay cacheable

It feels restrictive until you embrace the pattern — then it becomes predictable.

Common anti-patterns (don’t do these)

❌ Array indexing
$items[0]
$items[1]

❌ Function calls
isset($items[1])
array_key_exists(1, $items)

❌ Math
$i + 1

❌ Nested logic
<xf:if is="count($items) > 1 && $items[1].active">


All of the above belong in PHP.

Mental checklist for conditionals

Before writing a conditional, ask:

“Can this be answered with a boolean?”

If yes → pass a boolean
If no → compute it first

5 safe conditional patterns to memorise
<xf:if is="$items is not empty">
<xf:if is="count($items) > 1">
<xf:if is="$entity.is_active">
<xf:if is="$hasPermission">
<xf:if is="$showSection">

If your conditional doesn’t look like one of those, rethink it.

One-sentence summary (worth remembering)

XenForo templates don’t index arrays — controllers do.

XenForo Template Conditionals — Cheat Sheet

Rule of thumb:
XenForo templates can check values, not manipulate data.

✅ SAFE CONDITIONAL PATTERNS (use these)
1️⃣ Check if a variable exists / is truthy
<xf:if is="$item">

✔ Works for booleans, entities, non-empty values

2️⃣ Check if an array is not empty
<xf:if is="$items is not empty">


✔ Best practice for arrays
❌ Does not tell you how many items

3️⃣ Check array size (replacement for $array[1])
<xf:if is="count($items) > 1">


✔ Correct way to ensure index 1 exists
✔ Safe, supported

4️⃣ Loop with index (preferred instead of indexing)
<xf:foreach loop="$items" value="$item" key="$i">
    <xf:if is="$i == 1">
        Second item
    </xf:if>
</xf:foreach>

✔ XenForo-native
✔ Safe
✔ Readable

5️⃣ Boolean flags passed from PHP (best overall)

Controller / PHP

$viewParams['hasSecondItem'] = count($items) > 1;

Template

<xf:if is="$hasSecondItem">

✔ Clean
✔ Fast
✔ Zero template fragility

❌ NEVER WORKS (memorise this list)
$array[0]
$array[1]
isset($array[1])
array_key_exists(1, $array)
$i + 1
$items[1].title
count($items) && $items[1]

❌ XenForo templates are not PHP
❌ These will silently fail or break compilation

⚠️ CONDITION CHAINS — KEEP SIMPLE
❌ Wrong
<xf:if is="count($items) > 1 && $items[1].active">

✅ Right

PHP

$viewParams['showSecond'] = isset($items[1]) && $items[1]->active;

Template

<xf:if is="$showSecond">

🧠 One-line memory trick

If you need brackets [ ], stop and move it to PHP.

📘 Mini Guide: Writing Conditionals the XenForo Way
Why XenForo templates behave this way

XenForo uses a restricted expression parser, not PHP. This is intentional to:

keep templates cacheable
prevent fragile logic
improve performance
enforce MVC separation
avoid security issues
So the system forces you into good habits.

The correct mental model
❌ Wrong mental model

“Templates are PHP with angle brackets.”

✅ Correct mental model

“Templates only decide what to show, never how data is derived.”

The controller–template contract

Think of templates as consumers of prepared data.

Controllers should:

build arrays
index arrays
calculate values
determine conditions
produce booleans

Templates should:

check booleans
loop data
display values
apply layout
Refactoring a real-world bad conditional

❌ What people try
<xf:if is="$games[1]">
    {$games[1].title}
</xf:if>

✅ Correct refactor

Controller

$viewParams['featuredGame'] = $games[1] ?? null;


Template

<xf:if is="$featuredGame">
    {$featuredGame.title}
</xf:if>


This is:

safer
clearer
easier to debug
upgrade-proof

Approved conditional shapes (copy/paste safe)
<xf:if is="$items is not empty">
<xf:if is="count($items) > 1">
<xf:if is="$entity.is_visible">
<xf:if is="$hasPermission">
<xf:if is="$showSection">


If your conditional doesn’t look like one of these, reconsider it.

Common mistakes that cause “random” breakage
Mistake	Why it breaks
$array[1]	Unsupported
Complex logic	Parser limitation
Inline math	Unsupported
Function calls	Not PHP
Nested expressions	Unpredictable
Debugging tip (very useful)

If a conditional should work but doesn’t:

Replace it with:

{$dumpVar|dump}

See what the template actually receives

Fix it in PHP, not the template

Final takeaway (worth writing on the wall)

Templates don’t think. Controllers think. Templates decide what to show.
