# DingDong - Complete File Structure & Inventory

## PRESENTATION LAYER - ALL SCREENS & WIDGETS

### Authentication Screens (4 screens)
```
lib/presentation/screens/auth/
├── login_screen.dart              (200+ lines) - Email/password + OAuth
├── register_screen.dart            (352 lines) - Sign up with requirements
├── forgot_password_screen.dart     - Password recovery flow
└── splash_screen.dart              - App splash/startup

lib/presentation/screens/onboarding/
└── onboarding_screen.dart         - 4-page welcome experience
```

### Task Management Screens (5 screens + widgets)
```
lib/presentation/screens/tasks/
├── task_list_screen.dart          (574 lines)
│   - 5 filter tabs: All, Today, Upcoming, Overdue, Completed
│   - Pull-to-refresh
│   - Real-time updates
│   - Empty states
├── task_detail_screen.dart        (905 lines) ⭐ LARGEST SCREEN
│   - Full task info display
│   - Priority indicators
│   - Due date metadata
│   - Subtasks, comments, attachments sections
│   - Complete/uncomplete toggle
│   - Edit, delete, more options
├── task_form_screen.dart          (714 lines)
│   - Create & edit task form
│   - Title & description validation
│   - Due date picker
│   - Priority selector (5 levels)
│   - Tags management
│   - Category/list selector
└── widgets/
    └── quick_add_task_dialog.dart - Bottom sheet for fast task creation
```

### Visualization Views (4 major view systems)

#### Calendar View (5 files, 1,200+ lines)
```
lib/presentation/screens/calendar/
├── calendar_screen.dart
│   - Navigation bar with previous/next/today
│   - View mode selector (month/week/day)
│   - Integration with providers
├── widgets/
│   ├── calendar_date_cell.dart     - Individual date cell with indicators
│   ├── month_view_calendar.dart    - Full month grid layout
│   ├── week_view_calendar.dart     - 7-column weekly view
│   └── day_view_calendar.dart      - Detailed daily task list

lib/presentation/providers/calendar/
├── calendar_state.dart             - State model with Freezed
├── calendar_notifier.dart          - View logic (250+ lines)
└── calendar_providers.dart         - 20+ Riverpod providers
```

#### Kanban Board (3 files, 1,500+ lines)
```
lib/presentation/screens/kanban/
├── kanban_screen.dart             (371 lines)
│   - Statistics bar
│   - WIP limit warnings
│   - Filter menu
│   - Horizontal scrollable board
│   - Refresh functionality
└── widgets/
    ├── kanban_column_widget.dart   - Collapsible columns with WIP
    └── kanban_card_widget.dart     - Task cards with drag handle

lib/presentation/providers/kanban/
├── kanban_state.dart              - State with Freezed
├── kanban_notifier.dart           - Drag & drop logic (250+ lines)
└── kanban_providers.dart          - 15+ providers
```

#### Eisenhower Matrix (3 files, 1,400+ lines)
```
lib/presentation/screens/eisenhower/
├── eisenhower_matrix_screen.dart  (520 lines)
│   - 2×2 grid layout
│   - Auto-categorization
│   - Focus mode (full-screen quadrant)
│   - Color-coded quadrants:
│     Q1 (Red): Urgent & Important
│     Q2 (Blue): Not Urgent & Important
│     Q3 (Orange): Urgent & Not Important
│     Q4 (Gray): Not Urgent & Not Important
└── widgets/
    ├── matrix_quadrant_widget.dart - Color-coded quadrants
    └── matrix_task_card.dart       - Compact task display

lib/presentation/providers/eisenhower/
├── eisenhower_state.dart          - State model
├── eisenhower_notifier.dart       - Categorization logic (250+ lines)
└── eisenhower_providers.dart      - 15+ providers
```

#### Focus/Today View (2 files, 1,300+ lines)
```
lib/presentation/screens/focus/
├── focus_screen.dart              (542 lines)
│   - Time-based greeting
│   - Progress indicator
│   - "What's Next" smart suggestion
│   - Morning planning prompt (6am-10am)
│   - Evening review prompt (6pm-10pm)
│   - Overdue tasks section
│   - Today's tasks section
│   - Completed tasks toggle
└── widgets/
    └── today_task_card.dart       - Quick complete checkbox

lib/presentation/providers/focus/
├── focus_state.dart               - State with Freezed
├── focus_notifier.dart            - Smart suggestion logic (200+ lines)
└── focus_providers.dart           - 20+ providers
```

### Productivity Features (6 screens)

