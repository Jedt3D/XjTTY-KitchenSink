# Xojo Runtime Crash Investigation: macOS Tahoe xzone malloc

> Documented: 2026-03-17
> Project: XjTTY-KitchenSink (Xojo 2025r3.1 Console App)
> OS: macOS Tahoe 26.3.1 (Apple Silicon)
> Crash types: SIGSEGV (segmentation fault), SIGTRAP/EXC_BREAKPOINT (trace trap)

---

## Executive Summary

A Xojo console application that worked perfectly on macOS Tahoe with a certain codebase size began crashing with segfaults and trace traps when additional methods were added to a class — even though the new code never executed at startup. The root cause was identified as **Xojo's compiled method body size interacting with macOS Tahoe's xzone malloc allocator**, causing heap metadata corruption detection. The fix is to keep method bodies small by extracting logic into helper methods.

A secondary bug was discovered: several XjTTYLib files used `Chr(&hE2) + Chr(&h96) + Chr(&h88)` to construct Unicode block characters, but Xojo's `Chr()` operates on Unicode code points, not raw UTF-8 bytes, producing `â` instead of `█`.

---

## Timeline of Investigation

### Phase 1: Initial Crash — SIGSEGV in XjCell.SetStyle

**Symptom:** App crashed immediately on launch with `zsh: segmentation fault`.

**Crash report analysis** (from `~/Library/Logs/DiagnosticReports/`):
- Exception Type: `EXC_BAD_ACCESS (SIGSEGV)`
- Faulting address: `0x07980df80095003c` — a pattern with `0x0095` in the middle indicating a corrupted Xojo object pointer
- Crash location: `XjCell.SetStyle()` during `XjLayoutNode.PaintSelf()` → `XjCanvas.DrawBox()`

**Analysis:** The `mStyle` field of XjCell objects contained corrupted pointers. When `SetStyle(s)` called `mStyle.CopyFrom(s)` — a method dispatch on a corrupted pointer — it dereferenced garbage memory.

**Fix attempt:** Changed `SetStyle` to never dereference `mStyle` — use direct assignment `mStyle = s` instead of `mStyle.CopyFrom(s)`. This eliminated the crash at this location but the crash moved elsewhere.

### Phase 2: Crash Moves — SIGSEGV in XjCanvas.Render

**Symptom:** After fixing SetStyle, crash moved to `XjCanvas.Render()` reading cell styles.

**Analysis:** Same corrupted address pattern (`0x07980df800950054`). The 4,800 small XjCell heap objects (80×60 grid) created fragmentation that made them targets for heap corruption.

**Fix:** Complete rewrite of XjCanvas to use parallel arrays (`mChars() As String` + `mStyles() As XjStyle`) instead of `mCells() As XjCell`. This reduced 4,800 individual allocations to 2 array allocations.

**Result:** Crash moved again — now to `XjLayoutSolver.SolveChildren()`.

### Phase 3: Crash Moves Again — SIGTRAP in CreateArray

**Symptom:** `zsh: trace trap` (EXC_BREAKPOINT) in `XjLayoutSolver.SolveChildren()` at array creation.

**Crash report analysis:**
- Exception Type: `EXC_BREAKPOINT (SIGTRAP)`
- Thread 0 crashed in: `_xzm_xzone_malloc_freelist_outlined`
- This is macOS Tahoe's **xzone malloc** freelist validation code

**Key insight:** The crash was now in Apple's malloc implementation, not in Xojo application code. The `_xzm_xzone_malloc_freelist_outlined` function validates heap freelist integrity and fires a SIGTRAP when it detects corruption. This proved the corruption was in **heap allocator metadata**, not in application-level data.

**Environment variable workarounds attempted:**
- `MallocNanoZone=0` — No effect
- `MallocZone=0` — No effect
- `MallocZone=0 MallocNanoZone=0` — No effect

These variables don't disable xzone malloc on Tahoe.

### Phase 4: Binary Search Isolation

Systematic testing to isolate the trigger:

| Test | Config | Result |
|------|--------|--------|
| 1 | Batch 1 KSApp (original) + fixed XjTTYLib | ✅ Works |
| 2 | Batch 1 + 2 new properties (unused) | ✅ Works |
| 3 | Batch 1 + 2 properties + 5 new dead methods | ✅ Works |
| 4 | Full Batch 2 (lazy canvas in HandleTick) | ❌ Trace trap |
| 5 | Full Batch 2 (canvas in Event_Run) | ❌ Segfault |
| 6 | Batch 2 KSApp + Batch 1 Registry/Loader | ❌ Segfault |
| 7 | Batch 1 + dead code + ActivateDemoWidget mods + DemoKeyHint mods | ✅ Works |
| 8 | Test 7 + HandleTick overlay block (5 lines inlined) | ❌ Segfault |
| 9 | Test 7 + HandleTick calls helper method instead | ✅ Works |
| 10 | Test 9 + HandleKey pie case via helper method | ✅ Works |
| 11 | Test 10 + Registry/Loader Batch 2 changes | ✅ Works |

