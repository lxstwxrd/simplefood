import * as z from 'zod';

const emailSchema = z
  .string()
  .trim()
  .pipe(z.email({ message: 'Введите корректный email' }));

const passwordSchema = z.string().min(6, { message: 'Пароль должен быть не менее 6 символов' });

export const registerSchema = z.object({
  fullName: z.string().trim().min(2, { message: 'Имя должно быть не менее 2 символов' }),
  email: emailSchema,
  password: passwordSchema,
});

export const loginSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
});

export type RegisterFormValues = z.infer<typeof registerSchema>;
export type LoginFormValues = z.infer<typeof loginSchema>;

//единые правила проверки входных данных