#### Analytics Dashboard (3 files, 1,450+ lines)
```
lib/presentation/screens/analytics/
├── analytics_dashboard_screen.dart (524 lines)
│   - Period selector (Today, Week, Month, Year, All Time)
│   - Key metrics: Completion rate, stats
│   - Completion trend charts
│   - Streaks tracking
│   - Priority distribution
└── widgets/
    ├── stat_card.dart             - Gradient stat display
    └── simple_bar_chart.dart      - Daily task trends

lib/presentation/providers/analytics/
├── analytics_state.dart           - State with Freezed
├── analytics_notifier.dart        - Stats calculation (400+ lines)
└── analytics_providers.dart       - 15+ providers
```

#### Focus Timer / Pomodoro (5 files, 2,050+ lines)
```
lib/presentation/screens/focus_timer/
├── focus_timer_screen.dart        (417 lines)
│   - Circular timer display
│   - Session controls
│   - Task linking interface
│   - Statistics dashboard
│   - Settings dialog
│   - Duration configuration
└── widgets/
    ├── circular_timer.dart        - Custom circular progress
    ├── timer_controls.dart        - Play/pause/stop buttons
    ├── session_type_selector.dart - Pomodoro/break selection
    └── focus_stats_card.dart      - Today's statistics

lib/presentation/providers/focus_timer/
├── focus_timer_state.dart         - State with timer tracking
├── focus_timer_notifier.dart      - Timer logic (450+ lines)
└── focus_timer_providers.dart     - 25+ derived providers
```

#### Time Tracking (5 files, 2,250+ lines)
```
lib/presentation/screens/time_tracking/
├── time_tracking_screen.dart
│   - Period selector (7 options)
│   - Time stats dashboard
│   - Daily time breakdown
│   - Task time breakdown
│   - Estimation accuracy card
└── widgets/
    ├── time_stats_card.dart       - Total/billable stats
    ├── task_time_list.dart        - Task breakdown
    ├── daily_time_chart.dart      - Bar chart
    └── period_selector.dart       - Period chips

lib/presentation/providers/time_tracking/
├── time_tracking_state.dart       - State with analytics
├── time_tracking_notifier.dart    - Time calculations (450+ lines)
└── time_tracking_providers.dart   - 30+ providers
```

#### Habit Tracker (3 files, 2,000+ lines)
```
lib/presentation/screens/habit_tracker/
├── habit_tracker_screen.dart      (408 lines)
│   - Today's habits list
│   - Check-in functionality
│   - Habit statistics
│   - Create habit dialog with 15+ templates
│   - View modes (list, grid, calendar)
└── widgets/
    ├── habit_card.dart            - Check-in button + streak
    └── habit_stats_card.dart      - Progress & streaks

lib/presentation/providers/habit_tracker/
├── habit_tracker_state.dart       - State with templates
├── habit_tracker_notifier.dart    - CRUD + check-in logic (400+ lines)
└── habit_tracker_providers.dart   - 30+ providers
```

#### Goals & Milestones (2 files, 1,500+ lines)
```
lib/presentation/screens/goals/
├── goals_screen.dart
│   - Statistics dashboard
│   - Goals list with filtering
│   - Goal creation dialog with 8+ templates
│   - Goal details bottom sheet
│   - Manual progress slider
│   - Milestone checklist
└── widgets/
    └── goal_card.dart             - Progress bar + category

lib/presentation/providers/goals/
├── goals_state.dart               - State with progress tracking
├── goals_notifier.dart            - CRUD + milestone logic (400+ lines)
└── goals_providers.dart           - 20+ providers
```

### Collaboration & Teams (5 screens)

#### Workspaces (3 files, 990+ lines)
```
lib/presentation/screens/workspaces/
├── workspaces_screen.dart         (619 lines)
│   - Statistics dashboard
│   - Personal workspaces section
│   - Team workspaces section
│   - Workspace creation dialog
│   - Details sheet with members
└── widgets/
    ├── workspace_card.dart        - Workspace with metadata
    └── workspace_switcher.dart    - Quick workspace switcher

lib/presentation/providers/workspace/
├── workspace_state.dart           - Workspace management state
├── workspace_notifier.dart        - CRUD operations (580+ lines)
└── workspace_providers.dart       - 30+ providers
```

#### Team Dashboard (1 file, 561 lines)
```
lib/presentation/screens/teams/
└── team_dashboard_screen.dart
    - Team overview & statistics
    - Members list with roles
    - Quick actions
    - Workspace information
```

#### Shared Lists (3 files, 780+ lines)
```
lib/presentation/screens/lists/
├── shared_lists_screen.dart
│   - Lists shared with current user
│   - Permission display
│   - Access to settings dialog
└── widgets/
    ├── share_list_dialog.dart     - Permission management
    └── list_collaborators_widget.dart - Stacked avatars

lib/presentation/providers/list/
├── list_state.dart                - Sharing state
├── list_notifier.dart             - Share operations (481+ lines)
└── list_providers.dart            - Sharing providers
```

### Advanced Features (4 screens)

