'use server';

import { redirect } from 'next/navigation';
import { loginSchema, registerSchema } from '@/features/auth/schemas';
import { createClient } from '@/lib/supabase/server';

export type AuthActionState = {
  error: string | null;
  success: string | null;
};

export async function signUp(
  _prevState: AuthActionState,
  formData: FormData
): Promise<AuthActionState> {
  const parsed = registerSchema.safeParse({
    fullName: formData.get('fullName'),
    email: formData.get('email'),
    password: formData.get('password'),
  });

  if (!parsed.success) {
    return {
      error: parsed.error.issues[0]?.message ?? 'Проверьте введённые данные',
      success: null,
    };
  }

  const { fullName, email, password } = parsed.data;
  const supabase = await createClient();

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
      },
    },
  });

  if (error) {
    if (error.code === 'user_already_exists') {
      return {
        error: 'Пользователь с таким email уже зарегистрирован',
        success: null,
      };
    }

    return {
      error: 'Не удалось зарегистрироваться. Попробуйте позже.',
      success: null,
    };
  }

  if (!data.session) {
    return {
      error: null,
      success: 'Аккаунт создан. Проверьте почту для подтверждения регистрации.',
    };
  }

  redirect('/');
}

export async function signIn(
  _prevState: AuthActionState,
  formData: FormData
): Promise<AuthActionState> {
  const parsed = loginSchema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  });

  if (!parsed.success) {
    return {
      error: parsed.error.issues[0]?.message ?? 'Проверьте введённые данные',
      success: null,
    };
  }

  const supabase = await createClient();

  const { error } = await supabase.auth.signInWithPassword(parsed.data);

  if (error) {
    return {
      error:
        error.code === 'invalid_credentials'
          ? 'Неверный email или пароль'
          : 'Не удалось войти. Попробуйте позже.',
      success: null,
    };
  }

  const returnTo = formData.get('returnTo');

  if (
    typeof returnTo === 'string' &&
    returnTo.startsWith('/') &&
    !returnTo.startsWith('//') &&
    !returnTo.includes('\\')
  ) {
    redirect(returnTo);
  }

  redirect('/');
}

export async function signOut(): Promise<void> {
  const supabase = await createClient();

  const { error } = await supabase.auth.signOut();

  if (error) {
    throw new Error('Не удалось выйти из аккаунта');
  }

  redirect('/');
}
