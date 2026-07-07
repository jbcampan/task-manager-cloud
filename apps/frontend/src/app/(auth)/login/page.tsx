import { Mail } from 'lucide-react';
import Link from 'next/link';

import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import { Input } from '@/components/ui/input';
import { PasswordInput } from '@/components/ui/password-input';

export default function LoginPage() {
  return (
    <div>
      <h1 className="text-center text-2xl font-semibold text-slate-900">Welcome back</h1>
      <p className="mt-1 text-center text-sm text-slate-500">Sign in to your account to continue</p>

      <form className="mt-8 flex flex-col gap-5">
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
            autoComplete="current-password"
            placeholder="Enter your password"
          />
        </div>

        <div className="flex items-center justify-between">
          <Checkbox id="remember-me" name="rememberMe" label="Remember me" />
          {/* TODO: forgot-password flow is out of scope for this project — link kept for visual fidelity to the mockup */}
          <Link href="#" className="text-sm font-medium text-brand hover:underline">
            Forgot password?
          </Link>
        </div>

        <Button type="submit" className="w-full">
          Log in
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-slate-500">
        Don&apos;t have an account?{' '}
        <Link href="/register" className="font-medium text-brand hover:underline">
          Sign up
        </Link>
      </p>
    </div>
  );
}
