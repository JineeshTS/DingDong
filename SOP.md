# STANDARD OPERATING PROCEDURES (SOP)
## DingDong Task Management App Development

**Version**: 1.0
**Date**: November 10, 2025
**Status**: ACTIVE - MUST FOLLOW

---

## ⚠️ CRITICAL DEVELOPMENT INSTRUCTIONS

### 1. DEVELOPMENT SCOPE
✅ **FULL PRODUCT DEVELOPMENT** - No MVP shortcuts
✅ Build complete feature set as specified in REQUIREMENTS.md
✅ All features must be production-ready

### 2. TESTING PROTOCOL (MANDATORY)

#### 2.1 After EVERY Feature Development:
1. **Write comprehensive tests for the new feature**
   - Unit tests (business logic)
   - Widget tests (UI components)
   - Integration tests (end-to-end flows)

2. **Run ALL existing tests**
   - Execute complete test suite
   - Ensure 100% pass rate
   - No exceptions allowed

3. **Manual testing of ALL features**
   - Test every previously developed feature
   - Test on all target platforms (iOS, Android, Web, Desktop)
   - Verify no regressions

4. **Document test results**
   - Record what was tested
   - Record test outcomes
   - Note any issues found

### 3. ISSUE MANAGEMENT PROTOCOL

#### 3.1 When Issues Are Found:

**Step 1: Issue Identification**
- Document the issue clearly (what, where, when, how to reproduce)
- Classify severity:
  - 🔴 **Critical**: App crashes, data loss, security breach
  - 🟠 **High**: Major feature broken, poor UX
  - 🟡 **Medium**: Minor feature broken, cosmetic issues
  - 🟢 **Low**: Nice-to-have improvements
- Take screenshots/screen recordings
- Capture logs and error messages
- Create issue ticket

**Step 2: Root Cause Analysis (RCA)**
- Analyze the code causing the issue
- Trace execution flow to find the source
- Identify WHY it happened (not just what)
- Check related code for similar issues
- Document findings in detail:
  ```
  Issue: [Description]
  Root Cause: [Detailed explanation]
  Affected Components: [List all affected areas]
  ```

**Step 3: Impact Analysis**
- Determine which components/features are affected
- Identify dependencies (what depends on this code)
- Assess risk level of potential fixes
- Identify potential side effects
- Estimate effort required
- Document impact assessment:
  ```
  Directly Affected: [Components]
  Indirectly Affected: [Components]
  Risk Level: [High/Medium/Low]
  Dependencies: [List]
  Estimated Fix Time: [Hours]
  ```

**Step 4: Fix Implementation (ONE AT A TIME)**
- **IMPORTANT**: Fix ONE issue at a time
- Never batch fixes
- Implement the fix
- Write/update tests for the fix
- Run tests for the specific fix
- **Run ALL tests (complete test suite)**
- **Manually test ALL features (complete regression)**
- Document the fix:
  ```
  Fix Description: [What was changed]
  Files Modified: [List]
  Tests Added/Modified: [List]
  Verification: [How fix was verified]
  ```

**Step 5: Verification**
- ✅ All automated tests pass
- ✅ Manual testing confirms fix
- ✅ No new issues introduced
- ✅ All previous features still work
- ✅ Performance not degraded
- ✅ Documentation updated

**Step 6: If New Issues Found During Fix**
- STOP current fix process
- Document new issues
- Repeat from Step 1 for new issues
- Return to original fix only after new issues resolved

### 4. QUALITY GATES (No Exceptions)

**Feature CANNOT proceed to next phase until:**
- ✅ All unit tests written and passing (100%)
- ✅ All widget tests written and passing (100%)
- ✅ All integration tests written and passing (100%)
- ✅ All previous features tested and working (100%)
- ✅ Code meets quality standards (linting, formatting)
- ✅ Code reviewed (if team environment)
- ✅ Documentation updated
- ✅ No known bugs (all issues resolved)
- ✅ Performance benchmarks met
- ✅ Accessibility requirements met
- ✅ Security requirements met

### 5. TESTING CHECKLIST (After Each Feature)

