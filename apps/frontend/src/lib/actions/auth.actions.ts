'use server';

import { redirect } from 'next/navigation';

import { apiFetch, ApiError } from '@/lib/api';
import { clearSessionCookie, setSessionCookie } from '@/lib/auth';
import type { AuthTokenPayload, LoginPayload, RegisterPayload } from '@/lib/types/auth';

interface ActionResult {
  error?: string;
}

/**
 * Server Action: authenticates against POST /auth/login and sets the
 * session cookie. Runs entirely on the Next.js server
 */
export async function loginAction(
  payload: LoginPayload,
  rememberMe: boolean,
): Promise<ActionResult> {
  try {
    const { accessToken } = await apiFetch<AuthTokenPayload>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(payload),
    });

    setSessionCookie(accessToken, rememberMe);
  } catch (error) {
    if (error instanceof ApiError) {
      // 401: invalid credentials - the only expected failure from AuthService.login().
      return { error: error.statusCode === 401 ? 'Invalid email or password.' : error.message };
    }
    return { error: 'Unable to reach the server. Please try again.' };
  }

  // Must run outside the try/catch above
  redirect('/tasks');
}

/** Server Action: registers a new account via POST /auth/register and signs the user in. */
export async function registerAction(
  payload: RegisterPayload,
  rememberMe: boolean,
): Promise<ActionResult> {
  try {
    const { accessToken } = await apiFetch<AuthTokenPayload>('/auth/register', {
      method: 'POST',
      body: JSON.stringify(payload),
    });

    setSessionCookie(accessToken, rememberMe);
  } catch (error) {
    if (error instanceof ApiError) {
      // 409: email already in use - documented on AuthController.register().
      return {
        error: error.statusCode === 409 ? 'This email is already registered.' : error.message,
      };
    }
    return { error: 'Unable to reach the server. Please try again.' };
  }

  redirect('/tasks');
}

/** Server Action: clears the session cookie and sends the user back to /login. */
export async function logoutAction(): Promise<void> {
  clearSessionCookie();
  redirect('/login');
}
