# Optimization Plan — XjTTY-KitchenSink

> Analyzed: 2026-03-13 | Status: partially applied — see Applied Fixes section

Optimizations are ranked by actual runtime impact. Items on hot paths (30fps render loop or per-keystroke) are highest priority.

---

## 🔴 High Priority — Hot Paths

### OPT-1: Cache padding strings in `RenderHelp()`

**File:** `KSApp.xojo_code` — `RenderHelp()`
**Problem:** Two loops run on every frame (~30fps) while the help overlay is visible:
```xojo
For k As Integer = 1 To inner   // builds "---..." 38 times
  hbar = hbar + "-"
Next k

While row.Length < inner        // runs per row × 10 rows
  row = row + " "
Wend
```
This allocates many short-lived strings every 33ms.

**Fix:** Build `hbar` (38 dashes) and a full-width blank string (38 spaces) **once** — either as `Private` properties populated in `BuildWidgetTree()`, or as module-level constants. In `RenderHelp()`, use them directly with no loop.

```xojo
// In BuildWidgetTree() or as Private properties:
mHelpHbar = String(38, Asc("-"))   // if supported, else build once
mHelpBlank = String(38, Asc(" "))

// In RenderHelp() padding loop, replace While...Wend with:
Var pad As String = mHelpBlank.Left(inner - bases(i).Length)
Var row As String = bases(i) + pad
```

**Complexity change:** O(inner × rows) per frame → O(1) per frame
**Effort:** Low

---

### OPT-2: Cache lowercase fields for search in `KSComponentRegistry`

**File:** `KSComponentRegistry.xojo_code` — `Search()`
**Problem:** Every keystroke in search mode triggers 124 `.Lowercase` conversions (4 fields × 31 entries) plus the query string itself:
```xojo
If InStr(e.Name.Lowercase, q) > 0 Or
   InStr(e.ShortDesc.Lowercase, q) > 0 Or
   InStr(e.Keywords.Lowercase, q) > 0 Or
   InStr(e.Category.Lowercase, q) > 0 Then
```

**Fix:** Add lowercase cache fields to `KSComponentEntry` (or parallel arrays in the registry), populated once in `Init()`:
```xojo
// In KSComponentEntry — add fields:
Public NameLC As String
Public ShortDescLC As String
Public KeywordsLC As String
Public CategoryLC As String

// In KSComponentRegistry.Init() when constructing each entry:
e.NameLC = e.Name.Lowercase
e.ShortDescLC = e.ShortDesc.Lowercase
e.KeywordsLC = e.Keywords.Lowercase
e.CategoryLC = e.Category.Lowercase

// In Search() — compare pre-lowercased fields:
Var q As String = query.Lowercase
If InStr(e.NameLC, q) > 0 Or InStr(e.ShortDescLC, q) > 0 Or ...
```

**Complexity change:** 124 `.Lowercase` calls per keystroke → 1 (query only)
**Effort:** Low

---

## 🟡 Medium Priority — Per-Interaction

### OPT-3: Cache category header line indices for `1–6` jump

**File:** `KSApp.xojo_code` — `HandleKey()` category jump block
**Problem:** Every digit key press (1–6) scans the entire `mFlatNodes` array counting Nil entries:
```xojo
For i As Integer = 0 To mFlatNodes.Count - 1
  If mFlatEntries(i) Is Nil Then
    catCount = catCount + 1
    If catCount = catIdx Then SelectLine(i) : Return
```

**Fix:** Add `Private mCategoryHeaderLines(5) As Integer` populated once at the end of `RebuildTree()`:
```xojo
// At end of RebuildTree(), after building mFlatNodes:
Var ci As Integer = 0
For i As Integer = 0 To mFlatNodes.Count - 1
  If mFlatEntries(i) Is Nil Then
    If ci <= 5 Then mCategoryHeaderLines(ci) = i
    ci = ci + 1
  End If
Next i

// In HandleKey() category jump:
If catIdx <= 5 Then SelectLine(mCategoryHeaderLines(catIdx))
```

**Complexity change:** O(n) per keypress → O(1) per keypress
**Effort:** Low

---

### OPT-4: Eliminate nested scan in `RebuildTree()`

**File:** `KSApp.xojo_code` — `RebuildTree()`
**Problem:** For each of 6 categories, scans all entries in the input array — O(categories × n):
```xojo
For i As Integer = 0 To cats.Count - 1       // 6 iterations
  For j As Integer = 0 To entries.Count - 1  // up to 31 per cat
    If entries(j).Category = cat Then
      catEntries.Add(entries(j))
```

**Fix:** Single-pass grouping into a Dictionary before the category loop:
```xojo
// One pass: group entries by category
Var byCategory As New Dictionary
For j As Integer = 0 To entries.Count - 1
  Var cat As String = entries(j).Category
  If Not byCategory.HasKey(cat) Then
    Var arr() As KSComponentEntry
    byCategory.Value(cat) = arr
  End If
  Dim arr() As KSComponentEntry = byCategory.Value(cat)
  arr.Add(entries(j))
  byCategory.Value(cat) = arr
Next j

// Then iterate categories using O(1) lookup
For i As Integer = 0 To cats.Count - 1
  If byCategory.HasKey(cats(i)) Then
    Var catEntries() As KSComponentEntry = byCategory.Value(cats(i))
    // ... build tree nodes
```

**Complexity change:** O(categories × n) → O(n)
**Effort:** Medium (requires Xojo Dictionary usage)

---

## 🟢 Low Priority — Startup / Cold Paths

### OPT-5: Fix O(n²) duplicate check in `Categories()`

