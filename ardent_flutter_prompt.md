# 📱 Ardent Networks — Quote Approval Mobile App
## Flutter/Dart Development Prompt

---

## 🎯 Project Overview

Build a **Flutter/Dart** enterprise mobile application called **Ardent Resource Management** — a **Quote Approval System** for executive-level managers. The app allows executives to review, inspect, and approve or reject sales quotations submitted by their salespeople.

**Company Branding:**
- App Name: `Ardent Resource Management`
- Brand Colors: Dark navy/charcoal (`#1C2333`) for header, Red (`#D32F2F`) for accents/CTA, White background
- Logo: Letter "A" in red on dark square tile

---

## 🗂️ Project Architecture

Use a **clean, layered architecture** to keep the code maintainable and testable:

```
lib/
├── main.dart
├── app.dart                          # MaterialApp setup, theme, routing
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # All color constants
│   │   ├── app_text_styles.dart      # All text styles
│   │   ├── app_spacing.dart          # Padding/margin constants
│   │   └── app_strings.dart          # All string literals
│   ├── theme/
│   │   └── app_theme.dart            # ThemeData configuration
│   ├── utils/
│   │   ├── currency_formatter.dart   # Peso/USD formatting helpers
│   │   ├── date_formatter.dart       # Date display helpers
│   │   └── validators.dart           # Form field validators
│   └── extensions/
│       ├── string_extensions.dart
│       └── context_extensions.dart
│
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── quote_model.dart
│   │   ├── quote_item_model.dart
│   │   ├── incidental_model.dart
│   │   └── attachment_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── quote_repository.dart
│   └── mock/
│       └── mock_data.dart            # Mock/sample data for dev
│
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   │   └── login_screen.dart
│   │   ├── widgets/
│   │   │   ├── login_form.dart
│   │   │   └── branded_header.dart
│   │   └── controllers/
│   │       └── auth_controller.dart
│   │
│   ├── dashboard/
│   │   ├── screens/
│   │   │   └── dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── approval_summary_card.dart
│   │   │   └── recent_approval_tile.dart
│   │   └── controllers/
│   │       └── dashboard_controller.dart
│   │
│   ├── approvals/
│   │   ├── screens/
│   │   │   └── approvals_list_screen.dart
│   │   ├── widgets/
│   │   │   ├── approval_card.dart
│   │   │   ├── status_badge.dart
│   │   │   └── salesman_info_row.dart
│   │   └── controllers/
│   │       └── approvals_controller.dart
│   │
│   ├── quote_detail/
│   │   ├── screens/
│   │   │   └── quote_detail_screen.dart
│   │   ├── tabs/
│   │   │   ├── details_tab.dart
│   │   │   ├── items_tab.dart
│   │   │   ├── incidental_tab.dart
│   │   │   └── files_tab.dart
│   │   ├── widgets/
│   │   │   ├── quote_header_card.dart
│   │   │   ├── metric_tile.dart
│   │   │   ├── section_card.dart
│   │   │   ├── detail_row.dart
│   │   │   ├── quote_item_card.dart
│   │   │   ├── incidental_row.dart
│   │   │   ├── file_attachment_tile.dart
│   │   │   └── approve_bottom_bar.dart
│   │   └── controllers/
│   │       └── quote_detail_controller.dart
│   │
│   └── profile/
│       ├── screens/
│       │   └── profile_screen.dart
│       ├── widgets/
│       │   ├── profile_info_card.dart
│       │   └── preferences_tile.dart
│       └── controllers/
│           └── profile_controller.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_bottom_nav.dart       # Shared bottom navigation bar
│   │   ├── app_bar_widget.dart       # Shared custom AppBar
│   │   ├── loading_overlay.dart      # Full screen loading indicator
│   │   ├── error_widget.dart         # Error state widget
│   │   ├── empty_state_widget.dart   # Empty state widget
│   │   └── confirmation_dialog.dart  # Reusable confirm dialog
│   └── navigation/
│       └── app_router.dart           # Named route definitions
│
└── services/
    ├── auth_service.dart
    └── notification_service.dart
```

