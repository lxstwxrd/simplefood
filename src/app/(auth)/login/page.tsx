import { Suspense } from 'react';
import { LoginForm } from './LoginForm';

export default function LoginPage() {
  return (
    <Suspense fallback={<div className="container py-10">Загрузка...</div>}>
      <LoginForm />
    </Suspense>
  );
}
