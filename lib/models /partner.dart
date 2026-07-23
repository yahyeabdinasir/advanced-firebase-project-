





// User enters Email + Password
// │
// ▼
// Authenticate with Odoo 17
// │
// ▼
// Search hr.employee by work email
// │
// Employee exists?
// │        │
// No       Yes
// │        │
// Show "Access   ▼
// Denied"   Check Firebase Auth
// │
// ┌───────┴────────┐
// │                │
// User exists      User doesn't exist
// │                │
// ▼                ▼
// Firebase Login   Create Firebase User
// │                │
// └────────┬───────┘
// ▼
// Home