---

## 🎨 Core Design System

### `lib/core/constants/app_colors.dart`
```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFD32F2F);       // Red CTA / accent
  static const Color primaryDark = Color(0xFFB71C1C);   // Pressed red
  static const Color surface = Color(0xFF1C2333);        // Dark navy header/bar
  static const Color surfaceLight = Color(0xFF2A3347);   // Lighter navy

  // Background
  static const Color background = Color(0xFFF5F5F7);    // Light grey page bg
  static const Color cardBackground = Color(0xFFFFFFFF); // White cards

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Status
  static const Color pending = Color(0xFFFF9800);        // Orange badge
  static const Color approved = Color(0xFF4CAF50);       // Green badge
  static const Color rejected = Color(0xFFD32F2F);       // Red badge

  // UI
  static const Color divider = Color(0xFFE5E7EB);
  static const Color inputBorder = Color(0xFFD1D5DB);
  static const Color inputFill = Color(0xFFF9FAFB);
  static const Color shadow = Color(0x0D000000);

  // Financial
  static const Color positiveValue = Color(0xFF2E7D32);
  static const Color negativeValue = Color(0xFFC62828);
}
```

### `lib/core/constants/app_text_styles.dart`
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading3 = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static const TextStyle labelBold = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700,
    color: AppColors.textSecondary, letterSpacing: 0.8,
  );
  static const TextStyle metricValue = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle metricLabel = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  static const TextStyle quoteNumber = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w800,
    color: AppColors.textLight, letterSpacing: 0.5,
  );
  static const TextStyle buttonLabel = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.textLight, letterSpacing: 1.2,
  );
}
```

### `lib/core/constants/app_spacing.dart`
```dart
class AppSpacing {
  AppSpacing._();
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 10.0;
  static const double inputRadius = 10.0;
}
```

---

## 📦 Data Models

### `lib/data/models/user_model.dart`
```dart
class UserModel {
  final String id;
  final String fullName;
  final String role;
  final String email;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.role,
    required this.email,
  });
}
```

### `lib/data/models/quote_model.dart`
```dart
import 'quote_item_model.dart';
import 'incidental_model.dart';
import 'attachment_model.dart';

enum QuoteStatus { pending, approved, rejected }

class QuoteModel {
  final String quoteNumber;
  final String product;
  final String customer;
  final String contactPerson;
  final String endUser;
  final String customerPO;
  final String salesmanName;
  final String bdName;
  final String poNumber;
  final DateTime poDate;
  final DateTime quoteDate;
  final String quoteType;
  final String term;
  final String suContactPerson;
  final String destination;            // e.g. "FORTINET • LANDED-MANILA"
  final double billingAmount;
  final double buyPrice;
  final double incidentalAmount;
  final double gpAmount;
  final double gpPercentage;
  final double forex;
  final double allowedUpPercent;
  final String reason;
  final QuoteStatus status;
  final List<QuoteItemModel> items;
  final List<IncidentalModel> incidentals;
  final List<AttachmentModel> attachments;
  final String? salesmanNote;

  const QuoteModel({
    required this.quoteNumber,
    required this.product,
    required this.customer,
    required this.contactPerson,
    required this.endUser,
    required this.customerPO,
    required this.salesmanName,
    required this.bdName,
    required this.poNumber,
    required this.poDate,
    required this.quoteDate,
    required this.quoteType,
    required this.term,
    required this.suContactPerson,
    required this.destination,
    required this.billingAmount,
    required this.buyPrice,
    required this.incidentalAmount,
    required this.gpAmount,
    required this.gpPercentage,
    required this.forex,
    required this.allowedUpPercent,
    required this.reason,
    required this.status,
    required this.items,
    required this.incidentals,
    required this.attachments,
    this.salesmanNote,
  });
}
```

### `lib/data/models/quote_item_model.dart`
```dart
class QuoteItemModel {
  final String lineType;        // e.g. "DIRECT"
  final String partNumber;
  final String description;
  final String itemNumber;
  final String site;
  final int quantity;
  final double listPrice;
  final double unitPrice;
  final double extendedCost;
  final double rebate;
  final double spu;
  final double costUsd;
  final double costPhp;
  final String standard;        // e.g. "STANDARD" or "DIRECT"

