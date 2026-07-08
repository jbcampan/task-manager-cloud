import Link from 'next/link';

import { RegisterForm } from '@/components/auth/register-form';

export default function RegisterPage() {
  return (
    <div>
      <h1 className="text-center text-2xl font-semibold text-slate-900">Create your account</h1>
      <p className="mt-1 text-center text-sm text-slate-500">
        Start managing your tasks in a minute
      </p>

      <RegisterForm />

      <p className="mt-6 text-center text-sm text-slate-500">
        Already have an account?{' '}
        <Link href="/login" className="font-medium text-brand hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}
