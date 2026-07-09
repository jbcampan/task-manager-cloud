import 'server-only';
import { redirect } from 'next/navigation';

import { ApiError } from '@/lib/api';
import { clearSessionCookie, getSessionCookie } from '@/lib/auth';

/**
 * Reads the session token, redirecting to /login if absent.
 * Defense in depth: the middleware already blocks unauthenticated access to
 * /tasks and /settings, but Server Components/Actions can't assume it always ran first.
 */
export function requireSessionToken(): string {
  const token = getSessionCookie();
  if (!token) {
    redirect('/login');
  }
  return token;
}

/**
 * Runs an authenticated API call and handles a stale/expired token gracefully:
 * on a 401 from the backend, clears the now-invalid cookie and redirects to
 * /login instead of leaving the user on a broken page.
 */
export async function withSession<T>(fn: (token: string) => Promise<T>): Promise<T> {
  const token = requireSessionToken();

  try {
    return await fn(token);
  } catch (error) {
    if (error instanceof ApiError && error.statusCode === 401) {
      clearSessionCookie();
      redirect('/login');
    }
    throw error;
  }
}