  const QuoteItemModel({
    required this.lineType,
    required this.partNumber,
    required this.description,
    required this.itemNumber,
    required this.site,
    required this.quantity,
    required this.listPrice,
    required this.unitPrice,
    required this.extendedCost,
    required this.rebate,
    required this.spu,
    required this.costUsd,
    required this.costPhp,
    required this.standard,
  });
}
```

### `lib/data/models/incidental_model.dart`
```dart
class IncidentalModel {
  final String type;            // e.g. "Logistics"
  final String description;    // e.g. "Shipping and handling fees..."
  final double amount;

  const IncidentalModel({
    required this.type,
    required this.description,
    required this.amount,
  });
}
```

### `lib/data/models/attachment_model.dart`
```dart
class AttachmentModel {
  final String fileName;
  final String fileType;        // e.g. "pdf", "xlsx"
  final double fileSizeKb;
  final DateTime uploadedDate;
  final String url;

  const AttachmentModel({
    required this.fileName,
    required this.fileType,
    required this.fileSizeKb,
    required this.uploadedDate,
    required this.url,
  });
}
```

---

## 🔐 Screen 1 — Login

**File:** `lib/features/auth/screens/login_screen.dart`

**UI Requirements:**
- Light grey dotted/grid background (`#F5F5F7`)
- Centered logo: dark square rounded tile with red "A" letter
- Title: **"ARDENT NETWORKS"** (bold, dark) with **"NETWORKS"** in red
- Subtitle: "Enterprise Resource Gateway" in grey
- White rounded card form container with:
  - `CORPORATE EMAIL` label + email TextField with mail icon prefix
  - `PASSWORD` label + password TextField with lock icon, eye toggle, "Forgot Password?" red link
  - Checkbox: "Remember this device for 30 days"
  - **"SECURE LOGIN →"** button: full-width, red background, white bold text
  - Divider + "New to Ardent? **Contact IT Admin**" in grey/red
- Version tag at bottom: `V2.4.0-ENTERPRISE`

**Validation (in `lib/core/utils/validators.dart`):**
```dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters required';
    return null;
  }
}
```

**Widgets to compose:**
- `BrandedHeader` — logo + title + subtitle
- `LoginForm` — form with fields, validators, submit button
- Each TextField wrapped in a reusable `AppTextField` widget

---

## 🏠 Screen 2 — Dashboard

**File:** `lib/features/dashboard/screens/dashboard_screen.dart`

**UI Requirements:**
- Dark navy `AppBar` with company logo left, menu right
- Body: light grey background
- Greeting: `"Welcome, Nathaniel"` heading, subtitle `"Review and approve your team's quotes."`
- **Red summary card** (`ApprovalSummaryCard`):
  - "FOR APPROVAL" label
  - Large bold count: `"128 Quotes"`
- Section: `"Recent Pending Approvals"` heading
- Scrollable list of `RecentApprovalTile` items showing:
  - Document icon, Quote number (`#QT-88291`), time ago (`2h ago`), description

**Widgets:**
```dart
// ApprovalSummaryCard
class ApprovalSummaryCard extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  // Red card with large count + label
}

// RecentApprovalTile
class RecentApprovalTile extends StatelessWidget {
  final String quoteNumber;
  final String description;
  final String timeAgo;
  final VoidCallback onTap;
  // List tile with document icon, quote number, time, chevron
}
```

