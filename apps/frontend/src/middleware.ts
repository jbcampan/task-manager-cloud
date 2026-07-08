import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

import { SESSION_COOKIE_NAME } from '@/lib/constants';

// Routes that require a session cookie to be accessed.
const PROTECTED_PATHS = ['/tasks', '/settings'];

// Routes that should redirect an already-authenticated user away
// (no reason to show the login form to someone already signed in).
const AUTH_PATHS = ['/login', '/register'];

export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;
  const hasSession = request.cookies.has(SESSION_COOKIE_NAME);

  const isProtectedPath = PROTECTED_PATHS.some((path) => pathname.startsWith(path));
  const isAuthPath = AUTH_PATHS.some((path) => pathname.startsWith(path));

  if (isProtectedPath && !hasSession) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  if (isAuthPath && hasSession) {
    return NextResponse.redirect(new URL('/tasks', request.url));
  }

  return NextResponse.next();
}

// Limits which routes trigger the middleware, skipping static assets and
// Next.js internals for performance - no point running this on every .js/.css request.
export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
};