#### 5.1 Automated Testing
- [ ] Unit tests pass (100%)
- [ ] Widget tests pass (100%)
- [ ] Integration tests pass (100%)
- [ ] Code coverage ≥ 80%
- [ ] No test failures
- [ ] No test warnings
- [ ] Performance tests pass

#### 5.2 Core Functionality Testing
- [ ] **Authentication**
  - [ ] Email/password login
  - [ ] Google OAuth
  - [ ] Apple Sign In
  - [ ] Microsoft OAuth
  - [ ] 2FA (if implemented)
  - [ ] Biometric auth
  - [ ] Logout
  - [ ] Session management

- [ ] **Task Management**
  - [ ] Create task
  - [ ] Read/view task
  - [ ] Update task
  - [ ] Delete task
  - [ ] Complete task
  - [ ] Uncomplete task
  - [ ] Task with all properties
  - [ ] Task search
  - [ ] Task filtering

- [ ] **List Management**
  - [ ] Create list
  - [ ] Read/view list
  - [ ] Update list
  - [ ] Delete list
  - [ ] Archive list
  - [ ] Share list
  - [ ] List permissions

- [ ] **Subtasks & Checklists**
  - [ ] Create subtask
  - [ ] Nested subtasks
  - [ ] Complete subtask
  - [ ] Convert subtask to task
  - [ ] Move subtasks
  - [ ] Checklist items

- [ ] **Reminders & Notifications**
  - [ ] Time-based reminders
  - [ ] Location-based reminders
  - [ ] Notification delivery
  - [ ] Notification actions
  - [ ] Snooze functionality
  - [ ] Custom sounds

- [ ] **Recurring Tasks**
  - [ ] Daily recurrence
  - [ ] Weekly recurrence
  - [ ] Monthly recurrence
  - [ ] Yearly recurrence
  - [ ] Custom patterns
  - [ ] Recurrence completion
  - [ ] Skip occurrence

- [ ] **Sync & Offline**
  - [ ] Online sync works
  - [ ] Offline mode works
  - [ ] Sync after reconnection
  - [ ] Conflict resolution
  - [ ] Real-time updates

#### 5.3 View Testing
- [ ] **List View**
  - [ ] Displays correctly
  - [ ] Swipe gestures work
  - [ ] Drag-and-drop works
  - [ ] Inline editing works
  - [ ] Batch selection works
  - [ ] Sorting works
  - [ ] Grouping works

- [ ] **Calendar View**
  - [ ] Day view renders
  - [ ] Week view renders
  - [ ] Month view renders
  - [ ] Agenda view renders
  - [ ] Drag-and-drop reschedule works
  - [ ] Event creation works
  - [ ] Multiple calendars overlay

- [ ] **Kanban Board** (if implemented)
  - [ ] Board renders correctly
  - [ ] Drag between columns works
  - [ ] Card details display
  - [ ] WIP limits enforced

- [ ] **Other Views** (as implemented)
  - [ ] Eisenhower Matrix
  - [ ] Gantt/Timeline
  - [ ] Focus/Today view

#### 5.4 Productivity Features
- [ ] **Pomodoro Timer** (if implemented)
  - [ ] Timer starts/stops
  - [ ] Break timer works
  - [ ] Session tracking
  - [ ] Notifications work

- [ ] **Time Tracking** (if implemented)
  - [ ] Manual entry works
  - [ ] Timer works
  - [ ] Reports generate

- [ ] **Habit Tracker** (if implemented)
  - [ ] Create habit
  - [ ] Check-in works
  - [ ] Streak tracking
  - [ ] Calendar view

- [ ] **Statistics** (if implemented)
  - [ ] Data displays correctly
  - [ ] Charts render
  - [ ] Exports work

#### 5.5 Collaboration Features (if implemented)
- [ ] **Workspaces**
  - [ ] Create workspace
  - [ ] Switch workspace
  - [ ] Workspace settings
  - [ ] Roles and permissions

- [ ] **Sharing**
  - [ ] Share list works
  - [ ] Permissions enforced
  - [ ] Notifications sent
  - [ ] Un-share works