---

## 📋 Screen 3 — Approvals List

**File:** `lib/features/approvals/screens/approvals_list_screen.dart`

**UI Requirements:**
- Search bar at top: "Search quotes, customers, or salesmen..."
- `"PENDING APPROVALS"` section header + Filter button
- Scrollable list of `ApprovalCard` widgets

**`ApprovalCard` widget** — each card shows:
- Quote number (`#352437`) + `PENDING` red badge (top right)
- Product name (`Fortinet`), Date
- Customer name, BD Group (e.g., `Enterprise`)
- Salesman avatar icon + name (e.g., `Robert Lee`)
- Italicized salesman note in grey (e.g., *"Special project discount requested..."*)
- Chevron right

**`StatusBadge` widget:**
```dart
class StatusBadge extends StatelessWidget {
  final QuoteStatus status;
  // Returns colored pill: PENDING=orange, APPROVED=green, REJECTED=red
}
```

**`SalesmanInfoRow` widget:**
```dart
class SalesmanInfoRow extends StatelessWidget {
  final String salesmanName;
  // Shows avatar circle + name inline
}
```

---

## 📄 Screen 4 — Quote Approval Detail

**File:** `lib/features/quote_detail/screens/quote_detail_screen.dart`

This is the most complex screen. It uses a `DefaultTabController` with **4 tabs**.

### Header (always visible above tabs)

**`QuoteHeaderCard` widget:**
- Dark navy top bar: `"QUOTE APPROVAL"` label + `#352437` number (bold white)
- Three-dot menu icon
- Route tag: `"● FORTINET • LANDED-MANILA"` (red dot + grey text)
- Date right-aligned

**Metrics Row** — 3 columns (`MetricTile` widget each):
| Left | Center | Right |
|------|--------|-------|
| BILLING: `$1,309.52` / ₱82,500.00 | BUY PRICE: `$1,100.00` / ₱68,300.00 | INCIDENTAL: `$50.00` / ₱3,120.00 |

**Second Row** — 2 columns:
| Left | Right |
|------|-------|
| GP AMT: `$159.52` / ₱15,340.00 | GP %: `12.18%` (colored green if positive) |

**`MetricTile` widget:**
```dart
class MetricTile extends StatelessWidget {
  final String label;
  final String primaryValue;
  final String? secondaryValue;    // PHP equivalent
  final Color? valueColor;
  // Compact tile showing label on top, bold value, grey PHP value below
}
```

### Tab Bar
```
[ Details ] [ Items 4 ] [ Incidental ] [ Files 3 ]
```
Red underline indicator, dark text for active, grey for inactive.

---

### Tab 1 — Details (`lib/features/quote_detail/tabs/details_tab.dart`)

Scrollable content with `SectionCard` groups:

**QUOTE DETAILS section:**
- Quote Number, Product (2 columns)
- Quote Type, Quote Date (2 columns)

**CUSTOMER / END USERS section:**
- Customer, Contact Person (2 columns)
- Term, End User (2 columns)
- SU Contact Person (full width)

**SALESMAN / PO section:**
- Salesman, BDM (2 columns)
- PO Number, PO Date (2 columns)

**OTHERS section:**
- FOREX, Allowed Up % (2 columns)
- Reason (full width, italic)

**Reusable widgets:**
```dart
// SectionCard — labelled white card with grey header
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
}

// DetailRow — label/value pair, optionally in a 2-col grid
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
}
```

---

### Tab 2 — Items (`lib/features/quote_detail/tabs/items_tab.dart`)

**"QUOTE ITEMS (4)"** header count

For each item, a `QuoteItemCard` widget:
- Line type badge (e.g. `DIRECT` in dark) + part number
- Description (bold)
- Grid of fields: ITEM NUMBER, SITE, QUANTITY, LIST PRICE, UNIT PRICE, EXTENDED COST, REBATE, SPU, COST (USD), COST (PHP)
- Bottom row: `STANDARD` tag + part number

