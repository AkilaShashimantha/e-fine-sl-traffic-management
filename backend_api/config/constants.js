// ─────────────────────────────────────────────
// config/constants.js
// Central constants file for e-Fine SL backend
// ─────────────────────────────────────────────

// ── APP ──────────────────────────────────────
const APP = {
  NAME:        'e-Fine SL',
  PORT:        process.env.PORT || 5000,
  ENV:         process.env.NODE_ENV || 'development',
  API_PREFIX:  '/api/v1',
};

// ── USER ROLES ────────────────────────────────
const ROLES = {
  ADMIN:  'admin',
  SUPER_ADMIN: 'super_admin',
  ADMIN_OFFICER: 'admin_officer',
  FINANCE_OFFICER: 'finance_officer',
  POLICE: 'police',
  OFFICER: 'officer',
  DRIVER: 'driver',
};

// ── LICENSE STATUS ────────────────────────────
const LICENSE_STATUS = {
  ACTIVE:    'ACTIVE',
  SUSPENDED: 'SUSPENDED',
};

// ── DEMERIT POINTS ────────────────────────────
const DEMERIT = {
  DEFAULT_POINTS:    100,
  SUSPENSION_THRESHOLD: 0,
  MONTHLY_RESTORE:   50,
  OFFENSE_LEVELS: {
    MINOR:    10,
    MODERATE: 20,
    SERIOUS:  40,
    CRITICAL: 100,
  },
};

// ── AUTH & SECURITY ───────────────────────────
const AUTH = {
  JWT_EXPIRY:        '7d',
  BCRYPT_SALT_ROUNDS: 10,
  OTP_EXPIRY_MINUTES: 5,
  TOKEN_PREFIX:      'Bearer',
  MAX_LOGIN_ATTEMPTS: 5,
};

// ── PAYMENT ───────────────────────────────────
const PAYMENT = {
  CURRENCY:        'LKR',
  STATUS: {
    PAID:    'PAID',
    UNPAID:  'UNPAID',
    PENDING: 'PENDING',
  },
  PAYHARE_SANDBOX_URL: 'https://sandbox.payhere.lk/pay/checkout',
};

// ── HTTP STATUS CODES ─────────────────────────
const HTTP = {
  OK:           200,
  CREATED:      201,
  BAD_REQUEST:  400,
  UNAUTHORIZED: 401,
  FORBIDDEN:    403,
  NOT_FOUND:    404,
  SERVER_ERROR: 500,
};

// ── PAGINATION ────────────────────────────────
const PAGINATION = {
  DEFAULT_PAGE:  1,
  DEFAULT_LIMIT: 10,
};

// ── EMAIL ─────────────────────────────────────
const EMAIL = {
  FROM_NAME:    'e-Fine SL Traffic Authority',
  SUBJECTS: {
    LICENSE_ACTIVATED: '✅ Your Driving License Has Been Activated — e-Fine SL',
    LICENSE_SUSPENDED: '🚫 Your Driving License Has Been Suspended — e-Fine SL',
  },
};

// ── CRON JOBS ─────────────────────────────────
const CRON = {
  MONTHLY_RESET: '0 0 1 * *',
};

// ── LOCALIZATION ──────────────────────────────
const LOCALE = {
  DEFAULT:   'en',
  SUPPORTED: ['en', 'si'],
};

module.exports = {
  APP,
  ROLES,
  LICENSE_STATUS,
  DEMERIT,
  AUTH,
  PAYMENT,
  HTTP,
  PAGINATION,
  EMAIL,
  CRON,
  LOCALE,
};
