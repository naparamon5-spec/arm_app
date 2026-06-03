class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Ardent Resource Management';
  static const String appBarHeading = 'ARDENT RESOURCE MANAGEMENT';
  static const String appVersion = 'V2.4.0-ENTERPRISE';
  static const String appVersionStable =
      'Version 4.3.0-stable | ARDENT NETWORKS INC.';
  static const String companyName = 'ARDENT NETWORKS';
  static const String companyNameSuffix = 'NETWORKS';
  static const String enterpriseGateway = 'Enterprise Resource Gateway';

  // Login
  static const String corporateEmail = 'EMAIL';
  static const String password = 'PASSWORD';
  static const String rememberDevice = 'Remember Me';
  static const String secureLogin = 'LOGIN';
  static const String newToArdent = 'New to Ardent? ';
  static const String contactItAdmin = 'Contact IT Admin';
  static const String emailHint = 'you@ardentnetworks.com.ph';
  static const String passwordHint = '••••••••';

  // Dashboard
  static const String welcomePrefix = 'Welcome, ';
  static const String dashboardSubtitle =
      "Review and approve your team's quotes.";
  static const String forApproval = 'FOR APPROVAL';
  static const String quotesLabel = 'Quotes';
  static const String recentPendingApprovals = 'Recent Pending Approvals';

  // Approvals
  static const String pendingApprovals = 'APPROVALS';
  static const String searchHint = 'Search quotes, customers, or salesmen...';
  static const String filter = 'Filter';

  // Quote Detail
  static const String quoteApproval = 'QUOTE APPROVAL';
  static const String tabDetails = 'Details';
  static const String tabItems = 'Items';
  static const String tabIncidental = 'Incidental';
  static const String tabFiles = 'Files';

  // Section titles
  static const String sectionQuoteDetails = 'QUOTE DETAILS';
  static const String sectionCustomerEndUsers = 'CUSTOMER / END USERS';
  static const String sectionSalesmanPo = 'SALESMAN / PO';
  static const String sectionOthers = 'OTHERS';
  static const String sectionIncidentalDetails = 'INCIDENTAL DETAILS';

  // Detail labels
  static const String labelQuoteNumber = 'Quote Number';
  static const String labelProduct = 'Product';
  static const String labelQuoteType = 'Quote Type';
  static const String labelQuoteDate = 'Quote Date';
  static const String labelCustomer = 'Customer Name';
  static const String labelContactPerson = 'Contact Person';
  static const String labelTerm = 'Term';
  static const String labelEndUser = 'End User';
  static const String labelSuContactPerson = 'SU Contact Person';
  static const String labelSalesman = 'Salesman';
  static const String labelBdm = 'BDM';
  static const String labelPoNumber = 'PO Number';
  static const String labelPoDate = 'PO Date';
  static const String labelForex = 'FOREX';
  static const String labelAllowedUp = 'Allowed Up %';
  static const String labelReason = 'Reason';

  // Metrics
  static const String metricBilling = 'BILLING';
  static const String metricSelling = 'SELLING';
  static const String approvalsLabel = 'APPROVAL';
  static const String metricBuyPrice = 'BUY PRICE';
  static const String metricIncidental = 'INCIDENTAL';
  static const String metricGpAmt = 'GP AMOUNT';
  static const String metricGpPct = 'GP %';

  // Item fields
  static const String itemNumber = 'ITEM NUMBER';
  static const String itemSite = 'SITE';
  static const String itemQty = 'QUANTITY';
  static const String itemListGlp = 'UNIT GLP';
  static const String itemUnitPrice = 'UNIT PRICE';
  static const String itemExtPrice = 'EXTENDED PRICE';
  static const String itemFreight = 'FREIGHT';
  static const String itemVat = 'VAT';
  static const String itemCostUsd = 'COST (USD)';
  static const String itemCostPhp = 'COST (PHP)';

  // Incidental column headers
  static const String incidentalTypeDesc = 'TYPE & DESCRIPTION';
  static const String incidentalAmount = 'AMOUNT';

  // Actions
  static const String approve = 'APPROVE';
  static const String approveTitle = 'Approve Quote';
  static const String approveMessage =
      'Are you sure you want to approve this quote? This action cannot be undone.';
  static const String confirm = 'Confirm';
  static const String cancel = 'Cancel';

  // Profile
  static const String accountPreferences = 'ACCOUNT PREFERENCES';
  static const String changePassword = 'Change Password';
  static const String changePasswordSubtitle =
      'Update your security credentials';
  static const String signOut = 'SIGN OUT OF SYSTEM';

  // Nav
  static const String navDashboard = 'Dashboard';
  static const String navApprovals = 'Approvals';
  static const String navProfile = 'Profile';

  // Status
  static const String statusPending = 'PENDING';
  static const String statusApproved = 'APPROVED';
  static const String statusRejected = 'REJECTED';

  // Errors
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNoData = 'No data available.';
  static const String loginFailed =
      'Login failed. Please check your credentials.';
  static const String loginInvalidCredentials =
      'Invalid email or password. Please try again.';
  static const String mockEmail = 'mark.almueda@ardentnetworks.com.ph';
  static const String mockPassword = 'password';

  // Empty states
  static const String emptyApprovals = 'No pending approvals';
  static const String emptyApprovalsSubtitle =
      'All caught up! Check back later.';
  static const String emptyFiles = 'No files attached';
  static const String emptyItems = 'No items found';
}
