revoke delete on table "public"."courier_profiles" from "anon";

revoke insert on table "public"."courier_profiles" from "anon";

revoke references on table "public"."courier_profiles" from "anon";

revoke select on table "public"."courier_profiles" from "anon";

revoke trigger on table "public"."courier_profiles" from "anon";

revoke truncate on table "public"."courier_profiles" from "anon";

revoke update on table "public"."courier_profiles" from "anon";

revoke delete on table "public"."courier_profiles" from "authenticated";

revoke insert on table "public"."courier_profiles" from "authenticated";

revoke references on table "public"."courier_profiles" from "authenticated";

revoke trigger on table "public"."courier_profiles" from "authenticated";

revoke truncate on table "public"."courier_profiles" from "authenticated";

revoke update on table "public"."courier_profiles" from "authenticated";

revoke delete on table "public"."order_status_history" from "anon";

revoke insert on table "public"."order_status_history" from "anon";

revoke references on table "public"."order_status_history" from "anon";

revoke select on table "public"."order_status_history" from "anon";

revoke trigger on table "public"."order_status_history" from "anon";

revoke truncate on table "public"."order_status_history" from "anon";

revoke update on table "public"."order_status_history" from "anon";

revoke delete on table "public"."order_status_history" from "authenticated";

revoke insert on table "public"."order_status_history" from "authenticated";

revoke references on table "public"."order_status_history" from "authenticated";

revoke trigger on table "public"."order_status_history" from "authenticated";

revoke truncate on table "public"."order_status_history" from "authenticated";

revoke update on table "public"."order_status_history" from "authenticated";

revoke delete on table "public"."platform_admins" from "anon";

revoke insert on table "public"."platform_admins" from "anon";

revoke references on table "public"."platform_admins" from "anon";

revoke select on table "public"."platform_admins" from "anon";

revoke trigger on table "public"."platform_admins" from "anon";

revoke truncate on table "public"."platform_admins" from "anon";

revoke update on table "public"."platform_admins" from "anon";

revoke delete on table "public"."platform_admins" from "authenticated";

revoke insert on table "public"."platform_admins" from "authenticated";

revoke references on table "public"."platform_admins" from "authenticated";

revoke trigger on table "public"."platform_admins" from "authenticated";

revoke truncate on table "public"."platform_admins" from "authenticated";

revoke update on table "public"."platform_admins" from "authenticated";

revoke delete on table "public"."restaurant_applications" from "anon";

revoke insert on table "public"."restaurant_applications" from "anon";

revoke references on table "public"."restaurant_applications" from "anon";

revoke select on table "public"."restaurant_applications" from "anon";

revoke trigger on table "public"."restaurant_applications" from "anon";

revoke truncate on table "public"."restaurant_applications" from "anon";

revoke update on table "public"."restaurant_applications" from "anon";

revoke delete on table "public"."restaurant_applications" from "authenticated";

revoke references on table "public"."restaurant_applications" from "authenticated";

revoke trigger on table "public"."restaurant_applications" from "authenticated";

revoke truncate on table "public"."restaurant_applications" from "authenticated";

revoke update on table "public"."restaurant_applications" from "authenticated";

revoke delete on table "public"."restaurant_members" from "anon";

revoke insert on table "public"."restaurant_members" from "anon";

revoke references on table "public"."restaurant_members" from "anon";

revoke select on table "public"."restaurant_members" from "anon";

revoke trigger on table "public"."restaurant_members" from "anon";

revoke truncate on table "public"."restaurant_members" from "anon";

revoke update on table "public"."restaurant_members" from "anon";

revoke delete on table "public"."restaurant_members" from "authenticated";

revoke insert on table "public"."restaurant_members" from "authenticated";

revoke references on table "public"."restaurant_members" from "authenticated";

revoke trigger on table "public"."restaurant_members" from "authenticated";

revoke truncate on table "public"."restaurant_members" from "authenticated";

revoke update on table "public"."restaurant_members" from "authenticated";

alter table "public"."orders" alter column "status" drop default;

alter table "public"."orders" alter column status type "public"."order_status" using status::text::"public"."order_status";

alter table "public"."orders" alter column "status" set default 'pending'::public.order_status;

alter table "public"."orders" alter column "status" set not null;

alter table "public"."courier_locations" add constraint "courier_locations_latitude_check" CHECK (((lat >= ('-90'::integer)::numeric) AND (lat <= (90)::numeric))) not valid;

alter table "public"."courier_locations" validate constraint "courier_locations_latitude_check";

alter table "public"."courier_locations" add constraint "courier_locations_longitude_check" CHECK (((lng >= ('-180'::integer)::numeric) AND (lng <= (180)::numeric))) not valid;

alter table "public"."courier_locations" validate constraint "courier_locations_longitude_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.set_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$function$
;

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.categories FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.courier_profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.orders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.restaurant_applications FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_set_updated_at BEFORE UPDATE ON public.restaurants FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