#### Task Templates (2 files, 1,370+ lines)
```
lib/presentation/screens/templates/
├── templates_screen.dart          (506 lines)
│   - Tabbed interface (predefined vs user)
│   - 5+ predefined templates
│   - 11 template categories
│   - Usage statistics
│   - Create template dialog
└── widgets/
    └── template_card.dart         - Usage count + subtasks

lib/presentation/providers/templates/
├── template_state.dart            - Template state with Freezed
├── template_notifier.dart         - CRUD + persistence (400+ lines)
└── template_providers.dart        - 15+ providers
```

#### Automation Rules (2 files, 1,350+ lines)
```
lib/presentation/screens/automations/
├── automations_screen.dart        (529 lines)
│   - 3-tab interface (all, active, predefined)
│   - Automation details modal
│   - Execution statistics
│   - Enable/disable toggle
│   - Create automation dialog
└── widgets/
    └── automation_card.dart       - Trigger → Actions flow

lib/presentation/providers/automations/
├── automation_state.dart          - Automation state
├── automation_notifier.dart       - CRUD + execution (450+ lines)
└── automation_providers.dart      - 14+ providers
```

---

## COMMON COMPONENTS (Reusable Widgets)

```
lib/presentation/common/widgets/
├── app_button.dart               - 5 variants (primary, secondary, outlined, text, destructive)
├── app_card.dart                 - 4 padding variants
├── app_loading.dart              - 3 sizes, overlay, shimmer
├── app_text_field.dart           - 3 sizes, validation
├── quick_add_task_dialog.dart    - Fast task entry
└── widgets.dart                  - Exports

PLUS ~50 screen-specific widgets:
  - Task cards, list items
  - Calendar cells, month/week/day views
  - Kanban columns
  - Stat cards
  - Progress indicators
  - Avatar stacks
  - And many more...
```

---

## STATE MANAGEMENT PROVIDERS (90 Total)

```
lib/presentation/providers/
├── auth/                          (11 providers)
│   ├── auth_state.dart
│   ├── auth_notifier.dart
│   └── auth_providers.dart
├── task/                          (25 providers)
│   ├── task_state.dart
│   ├── task_notifier.dart        (1,255 lines - LARGEST NOTIFIER)
│   └── task_providers.dart       (859 lines)
├── list/                          (10 providers)
├── user/                          (10 providers)
├── reminder/                      (8 providers)
├── tag/                           (8 providers)
├── comment/                       (8 providers)
├── attachment/                    (8 providers)
├── habit/                         (10 providers)
├── habit_tracker/                 (Habit tracker views)
├── focus_session/                 (10 providers)
├── workspace/                     (10 providers)
├── calendar/                      (Calendar view providers)
├── kanban/                        (Kanban view providers)
├── eisenhower/                    (Matrix view providers)
├── focus/                         (Focus/Today view providers)
├── focus_timer/                   (Pomodoro timer providers)
├── analytics/                     (Analytics providers)
├── time_tracking/                 (Time tracking providers)
├── templates/                     (Template providers)
├── automations/                   (Automation providers)
└── goals/                         (Goal providers)

TOTAL: 90 provider files across 23 domains
```

---

## BUSINESS LOGIC LAYER (119 Use Cases)

```
lib/domain/usecases/
├── auth/                          (11 use cases)
│   ├── sign_in_with_email_usecase.dart
│   ├── sign_up_with_email_usecase.dart
│   ├── sign_out_usecase.dart
│   └── 8 more...
├── task/                          (25 use cases)
│   ├── create_task_usecase.dart
│   ├── complete_task_usecase.dart
│   ├── search_tasks_usecase.dart
│   └── 22 more...
├── list/                          (10 use cases)
├── user/                          (10 use cases)
├── reminder/                      (8 use cases)
├── tag/                           (8 use cases)
├── comment/                       (8 use cases)
├── attachment/                    (8 use cases)
├── habit/                         (10 use cases)
├── focus_session/                 (10 use cases)
└── workspace/                     (10 use cases)

TOTAL: 118 use cases (119 files with 1 folder)
```

---

## DATA LAYER

```
lib/data/

MODELS (21 files)
├── models/
│   ├── user_model.dart
│   ├── task_model.dart
│   ├── list_model.dart
│   └── 18 more...

REPOSITORIES (11 impl files)
├── repositories/
│   ├── auth_repository_impl.dart
│   ├── task_repository_impl.dart  (966 lines)
│   └── 9 more...

REMOTE DATA SOURCES (11 files - Firebase)
├── datasources/remote/
│   ├── firebase_auth_remote_data_source.dart
│   ├── firebase_task_remote_data_source.dart (1,240 lines)
│   ├── firebase_list_remote_data_source.dart (937 lines)
│   └── 8 more...

LOCAL DATA SOURCES (11 schema + 11 impl - Isar)
├── datasources/local/isar/
│   ├── models/
│   │   ├── user.dart
│   │   ├── task.dart
│   │   └── 9 more...
│   └── sources/
│       ├── isar_auth_local_data_source.dart
│       ├── isar_task_local_data_source.dart
│       └── 9 more...

TOTAL: 55 files
```

