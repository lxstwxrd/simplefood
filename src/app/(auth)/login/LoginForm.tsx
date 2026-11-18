'use client';

import { useActionState } from 'react';
import { useSearchParams } from 'next/navigation';

import { signIn, type AuthActionState } from '@/features/auth/actions';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

const initialState: AuthActionState = {
  error: null,
  success: null,
};

export function LoginForm() {
  const [state, formAction, isPending] = useActionState(signIn, initialState);

  const searchParams = useSearchParams();
  const returnTo = searchParams.get('returnTo');

  return (
    <Card>
      <CardHeader>
        <CardTitle>С возвращением</CardTitle>
        <CardDescription>Введите свои данные для входа</CardDescription>
      </CardHeader>

      <CardContent>
        <form action={formAction} className="space-y-4">
          <input type="hidden" name="returnTo" value={returnTo ?? ''} />

          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              name="email"
              type="email"
              placeholder="mail@example.com"
              autoComplete="email"
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="password">Пароль</Label>
            <Input
              id="password"
              name="password"
              type="password"
              placeholder="Введите пароль"
              autoComplete="current-password"
              required
            />
          </div>

          {state.error && (
            <p role="alert" className="text-sm text-destructive">
              {state.error}
            </p>
          )}

          <Button type="submit" className="w-full" disabled={isPending}>
            {isPending ? 'Входим...' : 'Войти'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}