```dart
class QuoteItemCard extends StatelessWidget {
  final QuoteItemModel item;
  // Expandable card with all item fields in a 2-col grid
}
```

---

### Tab 3 — Incidental (`lib/features/quote_detail/tabs/incidental_tab.dart`)

**"INCIDENTAL DETAILS"** header

Column headers: `TYPE & DESCRIPTION` | `AMOUNT`

List of `IncidentalRow` widgets:
```dart
class IncidentalRow extends StatelessWidget {
  final IncidentalModel incidental;
  // Shows type bold + description grey on left, dollar amount on right
}
```

Sample incidentals from screenshots:
- Logistics — Shipping and handling fees for Fortinet hardware — $50.00
- Documentation — Customs and certification processing — $25.00
- Insurance — Comprehensive transit insurance for hardware — $15.00
- Storage — Warehouse holding fees for 5 days — $10.00
- Inspection — Technical quality assurance check — $20.00

---

### Tab 4 — Files (`lib/features/quote_detail/tabs/files_tab.dart`)

List of `FileAttachmentTile` widgets:
```dart
class FileAttachmentTile extends StatelessWidget {
  final AttachmentModel attachment;
  // Red file icon + filename + file size + date + chevron arrow
}
```

Sample files:
- `Quote_352437.pdf` — 312 KB — May 15, 2026
- `Customer_PO_draft.pdf` — 88 KB — May 16, 2026
- `FORTINET_pricing.xlsx` — 54 KB — May 12, 2026

---

### Bottom Approve Bar (`lib/features/quote_detail/widgets/approve_bottom_bar.dart`)

Always visible at bottom:
```dart
class ApproveBottomBar extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onSettings;
  // Row: Red "✓ APPROVE" button (flex) + grey settings gear icon button
}
```

**On approve tap → show `ConfirmationDialog`:**
```dart
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  // Standard Material dialog with confirm/cancel buttons
}
```

---

## 👤 Screen 5 — Profile

**File:** `lib/features/profile/screens/profile_screen.dart`

**UI Requirements:**

**`ProfileInfoCard` widget:**
- Avatar placeholder (large circle, grey)
- Full name: `"Nathaniel S. Reyes"` (bold)
- Role: `"REGIONAL OPERATIONS MANAGER"` (red, uppercase, small)
- Email with mail icon: `nathan.reyes@ardentl.com.ph`

**ACCOUNT PREFERENCES section:**
- `PreferencesTile` for **Change Password**: lock icon + title + subtitle "Update your security credentials" + chevron

**"SIGN OUT OF SYSTEM"** button: full-width, outlined red border, red text, exit icon

**Version tag:** `Version 4.3.0-stable | ARDENT NETWORKS INC.`

---

## 🧭 Navigation

### Bottom Navigation Bar (`lib/shared/widgets/app_bottom_nav.dart`)

3 tabs:
```
[ Dashboard ]  [ Approvals ]  [ Profile ]
     🏠              📋           👤
```

- Active tab: red icon + red label
- Inactive: grey icon + grey label
- Dark navy background, subtle top border

```dart
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
}
```

### Routing (`lib/shared/navigation/app_router.dart`)

```dart
class AppRouter {
  static const String login = '/';
  static const String dashboard = '/dashboard';
  static const String approvals = '/approvals';
  static const String quoteDetail = '/quote-detail';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login: return MaterialPageRoute(builder: (_) => LoginScreen());
      case dashboard: return MaterialPageRoute(builder: (_) => DashboardScreen());
      case approvals: return MaterialPageRoute(builder: (_) => ApprovalsListScreen());
      case quoteDetail:
        final quote = settings.arguments as QuoteModel;
        return MaterialPageRoute(builder: (_) => QuoteDetailScreen(quote: quote));
      case profile: return MaterialPageRoute(builder: (_) => ProfileScreen());
      default: return MaterialPageRoute(builder: (_) => LoginScreen());
    }
  }
}
```

