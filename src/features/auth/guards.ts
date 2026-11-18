import 'server-only';

import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';

export async function requireUser() {
  const supabase = await createClient();
  const { data, error } = await supabase.auth.getUser();

  if (error || !data.user) {
    redirect('/login');
  }

  return data.user;
}

export async function requireAdmin() {
  const user = await requireUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('platform_admins')
    .select('user_id')
    .eq('user_id', user.id)
    .maybeSingle();

  if (error || !data) {
    redirect('/');
  }

  return user;
}

export async function requireCourier() {
  const user = await requireUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('courier_profiles')
    .select('user_id')
    .eq('user_id', user.id)
    .maybeSingle();

  if (error || !data) {
    redirect('/');
  }

  return user;
}

export async function requireRestaurantMember() {
  const user = await requireUser();
  const supabase = await createClient();

  const { data, error } = await supabase
    .from('restaurant_members')
    .select('id, restaurant_id, role')
    .eq('user_id', user.id);

  if (error || !data || data.length === 0) {
    redirect('/');
  }

  return {
    user,
    memberships: data,
  };
}