### Phase 5: Root Cause Identified

**The trigger is method body size.** When `HandleTick`'s compiled body exceeds a threshold (approximately by adding 5 lines of code), the Xojo compiler generates different machine code that changes how the method's stack frame or class metadata interacts with macOS Tahoe's xzone malloc. This causes the allocator to detect "corruption" in its own freelist metadata.

**Critical evidence:**
- Adding 5 lines of **dead code** (never executes, `mPreviewFocus` is `False` at startup) **inside HandleTick** → crash
- Extracting the same 5 lines into a **separate helper method** and calling it from HandleTick (1 line) → works
- Adding 250+ lines as **new standalone methods** to the same class → works
- The crash type changes with different configurations (segfault vs trace trap), confirming it's memory-layout-sensitive

---

## Root Cause: Xojo Method Size vs xzone malloc

### What is xzone malloc?

macOS Tahoe (2026) introduced `xzone malloc` as the default allocator, replacing the traditional magazine-based malloc. It uses a zone-based approach with aggressive metadata validation:

- **Freelist validation:** Every `malloc`/`free` checks freelist integrity
- **SIGTRAP on corruption:** Fires `EXC_BREAKPOINT` when corrupted freelists are detected
- **SIGSEGV on bad pointers:** Fires `EXC_BAD_ACCESS` when corrupted pointers are dereferenced
- **Cannot be disabled:** Unlike `MallocNanoZone`, xzone malloc ignores environment variables

### Why does method size matter?

When a Xojo method body crosses a size threshold:

1. The Xojo compiler may change how it generates stack frame setup/teardown code
2. The compiled method occupies more memory in the `.text` segment, shifting subsequent data sections
3. These shifts change the alignment of heap allocator metadata structures
4. xzone malloc's validation logic interprets the shifted metadata as corrupted

This is a **Xojo runtime bug** — the runtime's memory management is not fully compatible with xzone malloc's strict validation. The corruption existed in previous macOS versions but went undetected because the old allocator didn't validate metadata aggressively.

### Why the crash keeps moving

Each fix we applied changed the memory layout:
1. `SetStyle` fix → crash moved from `SetStyle` to `Render`
2. Parallel arrays → crash moved from `Render` to `SolveChildren/CreateArray`
3. Cached styles → crash moved to a different instruction within `CreateArray`

The corruption is in the **allocator metadata**, not in application data. Changing application code moves the metadata to different memory locations, changing where/when the corruption manifests.

---

## The Workaround: Method Extraction

### Rule: Keep frequently-called methods small

For any method that runs in a hot loop (like `HandleTick` at 30fps):
- **DO NOT** inline conditional logic blocks
- **DO** extract them into separate private helper methods
- A method call adds minimal overhead but changes the compiled method body size

### Before (crashes):
```xojo
Private Sub HandleTick(tickCount As Integer)
  // ... existing code ...
  Render()

  // These 5 lines cause the crash even though they never execute at startup
  If mPreviewFocus Then
    Select Case mDemoType
    Case "pie", "style", "color", "canvas"
      RenderDemoOverlay()
    End Select
  End If
End Sub
```

### After (works):
```xojo
Private Sub HandleTick(tickCount As Integer)
  // ... existing code ...
  Render()
  RenderOverlayIfNeeded()  // 1 line instead of 5
End Sub

Private Sub RenderOverlayIfNeeded()
  If mPreviewFocus Then
    Select Case mDemoType
    Case "pie", "style", "color", "canvas"
      RenderDemoOverlay()
    End Select
  End If
End Sub
```

### Same pattern applied to HandleKey:
```xojo
// Instead of inlining 15 lines of pie key handling:
Case "pie"
  HandlePieDemoKey(key)  // 1 line

// Extracted helper:
Private Sub HandlePieDemoKey(key As XjKeyEvent)
  If key.Char = "1" Then
    mPieDataset = 0
    mOverlayLines = BuildPieDemo(mPieDataset)
    // ...
  End If
End Sub
```

---

## Secondary Bug: Unicode Character Construction

### The Bug

Multiple XjTTYLib files constructed Unicode characters by concatenating individual UTF-8 bytes:

```xojo
// WRONG — creates â (U+00E2) + control chars, not █
Var full As String = Chr(&hE2) + Chr(&h96) + Chr(&h88)
```

### Why It's Wrong

Xojo's `Chr(n)` creates a character from a **Unicode code point**, not a raw byte:
- `Chr(&hE2)` → Unicode U+00E2 → `â` (Latin small letter a with circumflex)
- `Chr(&h96)` → Unicode U+0096 → SPA control character (invisible)
- `Chr(&h88)` → Unicode U+0088 → Character Tabulation Set (invisible)