- [ ] **Comments**
  - [ ] Post comment
  - [ ] @mentions work
  - [ ] Edit comment
  - [ ] Delete comment
  - [ ] Notifications sent

#### 5.6 AI Features (if implemented)
- [ ] **AI Image Recognition**
  - [ ] Camera opens
  - [ ] Image capture works
  - [ ] OCR extraction works
  - [ ] Task creation from image
  - [ ] Confidence indicators
  - [ ] Manual editing works

- [ ] **AI Suggestions**
  - [ ] Priority suggestions
  - [ ] Scheduling suggestions
  - [ ] Tag suggestions

#### 5.7 Integrations (as implemented)
- [ ] **Google Calendar**
  - [ ] Authentication works
  - [ ] Two-way sync works
  - [ ] Events display correctly
  - [ ] Tasks sync as events

- [ ] **Other Integrations** (check each)
  - [ ] Slack integration
  - [ ] Notion integration
  - [ ] Email integration
  - [ ] etc.

#### 5.8 Navigation & UI
- [ ] **Navigation**
  - [ ] All routes work
  - [ ] Back button works
  - [ ] Deep linking works
  - [ ] Bottom nav works (mobile)
  - [ ] Side nav works (desktop)

- [ ] **UI/UX**
  - [ ] All screens render correctly
  - [ ] No visual glitches
  - [ ] Animations smooth (60fps)
  - [ ] Gestures responsive
  - [ ] Loading states display
  - [ ] Error states display
  - [ ] Empty states display

#### 5.9 Theming
- [ ] Light mode works
- [ ] Dark mode works
- [ ] Auto mode works
- [ ] Theme switching works
- [ ] Custom themes work (if implemented)
- [ ] Colors consistent

#### 5.10 Accessibility
- [ ] Screen reader support
- [ ] Keyboard navigation
- [ ] Focus indicators visible
- [ ] High contrast readable
- [ ] Large text support
- [ ] Reduced motion respected

#### 5.11 Performance
- [ ] App launch < 2 seconds
- [ ] No lag during normal use
- [ ] Scrolling smooth
- [ ] Animations 60fps
- [ ] Memory usage acceptable
- [ ] Battery impact minimal
- [ ] No memory leaks

#### 5.12 Platform-Specific (All Platforms)
- [ ] **iOS** (if implemented)
  - [ ] iPhone works
  - [ ] iPad works
  - [ ] Widgets work
  - [ ] Shortcuts work
  - [ ] Share extension works

- [ ] **Android** (if implemented)
  - [ ] Phone works
  - [ ] Tablet works
  - [ ] Widgets work
  - [ ] Quick settings work

- [ ] **Web** (if implemented)
  - [ ] Chrome works
  - [ ] Firefox works
  - [ ] Safari works
  - [ ] Edge works
  - [ ] PWA installs
  - [ ] Offline works

- [ ] **Desktop** (if implemented)
  - [ ] macOS works
  - [ ] Windows works
  - [ ] Linux works
  - [ ] Keyboard shortcuts work

#### 5.13 Security
- [ ] Authentication secure
- [ ] API calls encrypted (HTTPS)
- [ ] Local storage encrypted
- [ ] No sensitive data in logs
- [ ] Input validation works
- [ ] XSS prevention works
- [ ] Rate limiting works

#### 5.14 Error Handling
- [ ] Network errors handled
- [ ] Authentication errors handled
- [ ] Validation errors displayed
- [ ] Server errors handled
- [ ] Offline errors handled
- [ ] User-friendly error messages
- [ ] Errors logged (Crashlytics)

### 6. DEVELOPMENT WORKFLOW

#### 6.1 Before Starting New Feature
1. Review requirements for the feature
2. Review WBS for the feature breakdown
3. Design architecture/approach
4. Identify dependencies
5. Create feature branch (if using git flow)
6. Update todo list

#### 6.2 During Feature Development
1. Write code following clean architecture
2. Follow coding standards (Dart style guide)
3. Add inline comments for complex logic
4. Keep commits atomic and well-described
5. Update todo list as progress made

