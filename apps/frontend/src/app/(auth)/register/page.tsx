import { Mail, User } from 'lucide-react';
import Link from 'next/link';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { PasswordInput } from '@/components/ui/password-input';

// TODO (2.2): wire up react-hook-form + zod validation and call
// POST /api/v1/auth/register via the typed API client.
export default function RegisterPage() {
  return (
    <div>
      <h1 className="text-center text-2xl font-semibold text-slate-900">Create your account</h1>
      <p className="mt-1 text-center text-sm text-slate-500">
        Start managing your tasks in a minute
      </p>

      <form className="mt-8 flex flex-col gap-5">
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label htmlFor="firstName" className="mb-1.5 block text-sm font-medium text-slate-700">
              First name
            </label>
            <Input
              id="firstName"
              name="firstName"
              type="text"
              autoComplete="given-name"
              maxLength={50}
              icon={User}
              placeholder="John"
            />
          </div>
          <div>
            <label htmlFor="lastName" className="mb-1.5 block text-sm font-medium text-slate-700">
              Last name
            </label>
            <Input
              id="lastName"
              name="lastName"
              type="text"
              autoComplete="family-name"
              maxLength={50}
              icon={User}
              placeholder="Doe"
            />
          </div>
        </div>

        <div>
          <label htmlFor="email" className="mb-1.5 block text-sm font-medium text-slate-700">
            Email
          </label>
          <Input
            id="email"
            name="email"
            type="email"
            autoComplete="email"
            icon={Mail}
            placeholder="Enter your email"
          />
        </div>

        <div>
          <label htmlFor="password" className="mb-1.5 block text-sm font-medium text-slate-700">
            Password
          </label>
          <PasswordInput
            id="password"
            name="password"
            autoComplete="new-password"
            minLength={8}
            maxLength={72}
            placeholder="At least 8 characters"
          />
        </div>

        <Button type="submit" className="w-full">
          Create account
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-slate-500">
        Already have an account?{' '}
        <Link href="/login" className="font-medium text-brand hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}