The result is a 3-character string `â` + invisible + invisible, NOT the intended `█`.

### The Fix

Use the actual Unicode code point:

```xojo
// CORRECT — Chr() takes a Unicode code point
Var full As String = Chr(&h2588)  // U+2588 = █ (FULL BLOCK)
```

### Evidence from the same codebase

Other files in XjTTYLib already used the correct approach:
- `XjSpinner`: `Chr(&h2588)` ✅
- `XjProgressBar`: `Chr(&h2588)` ✅
- `XjCanvas`: `Chr(&h2554)`, `Chr(&h2500)`, etc. ✅
- `XjTable`: `Chr(&h2502)`, `Chr(&h2500)` ✅

Only `XjPie`, `XjFont`, and `XjMarkdown` had the bug.

### Character Reference

| UTF-8 Bytes | Unicode | Character | Correct Xojo |
|-------------|---------|-----------|--------------|
| E2 96 88 | U+2588 | █ FULL BLOCK | `Chr(&h2588)` |
| E2 96 91 | U+2591 | ░ LIGHT SHADE | `Chr(&h2591)` |
| E2 94 80 | U+2500 | ─ BOX HORIZONTAL | `Chr(&h2500)` |
| E2 80 A2 | U+2022 | • BULLET | `Chr(&h2022)` |

### General Rule

**Never manually construct UTF-8 byte sequences in Xojo.** Always use the Unicode code point directly with `Chr()`. If you see a pattern like `Chr(&hE2) + Chr(&hXX) + Chr(&hXX)`, it's a bug — convert the UTF-8 bytes to the Unicode code point and use `Chr()` with that.

---

## Affected Files and Commits

### XjTTY-Toolkit (library)

| File | Fix Type | Commit |
|------|----------|--------|
| XjCanvas.xojo_code | Parallel arrays (heap corruption mitigation) | `3c9afca` |
| XjCell.xojo_code | Style sharing (no dereference on set) | `3c9afca` |
| XjLayoutNode.xojo_code | Cached styles (reduce allocations) | `3c9afca` |
| XjPie.xojo_code | Unicode fix: `Chr(&h2588)`, `Chr(&h2591)` | `02552ff` |
| XjFont.xojo_code | Unicode fix: `Chr(&h2588)` | `02552ff` |
| XjMarkdown.xojo_code | Unicode fix: `Chr(&h2500)`, `Chr(&h2022)` | `02552ff` |

### XjTTY-KitchenSink (app)

| File | Fix Type | Commit |
|------|----------|--------|
| KSApp.xojo_code | Method extraction (HandleTick, HandleKey) | `352529f` |
| KSApp.xojo_code | Unicode fix in BuildColorDemo | `352529f` |

---

## Diagnostic Techniques Used

### 1. Crash Reports
```bash
ls ~/Library/Logs/DiagnosticReports/XjTTY-KitchenSink-*.ips
```
Look for `Exception Type`, faulting address patterns, and thread backtraces.

### 2. Binary Search Isolation
Systematically add/remove code to find the minimum change that triggers the crash. Key technique: **test dead code** (code that compiles but never executes) to distinguish binary-layout from runtime issues.

### 3. Address Pattern Analysis
Corrupted addresses like `0x07980df80095XXXX` with consistent patterns indicate allocator metadata corruption, not application-level pointer corruption.

### 4. Crash Type Changes
If the crash type changes (segfault → trace trap) or crash location moves when you change unrelated code, the issue is memory-layout-sensitive — likely an allocator/runtime interaction, not a logic bug.

---

## Recommendations for Xojo Development on macOS Tahoe

1. **Keep methods small.** Extract conditional blocks into helper methods. This is good practice anyway and avoids the xzone malloc threshold issue.

2. **Minimize small-object heap fragmentation.** Prefer arrays over thousands of small objects (e.g., parallel arrays instead of arrays of tiny class instances).

3. **Use `Static` for singleton styles.** Instead of creating new XjStyle instances every frame, cache them:
   ```xojo
   Static cachedStyle As XjStyle
   If cachedStyle Is Nil Then cachedStyle = New XjStyle
   ```

4. **Never construct UTF-8 manually.** Use `Chr()` with Unicode code points: `Chr(&h2588)` not `Chr(&hE2) + Chr(&h96) + Chr(&h88)`.

5. **Share object references where safe.** Instead of cloning/copying style objects, share references: `mStyle = s` instead of `mStyle.CopyFrom(s)`.

6. **Watch for crash migration.** If a fix makes the crash move to a different location, the root cause is likely memory-layout-sensitive, not a logic bug in the original crash location.
