/**
 * Name of the httpOnly cookie storing the JWT issued by the NestJS backend.
 * Centralized here so Server Actions, middleware and cookie helpers all
 * reference the same value.
 */
export const SESSION_COOKIE_NAME = 'session_token';

/** Cookie lifetime in seconds when "Remember me" is checked — 30 days. */
export const REMEMBER_ME_MAX_AGE_SECONDS = 60 * 60 * 24 * 30;
