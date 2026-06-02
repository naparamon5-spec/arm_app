# Quoatation Approval API — Endpoint Reference

Base URL: `https://quote-approval-api.ardentnetworks.com.ph`

All protected routes require:
```
Authorization: Bearer <access_token>
```

---

## Auth — `/api/auth`

### POST /api/auth/login
Public. Exchange credentials for tokens.

**Request body**
```json
{
  "user_id": "string",
  "password": "string"
}
```

**200 OK**
```json
{
  "access_token": "string",
  "refresh_token": "string",
  "token_type": "Bearer",
  "expires_in": "8h"
}
```

**Errors**
| Status | Error |
|--------|-------|
| 400 | `user_id and password are required` |
| 401 | `Invalid credentials` |
| 500 | `Login failed` |

---

### POST /api/auth/refresh
Public. Issue a new access token using a valid refresh token.

**Request body**
```json
{
  "refresh_token": "string"
}
```

**200 OK**
```json
{
  "access_token": "string",
  "token_type": "Bearer",
  "expires_in": "8h"
}
```

**Errors**
| Status | Error |
|--------|-------|
| 400 | `refresh_token is required` |
| 401 | `Token has been revoked` |
| 401 | `Refresh token expired` |
| 401 | `Invalid refresh token` |

---

### POST /api/auth/logout
Public. Revoke the refresh token.

**Request body**
```json
{
  "refresh_token": "string"
}
```

**200 OK**
```json
{
  "message": "Logged out successfully"
}
```

---

### POST /api/auth/change-password
Protected. Change the authenticated user's password. Updates `PASSWORD`, `EPASSWORD`, and `ONLINE_PASS` columns on the `USERS` table.

**Request body**
```json
{
  "currentPassword": "string",
  "NewPassword": "string"
}
```

**200 OK**
```json
{
  "message": "Password changed successfully"
}
```

**Errors**
| Status | Error |
|--------|-------|
| 400 | `currentPassword and NewPassword are required` |
| 401 | `Incorrect current password` |
| 404 | `User not found` |
| 500 | `Password change failed` |

---

## Quote Approvals — `/api/quote-approvals`

All routes require a valid `Authorization: Bearer <access_token>` header. Row-level visibility is enforced per user role:
- **Executive** (`privilege = 'S'`) — sees all quotes.
- **BU group users** — scoped to their business unit (`bu_group`).
- **All others** — scoped to their assigned product groups (`entry_flag`).

---

### GET /api/quote-approvals
Paginated list of quotes pending approval from `vw_QuoteForApproval`.

**Query parameters**
| Param | Type | Description |
|-------|------|-------------|
| `page` | number | Page number (default: `1`) |
| `pageSize` | number | Records per page (default: `20`) |
| `date_from` | string | Filter by `quote_date` ≥ this value (e.g. `2025-01-01`) |
| `date_to` | string | Filter by `quote_date` ≤ this value |
| `quote_number` | string | Exact match on `quote_number` |
| `product_group_name` | string | Partial match (`LIKE %value%`) |
| `customer_name` | string | Partial match (`LIKE %value%`) |

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals?page=1&pageSize=20&date_from=2025-01-01&date_to=2025-12-31
```

**200 OK**
```json
{
  "data": [ /* vw_QuoteForApproval rows */ ],
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "totalPages": 5
}
```

**Errors**
| Status | Error |
|--------|-------|
| 500 | `Failed to retrieve approvals` |

---

### GET /api/quote-approvals/recent
Returns the 5 most recent quotes from `vw_QuoteForApproval`, ordered by `quote_date DESC`. Applies the same row-level access control as `GET /`.

**No query parameters.**

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals/recent
```

**200 OK**
```json
{
  "data": [ /* up to 5 vw_QuoteForApproval rows */ ]
}
```

**Errors**
| Status | Error |
|--------|-------|
| 500 | `Failed to retrieve recent approvals` |

---

### GET /api/quote-approvals/:quote_number
Full quote header with all associations (details, TPC, CPO files, customer, end-user, salesman, quote type, product group).

**URL parameter**
| Param | Description |
|-------|-------------|
| `quote_number` | Quote number (e.g. `Q-2025-00123`) |

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals/Q-2025-00123
```

**200 OK** — `quotation_header` row with nested associations.

**Errors**
| Status | Error |
|--------|-------|
| 404 | `Quote not found` |
| 500 | `Failed to retrieve quote` |

---

### GET /api/quote-approvals/:quote_number/details
Line items from `quotation_detail`, ordered by `trans_no ASC`.

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals/Q-2025-00123/details
```

**200 OK** — Array of `quotation_detail` rows.

**Errors**
| Status | Error |
|--------|-------|
| 500 | `Failed to retrieve quote details` |

---

### GET /api/quote-approvals/:quote_number/tpc
TPC entries from `quote_tpc`, ordered by `trans_no ASC`.

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals/Q-2025-00123/tpc
```

**200 OK** — Array of `quote_tpc` rows.

**Errors**
| Status | Error |
|--------|-------|
| 500 | `Failed to retrieve quote TPC` |

---

### GET /api/quote-approvals/:quote_number/cpo-files
CPO file attachments from `cpo_file`.

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals/Q-2025-00123/cpo-files
```

**200 OK** — Array of `cpo_file` rows.

**Errors**
| Status | Error |
|--------|-------|
| 500 | `Failed to retrieve CPO files` |

---

### PUT /api/quote-approvals/:quote_number/approve
Runs the approval rules engine. Stamps the appropriate columns on `quotation_header` based on the user's role and the quote's current `checking` state.

**URL parameter**
| Param | Description |
|-------|-------------|
| `quote_number` | Quote number to approve |

**Request body**
```json
{
  "type": "BU",
  "remarks": "string"
}
```

| Field | Required | Description |
|-------|----------|-------------|
| `type` | No | Pass `"BU"` to trigger BU-approval path |
| `remarks` | Conditional | Required when `checking = 'NEGATIVE GP'` |

**Example**
```
PUT https://quote-approval-api.ardentnetworks.com.ph/api/quote-approvals/Q-2025-00123/approve
```

**200 OK**
```json
{
  "message": "QT#Q-2025-00123 Approved"
}
```

**Errors**
| Status | Error |
|--------|-------|
| 400 | `Approver's remarks are required` |
| 400 | `Only BU approver can approve this quote` |
| 400 | `Already BU Approved` |
| 400 | `This quote does not require BU approval.` |
| 400 | `This quote require BU approval.` |
| 400 | `Only Executive or BU can approve <checking>` |
| 400 | `This quotation requires executive approval` |
| 404 | `Quote not found` |
| 500 | `Failed to approve quote` |

---

## Miscellaneous

### GET /health
Public. Liveness / info check.

**Example**
```
GET https://quote-approval-api.ardentnetworks.com.ph/health
```

**200 OK** — JSON with server status and basic info.
