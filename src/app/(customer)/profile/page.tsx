import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { requireUser } from '@/features/auth/guards';
import { signOut } from '@/features/auth/actions';

export default async function ProfilePage() {
  const user = await requireUser();

  const fullName =
    typeof user.user_metadata?.full_name === 'string' ? user.user_metadata.full_name : 'Не указано';

  return (
    <div className="container max-w-2xl py-10">
      <Card>
        <CardHeader>
          <CardTitle>Мой профиль</CardTitle>
          <CardDescription>Управление вашим аккаунтом</CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm font-medium text-muted-foreground">Имя</p>
              <p className="text-lg">{fullName}</p>
            </div>

            <div>
              <p className="text-sm font-medium text-muted-foreground">Email</p>
              <p className="text-lg">{user.email ?? 'Не указан'}</p>
            </div>
          </div>

          <div className="border-t pt-4">
            <form action={signOut}>
              <Button type="submit" variant="destructive">
                Выйти из аккаунта
              </Button>
            </form>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