#### 6.3 After Feature Completion
1. Write tests (unit, widget, integration)
2. Run all tests
3. Manual testing (feature + all previous)
4. Fix any issues (follow Issue Management Protocol)
5. Update documentation
6. Mark todo as complete
7. Commit with clear message
8. Move to next feature

### 7. CODE QUALITY STANDARDS

#### 7.1 Code Structure
- Follow Clean Architecture (Presentation → Domain → Data)
- Use dependency injection
- Separate business logic from UI
- Use meaningful variable/function names
- Keep functions small and focused
- Avoid code duplication (DRY principle)

#### 7.2 Code Style
- Follow Dart style guide
- Use `flutter analyze` and fix all issues
- Use `flutter format` for consistent formatting
- No warnings allowed
- No errors allowed
- Keep files under 300 lines when possible

#### 7.3 Documentation
- Document all public APIs
- Add comments for complex logic
- Keep README updated
- Update changelog
- Document breaking changes

### 8. VERSION CONTROL

#### 8.1 Commit Messages
Format: `type(scope): description`

Types:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `docs`: Documentation changes
- `style`: Code style changes
- `perf`: Performance improvements
- `chore`: Build/tooling changes

Example: `feat(tasks): add recurring task support`

#### 8.2 Branching (if team environment)
- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature branches
- `fix/*`: Bug fix branches
- `hotfix/*`: Critical fixes

### 9. PERFORMANCE BENCHMARKS

All features must meet these targets:
- **App launch**: < 2 seconds (cold start)
- **Task creation**: < 100ms response time
- **List loading**: < 500ms
- **Search results**: < 300ms
- **Calendar rendering**: < 1 second
- **Animations**: 60fps minimum
- **Memory usage**: < 150MB (normal use)
- **App size**: < 50MB (initial download)

### 10. ACCESSIBILITY REQUIREMENTS

All features must support:
- Screen readers (VoiceOver, TalkBack)
- Keyboard navigation
- High contrast mode
- Large text (up to 200%)
- Reduced motion
- Color blind friendly (don't rely solely on color)
- WCAG 2.1 AA compliance minimum

### 11. SECURITY REQUIREMENTS

All features must implement:
- Input validation
- Output sanitization
- XSS prevention
- SQL injection prevention (if applicable)
- CSRF protection (if applicable)
- Secure data storage
- Encrypted communications
- Authentication/authorization checks

### 12. DOCUMENTATION REQUIREMENTS

For each feature, document:
- User-facing documentation (Help Center)
- Developer documentation (code comments, API docs)
- Test documentation (test plans, test cases)
- Known limitations
- Future improvements

### 13. CONTINUOUS IMPROVEMENT

After each feature:
- Reflect on what went well
- Identify what could be improved
- Update this SOP if needed
- Share learnings with team
- Celebrate wins! 🎉

---

## ⚠️ GOLDEN RULES (Never Break These)

1. **NEVER skip testing** - No exceptions, ever
2. **ALWAYS test everything** - Not just new code, everything
3. **FIX ISSUES IMMEDIATELY** - Don't accumulate technical debt
4. **ONE ISSUE AT A TIME** - Never batch fixes
5. **DOCUMENT EVERYTHING** - Code, tests, decisions, issues
6. **NO SHORTCUTS** - Full product, not MVP
7. **QUALITY OVER SPEED** - Better to be slow and right than fast and wrong
8. **TEST ON ALL PLATFORMS** - Don't assume it works elsewhere
9. **FOLLOW THE PROCESS** - This SOP exists for a reason
10. **COMMUNICATE CLEARLY** - Document decisions and changes

---

## 🎯 SUCCESS CRITERIA

A feature is DONE when:
- ✅ All code written and reviewed
- ✅ All tests written and passing (100%)
- ✅ All previous features tested and working (100%)
- ✅ All quality gates passed
- ✅ All platforms tested
- ✅ Documentation updated
- ✅ No known issues
- ✅ Performance benchmarks met
- ✅ Accessibility requirements met
- ✅ Security requirements met
- ✅ Stakeholder approved (if applicable)

---

**Remember: Quality is not negotiable. We're building a world-class product.**

**End of SOP**
