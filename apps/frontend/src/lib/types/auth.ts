/** Uniform success envelope returned by every backend endpoint (TransformResponseInterceptor). */
export interface ApiSuccessResponse<T> {
  data: T;
  timestamp: string;
}

/** Uniform error envelope returned by the backend's HttpExceptionFilter. */
export interface ApiErrorResponse {
  statusCode: number;
  message: string | string[];
  timestamp: string;
  path: string;
}

/** Shape of the payload returned by POST /auth/login and /auth/register. */
export interface AuthTokenPayload {
  accessToken: string;
  tokenType: string;
  expiresIn: number;
}

/** Mirrors the backend LoginDto — kept in sync manually since frontend and backend are separate apps. */
export interface LoginPayload {
  email: string;
  password: string;
}

/** Mirrors the backend RegisterDto. */
export interface RegisterPayload {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
}