---

## 🔧 State Management

Use **`setState` + simple controllers** (no heavy framework needed for MVP):

```dart
// Example: AuthController
class AuthController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login({
    required String email,
    required String password,
    required VoidCallback onSuccess,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // simulate API call
      // TODO: Replace with real auth service
      if (email.isNotEmpty && password.isNotEmpty) {
        onSuccess();
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please check your credentials.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

Use `ChangeNotifierProvider` (provider package) for each feature controller.

---

## 📦 Required Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1           # State management
  intl: ^0.19.0              # Currency & date formatting
  url_launcher: ^6.2.5       # Open file attachments
  cached_network_image: ^3.3.1  # Profile images
  shimmer: ^3.0.0            # Loading skeleton placeholders
  flutter_svg: ^2.0.10       # SVG icons if needed

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## ✅ Validation Rules

All in `lib/core/utils/validators.dart`:

| Field | Rule |
|-------|------|
| Corporate Email | Required, valid email format (`@domain.com`) |
| Password | Required, min 6 characters |
| Approve Action | Show confirmation dialog before submitting |
| Filter (Approvals) | Non-blocking, no validation needed |

---

## 💰 Currency Formatting

**`lib/core/utils/currency_formatter.dart`:**
```dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _usd = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _php = NumberFormat.currency(symbol: '₱', decimalDigits: 2);
  static final _percent = NumberFormat.decimalPercentPattern(decimalDigits: 2);

  static String usd(double amount) => _usd.format(amount);
  static String php(double amount) => _php.format(amount);
  static String percent(double value) => '${value.toStringAsFixed(2)} %';
}
```

---

## 📅 Date Formatting

**`lib/core/utils/date_formatter.dart`:**
```dart
import 'package:intl/intl.dart';

class DateFormatter {
  static final _display = DateFormat('MMM dd, yyyy');
  static final _short = DateFormat('MMM dd');

  static String display(DateTime date) => _display.format(date);
  static String short(DateTime date) => _short.format(date);
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return 'Oct ${date.day}';
  }
}
```

---

## 🎭 Mock Data (`lib/data/mock/mock_data.dart`)

Populate with sample data matching the screenshots:

```dart
class MockData {
  static final currentUser = UserModel(
    id: '001',
    fullName: 'Nathaniel S. Reyes',
    role: 'Regional Operations Manager',
    email: 'nathan.reyes@ardentl.com.ph',
  );

