import { requireRestaurantMember } from '@/features/auth/guards';

export default async function RestaurantLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  await requireRestaurantMember();

  return <>{children}</>;
}
