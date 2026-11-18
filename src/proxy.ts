import { type NextRequest, NextResponse } from 'next/server';
import { updateSession } from '@/lib/supabase/update-session';

function isRoute(pathname: string, route: string) {
  return pathname === route || pathname.startsWith(`${route}/`);
}

export async function proxy(request: NextRequest) {
  const { supabaseResponse, user } = await updateSession(request);
  const { pathname, search } = request.nextUrl;

  const isProtectedRoute = ['/profile', '/orders', '/admin', '/courier'].some((route) =>
    isRoute(pathname, route)
  );

  const isAuthRoute = ['/login', '/register'].some((route) => isRoute(pathname, route));

  if (!user && isProtectedRoute) {
    const loginUrl = new URL('/login', request.url);
    loginUrl.searchParams.set('returnTo', `${pathname}${search}`);

    const response = NextResponse.redirect(loginUrl);

    supabaseResponse.cookies.getAll().forEach((cookie) => {
      response.cookies.set(cookie);
    });

    return response;
  }

  if (user && isAuthRoute) {
    const response = NextResponse.redirect(new URL('/', request.url));

    supabaseResponse.cookies.getAll().forEach((cookie) => {
      response.cookies.set(cookie);
    });

    return response;
  }

  return supabaseResponse;
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)'],
};
