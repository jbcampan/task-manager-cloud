import Link from 'next/link';

import { LoginForm } from '@/components/auth/login-form';

export default function LoginPage() {
  return (
    <div>
      <h1 className="text-center text-2xl font-semibold text-slate-900">Welcome back</h1>
      <p className="mt-1 text-center text-sm text-slate-500">Sign in to your account to continue</p>

      <LoginForm />

      <p className="mt-6 text-center text-sm text-slate-500">
        Don&apos;t have an account?{' '}
        <Link href="/register" className="font-medium text-brand hover:underline">
          Sign up
        </Link>
      </p>
    </div>
  );
}