  static final List<QuoteModel> pendingQuotes = [
    QuoteModel(
      quoteNumber: '#352437',
      product: 'Fortinet',
      customer: 'Tech Solutions Inc.',
      contactPerson: 'John Doe',
      endUser: 'Global Corp',
      customerPO: 'Net 30',
      salesmanName: 'Robert Lee',
      bdName: 'Sarah Chen',
      poNumber: 'PO-88219',
      poDate: DateTime(2026, 5, 14),
      quoteDate: DateTime(2026, 5, 15),
      quoteType: 'Standard Quote',
      term: 'Net 30',
      suContactPerson: 'Jane Smith',
      destination: 'FORTINET • LANDED-MANILA',
      billingAmount: 1309.52,
      buyPrice: 1100.00,
      incidentalAmount: 50.00,
      gpAmount: 159.52,
      gpPercentage: 12.18,
      forex: 56.45,
      allowedUpPercent: 10.00,
      reason: 'Special project discount for long-term partnership.',
      status: QuoteStatus.pending,
      salesmanNote: 'Special project discount requested for Infrastructure Phase 2.',
      items: [ /* QuoteItemModel list */ ],
      incidentals: [
        IncidentalModel(type: 'Logistics', description: 'Shipping and handling fees for Fortinet hardware', amount: 50.00),
        IncidentalModel(type: 'Documentation', description: 'Customs and certification processing', amount: 25.00),
        IncidentalModel(type: 'Insurance', description: 'Comprehensive transit insurance for hardware', amount: 15.00),
        IncidentalModel(type: 'Storage', description: 'Warehouse holding fees for 5 days', amount: 10.00),
        IncidentalModel(type: 'Inspection', description: 'Technical quality assurance check', amount: 20.00),
      ],
      attachments: [
        AttachmentModel(fileName: 'Quote_352437.pdf', fileType: 'pdf', fileSizeKb: 312, uploadedDate: DateTime(2026,5,15), url: ''),
        AttachmentModel(fileName: 'Customer_PO_draft.pdf', fileType: 'pdf', fileSizeKb: 88, uploadedDate: DateTime(2026,5,16), url: ''),
        AttachmentModel(fileName: 'FORTINET_pricing.xlsx', fileType: 'xlsx', fileSizeKb: 54, uploadedDate: DateTime(2026,5,12), url: ''),
      ],
    ),
    // Add #352445 (Cisco Systems / Global Dynamics / Sarah Connor / Public Sector)
    // Add #352451 (Veeam Software / Nova Retail / James Smith / Commercial)
  ];
}
```

---

## 🏗️ App Entry Point

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';
import 'features/approvals/controllers/approvals_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => ApprovalsController()),
      ],
      child: const ArdentApp(),
    ),
  );
}
```

### `lib/app.dart`
```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'shared/navigation/app_router.dart';

class ArdentApp extends StatelessWidget {
  const ArdentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ardent Resource Management',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.login,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
```

---

## 🧪 Debuggability Checklist

- [ ] Each widget file has **one responsibility** (no god widgets)
- [ ] All hardcoded strings live in `app_strings.dart`
- [ ] All colors referenced via `AppColors.*` — never hardcoded hex
- [ ] All spacing via `AppSpacing.*` — never magic numbers
- [ ] Controllers use `ChangeNotifier` — state is never in UI layers
- [ ] `print()` replaced with a structured logger (or `debugPrint()` at minimum)
- [ ] Error states handled in every data-loading widget
- [ ] Forms use `GlobalKey<FormState>` and `autovalidateMode`
- [ ] Every `async` operation wrapped in `try/catch`
- [ ] Mock data isolated in `mock_data.dart` — easy to swap for real API

---

## 📐 Shared Reusable Widgets Summary

| Widget | File | Purpose |
|--------|------|---------|
| `AppBottomNav` | shared/widgets/ | 3-tab bottom navigation |
| `AppBarWidget` | shared/widgets/ | Dark navy app bar |
| `LoadingOverlay` | shared/widgets/ | Full-screen loading spinner |
| `ErrorWidget` | shared/widgets/ | Centered error message + retry |
| `EmptyStateWidget` | shared/widgets/ | Empty list illustration + message |
| `ConfirmationDialog` | shared/widgets/ | Approve/Reject confirm modal |
| `AppTextField` | shared/widgets/ | Styled input with label + icon |
| `StatusBadge` | features/approvals/ | Colored status pill |
| `MetricTile` | features/quote_detail/ | USD + PHP value display tile |
| `SectionCard` | features/quote_detail/ | Grouped detail card with header |
| `DetailRow` | features/quote_detail/ | Label/value row with 2-col support |
| `QuoteItemCard` | features/quote_detail/ | Expandable item card |
| `IncidentalRow` | features/quote_detail/ | Type + amount row |
| `FileAttachmentTile` | features/quote_detail/ | File icon + name + meta + arrow |
| `ApproveBottomBar` | features/quote_detail/ | Approve CTA + settings icon |

---

*Generated for: Ardent Networks Quote Approval App — Flutter/Dart*
*Version: 1.0 | Architecture: Feature-first, Clean Layers*
