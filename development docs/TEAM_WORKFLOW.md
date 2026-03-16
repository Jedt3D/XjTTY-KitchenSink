# TEAM_WORKFLOW.md

> กระบวนการทำงานของทีม XjTTY-KitchenSink
>
> Development team workflow for XjTTY-KitchenSink.

---

## Team Roles

### @lead — Lead Architect (สถาปนิกโครงการ)

**รับผิดชอบ:** วางแผนสถาปัตยกรรม กำหนดขอบเขตงาน ตรวจสอบผลงานของ @dev ก่อนส่งให้ Human review

**Responsibilities:**
- Plan each implementation phase — architecture, API contracts, file boundaries
- Delegate to @dev with clear, specific task descriptions
- Review @dev's output for correctness and completeness before human review
- Update CLAUDE.md phase status after completion

**Does NOT:** Write implementation code. The lead designs; the developer builds.

---

### @dev — Developer (นักพัฒนา)

**รับผิดชอบ:** เขียนโค้ดตามแผนของ @lead ตาม Xojo 2025 conventions เขียนโค้ดที่สะอาดและตรงกับ spec

**Responsibilities:**
- Implement code per @lead's specification
- Follow Xojo 2025 syntax and naming conventions
- Write clean, focused code — no speculative additions
- Flag blockers or spec ambiguities to @lead immediately
- Do NOT add comments to code (that's @documentator's role)

---

### Human — Code Reviewer (ผู้ตรวจสอบโค้ด)

**รับผิดชอบ:** ตรวจสอบผลงานของแต่ละ Phase ก่อนที่จะ commit

**Responsibilities:**
- Review each phase output before `/sccs` runs
- Has final say on code quality and correctness
- Approves or requests changes

**The gate:** `/sccs` only runs after Human approval.

---

### @documentator — Documentation & Commentary (นักเขียนเอกสาร)

**รับผิดชอบ:** เขียนและอัปเดตเอกสารทั้งหมด เพิ่ม comment ใน source code แบบสองภาษา (ไทย/อังกฤษ)

**Responsibilities:**
- Maintain: `README.md`, `CLAUDE.md`, `CHANGELOG.md`, `DEV_CODE_WALKTHROUGH.md`
- Add bilingual Thai/English inline comments to all source files
- Proficient in both software development and Thai editorial writing
- Comments describe *why*, not just *what*
- Thai comments target Thai developers reading the code for the first time

**Comment format:**
```xojo
// [EN] Brief English explanation of the intent
// [TH] คำอธิบายภาษาไทยสำหรับนักพัฒนาไทยที่เพิ่งเข้ามาอ่านโค้ด
```

---

## Phase Workflow

Each phase follows this cycle:

```
┌──────────────────────────────────────────────────────────────┐
│                    PHASE CYCLE                                │
│                                                              │
│  1. @lead      → Define scope, architecture, task list       │
│  2. @dev       → Implement code                              │
│  3. @lead      → Review implementation, check against spec   │
│  4. Human      → Code review (approve or request changes)    │
│  5. @documentator → Add bilingual comments, update docs      │
│  6. /sccs      → Summarize, update CLAUDE.md + CHANGELOG.md, │
│                   git commit                                  │
└──────────────────────────────────────────────────────────────┘
```

---

## Phase Checklist

### Phase 1 — Skeleton
- [ ] @lead: Define widget tree structure and event loop setup
- [ ] @dev: Create KitchenSink.xojo_project, KSApp skeleton
- [ ] @dev: Build 4-panel layout (XjBox hierarchy)
- [ ] @dev: XjEventLoop with resize guard (80×24 minimum)
- [ ] @dev: `q` to quit
- [ ] @lead: Verify compiles and renders layout correctly
- [ ] Human: Code review ✓
- [ ] @documentator: Add bilingual comments to KSApp
- [ ] /sccs ← run after human approval

### Phase 2 — Component Registry & Navigation
- [ ] @lead: Define KSComponentRegistry API
- [ ] @dev: Implement KSComponentRegistry with all 31 entries
- [ ] @dev: XjTree populated with categorized list
- [ ] @dev: Up/Down/Enter/Space navigation wired
- [ ] @dev: currentLabel and statusBar update on selection
- [ ] @lead: Verify navigation and data correctness
- [ ] Human: Code review ✓
- [ ] @documentator: Add bilingual comments to KSComponentRegistry
- [ ] /sccs

