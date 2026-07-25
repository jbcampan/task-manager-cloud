import 'server-only';
import { cookies } from 'next/headers';

import { REMEMBER_ME_MAX_AGE_SECONDS, SESSION_COOKIE_NAME } from './constants';

/**
 * Sets the httpOnly session cookie carrying the backend JWT.
 * With rememberMe=false, omitting maxAge creates a session cookie that
 * expires when the browser closes rather than on a fixed date.
 *
 * `secure` is driven by COOKIE_SECURE rather than NODE_ENV: the ALB
 * currently serves HTTP only (no ACM certificate/domain yet), even in
 * the "production" NODE_ENV build, so a cookie marked Secure would never
 * be sent back by the browser. Set COOKIE_SECURE=true once HTTPS is in
 * front of the ALB.
 */
export function setSessionCookie(token: string, rememberMe: boolean): void {
  cookies().set(SESSION_COOKIE_NAME, token, {
    httpOnly: true,
    secure: process.env.COOKIE_SECURE === 'true',
    sameSite: 'lax',
    path: '/',
    ...(rememberMe ? { maxAge: REMEMBER_ME_MAX_AGE_SECONDS } : {}),
  });
}

/** Reads the raw JWT from the session cookie, if present. */
export function getSessionCookie(): string | undefined {
  return cookies().get(SESSION_COOKIE_NAME)?.value;
}

/** Clears the session cookie — used on logout. */
export function clearSessionCookie(): void {
  cookies().delete(SESSION_COOKIE_NAME);
}
