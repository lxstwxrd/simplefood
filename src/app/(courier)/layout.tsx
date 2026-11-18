import { requireCourier } from '@/features/auth/guards';

export default async function CourierLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  await requireCourier();

  return <>{children}</>;
}
