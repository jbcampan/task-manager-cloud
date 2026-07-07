import 'server-only';

import type { ApiErrorResponse, ApiSuccessResponse } from './types/auth';

const API_URL = process.env.API_URL ?? 'http://localhost:3001/api/v1';

/** Thrown by apiFetch on any non-2xx response, carrying the original HTTP status code. */
export class ApiError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

interface RequestOptions extends RequestInit {
  /** Bearer token to attach when calling a JWT-protected endpoint. */
  token?: string;
}

/**
 * Typed fetch wrapper around the NestJS API.
 * Server-only: this file must never be imported from a Client Component -
 * it may carry the JWT and must not end up in the client JS bundle.
 */
export async function apiFetch<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const { token, headers, ...rest } = options;

  const response = await fetch(`${API_URL}${path}`, {
    ...rest,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...headers,
    },
    // Auth and task data are always user-specific - never let fetch cache them.
    cache: 'no-store',
  });

  const body = await response.json().catch(() => null);

  if (!response.ok) {
    const errorBody = body as ApiErrorResponse | null;
    const message = Array.isArray(errorBody?.message)
      ? errorBody.message.join(', ')
      : (errorBody?.message ?? 'Unexpected API error');

    throw new ApiError(message, response.status);
  }

  return (body as ApiSuccessResponse<T>).data;
}
