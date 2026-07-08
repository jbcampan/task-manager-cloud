import { z } from 'zod';

// Presence check only — password complexity is validated by the backend at
// registration time, not re-enforced here on every login attempt.
export const loginSchema = z.object({
  email: z.email('Enter a valid email address.'),
  password: z.string().min(1, 'Password is required.'),
});

export type LoginFormValues = z.infer<typeof loginSchema>;

// Mirrors the constraints of the backend RegisterDto (email/register.dto.ts).
export const registerSchema = z.object({
  firstName: z.string().min(1, 'First name is required.').max(50),
  lastName: z.string().min(1, 'Last name is required.').max(50),
  email: z.email('Enter a valid email address.'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters.')
    .max(72, 'Password must be at most 72 characters.'),
});

export type RegisterFormValues = z.infer<typeof registerSchema>;