**File:** `KSComponentRegistry.xojo_code` — `Categories()`
**Problem:** For each entry, scans the result array to check for duplicate categories:
```xojo
For j As Integer = 0 To result.Count - 1
  If result(j) = cat Then alreadyAdded = True
```
Only runs once at startup — negligible in practice.

**Fix:** Replace the inner scan with a Dictionary keyed by category name, or since categories are fixed and known, replace `Categories()` with a constant array defined once in `Init()`.

**Effort:** Low

---

### OPT-6: Cache full entry list in `ApplySearch()`

**File:** `KSApp.xojo_code` — `ApplySearch()` empty-query branch
**Problem:** On every Esc (search exit), re-fetches all 31 entries into a new array:
```xojo
For i As Integer = 0 To KSComponentRegistry.Count() - 1
  allEntries.Add(KSComponentRegistry.EntryAt(i))
Next i
```
Only runs once per search session exit — negligible in practice.

**Fix:** Store `mAllEntries() As KSComponentEntry` populated once in `PopulateTree()` and reuse it in `ApplySearch()`.

**Effort:** Low

---

## Implementation Order

| # | Optimization | File | Effort | Impact |
|---|-------------|------|--------|--------|
| 1 | OPT-1: Cache help padding strings | `KSApp` | Low | 🔴 High (30fps) |
| 2 | OPT-2: Cache lowercase search fields | `KSComponentRegistry` + `KSComponentEntry` | Low | 🔴 High (per keystroke) |
| 3 | OPT-3: Cache category header indices | `KSApp` | Low | 🟡 Med (per key 1–6) |
| 4 | OPT-4: Single-pass RebuildTree grouping | `KSApp` | Medium | 🟡 Med (per search) |
| 5 | OPT-5: Fix O(n²) in Categories() | `KSComponentRegistry` | Low | 🟢 Low (startup only) |
| 6 | OPT-6: Cache full entry list | `KSApp` | Low | 🟢 Low (cold path) |

> With only 31 components, none of these are blocking performance issues today.
> OPT-1 and OPT-2 are worth doing as good practice; the rest are optional polish.

---

## Applied Fixes

Changes already made to the codebase as prerequisites or corrections discovered during the optimization review session.

---

### FIX-1: Renamed `DIM` reserved keyword in `RenderHelp()`

**File:** `KSApp.xojo_code` — `RenderHelp()`, line 715
**Problem:** `DIM` is a reserved keyword in Xojo — it is the legacy variable declaration syntax (equivalent to `Var` in modern Xojo). Using it as a variable name causes a syntax error:
```xojo
// ❌ Compile error: syntax error
Var DIM As String = esc + "[90m"

// All downstream uses also fail:
out = out + CYAN + "|" + RST + DIM + hintStr + RST + CYAN + "|" + RST
```

**Fix applied:** Renamed to `dimStyle` throughout `RenderHelp()`:
```xojo
// ✅ After fix
Var dimStyle As String = esc + "[90m"

out = out + CYAN + "|" + RST + dimStyle + hintStr + RST + CYAN + "|" + RST
```

**Root cause note:** Same class of problem as `(New XjStyle).Method()` — Xojo reserves certain identifiers that look like valid names in other languages. `DIM`, `VAR`, `IF`, `THEN`, `END`, `AS` are all reserved and cannot be used as variable names.

---

### FIX-2: Replaced `(arithmetic expression).ToString` with intermediate variables

**File:** `KSApp.xojo_code` — `RenderHelp()`, lines 735, 739, 760, 774
**Problem:** Xojo does not allow calling methods directly on the result of an arithmetic expression in parentheses. This caused both a type mismatch and a syntax error on every line that used the pattern:
```xojo
// ❌ Compile errors on all four of these:
out = out + esc + "[" + (startRow + 1).ToString + ";" + ...
out = out + esc + "[" + (startRow + 2).ToString + ";" + ...
out = out + esc + "[" + (startRow + 3 + i).ToString + ";" + ...
out = out + esc + "[" + (hintRow + 1).ToString + ";" + ...
```
Xojo evaluates `"[" + (startRow + 1)` as an attempt to add an Integer to a String before `.ToString` can be applied, producing:
- `Type mismatch error. Expected String, but got Integer`
- `Syntax error`

**Fix applied:** Store each arithmetic result in a named intermediate variable first, then call `.ToString` on that variable:
```xojo
// ✅ After fix — one intermediate variable per computed row number
Var titleRow As Integer = startRow + 1
out = out + esc + "[" + titleRow.ToString + ";" + startCol.ToString + "H"

Var sepRow As Integer = startRow + 2
out = out + esc + "[" + sepRow.ToString + ";" + startCol.ToString + "H"

Var contentRow As Integer = startRow + 3 + i
out = out + esc + "[" + contentRow.ToString + ";" + startCol.ToString + "H"

Var bottomRow As Integer = hintRow + 1
out = out + esc + "[" + bottomRow.ToString + ";" + startCol.ToString + "H"
```

**Root cause note:** This is the same Xojo gotcha previously encountered with `(New XjStyle).SetFG(...)` — Xojo requires a named variable as the receiver of any method call. Arithmetic expressions, `New` expressions, and literal values cannot have methods called on them directly. Always assign to a variable first.

**General rule for future code:**
```xojo
// ❌ Never do this in Xojo:
(someInteger + offset).ToString
(New SomeClass).SomeMethod()
SomeFunction().SomeProperty

// ✅ Always do this instead:
Var temp As Integer = someInteger + offset
temp.ToString

Var obj As New SomeClass
obj.SomeMethod()

Var result As SomeType = SomeFunction()
result.SomeProperty
```