---

## DOMAIN LAYER (143 Files)

```
lib/domain/

ENTITIES (11 files)
├── entities/
│   ├── user_entity.dart
│   ├── task_entity.dart
│   ├── list_entity.dart
│   └── 8 more...

REPOSITORIES - INTERFACES (11 files)
├── repositories/
│   ├── auth_repository.dart
│   ├── task_repository.dart
│   └── 9 more...

USE CASES (119 files - 118 use cases)
├── usecases/
│   └── [see above]

TOTAL: 143 files
```

---

## CORE & CONFIGURATION

```
lib/core/
├── constants/
│   └── app_constants.dart
├── errors/
│   ├── exceptions.dart
│   └── failures.dart
├── di/
│   └── injection_container.dart   (520 lines - DI setup)
├── utils/
│   └── logger.dart

lib/config/
├── theme/
│   ├── app_theme.dart
│   ├── app_colors.dart            (220+ colors)
│   ├── app_typography.dart        (18 text styles)
│   └── app_spacing.dart           (50+ spacing presets)

lib/presentation/routes/
├── app_router.dart                (go_router configuration)

TOTAL: 5 core files + 9 config files
```

---

## TESTING (8 Files)

```
test/

UNIT TESTS (2 files)
├── unit/usecases/
│   ├── create_task_usecase_test.dart
│   └── complete_task_usecase_test.dart

WIDGET TESTS (2 files)
├── widget/
│   ├── components/
│   │   └── app_button_test.dart
│   └── screens/
│       └── task_list_screen_test.dart

INTEGRATION TESTS (1 file)
├── integration/
│   └── task_management_flow_test.dart

FIXTURES & MOCKS (3 files)
├── fixtures/
│   └── mock_data.dart
├── mocks/
│   └── mock_task_repository.dart
└── helpers/
    └── test_helpers.dart

TOTAL: 8 files
```

---

## SUMMARY TABLE

| Category | Count | Files |
|----------|-------|-------|
| **Presentation - Screens** | 22 | 52 |
| **Presentation - Providers** | 90 domains | 90 |
| **Presentation - Components** | 60+ widgets | 10+ |
| **Domain - Use Cases** | 118 | 119 |
| **Domain - Entities** | 11 | 11 |
| **Domain - Repositories** | 11 | 11 |
| **Data - Models** | 21 | 21 |
| **Data - Remote Sources** | 11 | 11 |
| **Data - Local Sources** | 11 | 11 |
| **Data - Repositories Impl** | 11 | 11 |
| **Core & Config** | - | 14 |
| **Tests** | 8 | 8 |
| **TOTAL** | - | **365+ Dart files** |

---

## LARGEST FILES BY LINES

1. TaskNotifier .................... 1,255 lines (state management)
2. FirebaseTaskRemoteDataSource .... 1,240 lines (remote data)
3. FirebaseFocusSessionRemoteDS .... 1,083 lines (remote data)
4. FirebaseWorkspaceRemoteDataSource 1,070 lines (remote data)
5. TaskRepositoryImpl .............. 966 lines (repository)
6. FirebaseListRemoteDataSource .... 937 lines (remote data)
7. FirebaseHabitRemoteDataSource ... 910 lines (remote data)
8. TaskDetailScreen ............... 905 lines (UI screen)
9. TaskProviders .................. 859 lines (state)
10. WorkspaceRepositoryImpl ......... 853 lines (repository)

---

## FEATURE COMPLETENESS BY SCREEN

| Screen | Status | Features | Lines |
|--------|--------|----------|-------|
| Task Management | Complete | CRUD, filters, detail | 1,800+ |
| Calendar | Complete | 3 views, date nav | 1,200+ |
| Kanban | Complete | Columns, drag & drop | 1,500+ |
| Eisenhower | Complete | Matrix, focus mode | 1,400+ |
| Focus/Today | Complete | Smart suggestions | 1,300+ |
| Analytics | Complete | Statistics, charts | 1,450+ |
| Pomodoro | Complete | Timer, sessions | 2,050+ |
| Time Tracking | Complete | By task, charts | 2,250+ |
| Habit Tracker | Complete | Check-ins, streaks | 2,000+ |
| Goals | Complete | Progress, milestones | 1,500+ |
| Workspaces | Complete | Teams, roles | 990+ |
| Team Dashboard | Complete | Members, stats | 561 |
| Shared Lists | Complete | Permissions | 780+ |
| Templates | Complete | 5+ templates | 1,370+ |
| Automations | Complete | 6 presets | 1,350+ |
| Auth | Complete | Email + OAuth | 700+ |

