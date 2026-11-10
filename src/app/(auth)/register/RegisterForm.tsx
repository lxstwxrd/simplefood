'use client';

import { zodResolver } from '@hookform/resolvers/zod';
import { useForm } from 'react-hook-form';
import { registerSchema, type RegisterFormValues } from '@/features/auth/schemas';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export function RegisterForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: { fullName: '', email: '', password: '' },
  });

  async function onSubmit(values: RegisterFormValues) {
    // ЗАГЛУШКА: Позже здесь будет вызов Server Action от коллеги
    console.log('Отправка данных:', values);

    toast.promise(
      new Promise((resolve) => setTimeout(resolve, 1000)), // Имитация запроса
      {
        loading: 'Регистрация...',
        success: () => 'Успешная регистрация!',
        error: 'Ошибка регистрации',
      }
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Регистрация</CardTitle>
        <CardDescription>Заполните данные, чтобы создать аккаунт</CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="fullName">Имя</Label>
            <Input id="fullName" placeholder="Иван Иванов" {...register('fullName')} />
            {errors.fullName && <p className="text-sm text-red-500">{errors.fullName.message}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input id="email" type="email" placeholder="mail@example.com" {...register('email')} />
            {errors.email && <p className="text-sm text-red-500">{errors.email.message}</p>}
          </div>

          <div className="space-y-2">
            <Label htmlFor="password">Пароль</Label>
            <Input id="password" type="password" placeholder="••••••••" {...register('password')} />
            {errors.password && <p className="text-sm text-red-500">{errors.password.message}</p>}
          </div>

          <Button type="submit" className="w-full" disabled={isSubmitting}>
            {isSubmitting ? 'Загрузка...' : 'Зарегистрироваться'}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

// Сбор данных нового пользователя. Проблема аналогична форме входа: сейчас это заглушка. Также форма использует fullName, а server action ожидает full_name - согласовать.
// Также необходимо вынести схему Zod в общий модуль авторизации, чтобы клиентская и серверная валидация не расходилась.
// В будущем: Регистрация создаёт Пользователя в Supabase Auth, записывает профиль через PostgreSQL trigger, создаёт сессию после успешного подтверждения