### Phase 3 — Search & Autocomplete
- [ ] @lead: Define search filtering logic
- [ ] @dev: XjTextInput wired with XjCompleter
- [ ] @dev: KSComponentRegistry.Search() implemented
- [ ] @dev: Tree filters on search input change
- [ ] @dev: `/` jump to search, Esc to clear
- [ ] @lead: Verify search accuracy and UX
- [ ] Human: Code review ✓
- [ ] @documentator: Add bilingual comments to search logic
- [ ] /sccs

### Phase 4 — Static Previews
- [ ] @lead: Define KSPreviewBuilder API and preview specs
- [ ] @dev: KSPreviewBuilder skeleton with BuildPreview() dispatch
- [ ] @dev: All 31 preview builders (static first)
- [ ] @dev: Prompt mockups as styled XjText
- [ ] @dev: Reference cards for Foundation/Layout components
- [ ] @dev: Properties table populated per component
- [ ] @lead: Verify all 31 previews render correctly
- [ ] Human: Code review ✓
- [ ] @documentator: Add bilingual comments to KSPreviewBuilder
- [ ] /sccs

### Phase 5 — Interactive Previews
- [ ] @lead: Define key routing architecture for preview zone
- [ ] @dev: HandlePreviewKey() dispatch in KSPreviewBuilder
- [ ] @dev: Interactive widgets (Box, Text, TextInput, Table, ProgressBar, Spinner, Tree)
- [ ] @dev: Interactive utilities (Font, Pie, Style, KeyEvent)
- [ ] @dev: Focus zone 3 (preview) wired in FocusManager
- [ ] @lead: Verify all 15 interactive previews
- [ ] Human: Code review ✓
- [ ] @documentator: Add bilingual comments to interactive handlers
- [ ] /sccs

### Phase 6 — Polish
- [ ] @lead: Define polish scope and edge cases
- [ ] @dev: Help overlay (`?` key, centered modal)
- [ ] @dev: Category jump shortcuts (`1`–`6`)
- [ ] @dev: Page Up/Down, Home/End in list
- [ ] @dev: Edge cases (rapid resize, empty search, boundary values)
- [ ] @lead: Full verification against success criteria (KITCHEN_SINK_PROPOSAL.md §12)
- [ ] Human: Final review ✓
- [ ] @documentator: Final doc pass — all files fully documented
- [ ] /sccs (final release commit)

---

## Communication Protocol

**@lead → @dev:** Task descriptions must include:
- What file to work in
- Specific methods/classes to implement
- Any API constraints (must match XjTTYLib signatures)
- The "verify" criterion (how to know it's done)

**@dev → @lead (blockers):** Flag immediately with:
- What was attempted
- What failed or is ambiguous
- What decision is needed

**Human → team:** Feedback format:
- ✅ Approved
- 🔄 Changes requested: [specific issue]
- ❌ Blocked: [reason]

---

## Source Code Comment Standards

All source files receive bilingual comments from @documentator after each phase.

### When to comment
- Class/Module declaration: purpose and lifecycle
- Each method: intent, non-obvious behavior
- Complex logic blocks: step-by-step in both languages
- Module-level properties: what state they represent

### When NOT to comment
- Self-explanatory variable assignments
- Simple getter/setter wrappers
- Code that directly mirrors the spec (the spec is the comment)

### Example

```xojo
// [EN] KSApp is the application entry point. It owns the widget tree,
//      event loop, and all mutable UI state. Other modules are stateless
//      factories or data stores.
// [TH] KSApp คือจุดเริ่มต้นของแอปพลิเคชัน เป็นเจ้าของ widget tree,
//      event loop และ state ทั้งหมดของ UI ส่วน module อื่นๆ เป็น
//      factory หรือ data store ที่ไม่มี state
Class KSApp Inherits ConsoleApplication

  // [EN] Run() is the single entry point — called once by the Xojo runtime.
  //      After loop.Run(), control never returns here until the user quits.
  // [TH] Run() คือ entry point เดียว — ถูกเรียกครั้งเดียวโดย Xojo runtime
  //      หลังจาก loop.Run() เรียกแล้ว การควบคุมจะไม่กลับมาที่นี่จนกว่าผู้ใช้จะออกจากแอป
  Event Run(args() As String) As Integer
```

---

*เขียนโดย @documentator · 2026-03-13*
