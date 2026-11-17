revoke delete on table "public"."categories" from "anon";

revoke insert on table "public"."categories" from "anon";

revoke references on table "public"."categories" from "anon";

revoke trigger on table "public"."categories" from "anon";

revoke truncate on table "public"."categories" from "anon";

revoke update on table "public"."categories" from "anon";

revoke references on table "public"."categories" from "authenticated";

revoke trigger on table "public"."categories" from "authenticated";

revoke truncate on table "public"."categories" from "authenticated";

revoke delete on table "public"."courier_locations" from "anon";

revoke insert on table "public"."courier_locations" from "anon";

revoke references on table "public"."courier_locations" from "anon";

revoke select on table "public"."courier_locations" from "anon";

revoke trigger on table "public"."courier_locations" from "anon";

revoke truncate on table "public"."courier_locations" from "anon";

revoke update on table "public"."courier_locations" from "anon";

revoke delete on table "public"."courier_locations" from "authenticated";

revoke insert on table "public"."courier_locations" from "authenticated";

revoke references on table "public"."courier_locations" from "authenticated";

revoke trigger on table "public"."courier_locations" from "authenticated";

revoke truncate on table "public"."courier_locations" from "authenticated";

revoke update on table "public"."courier_locations" from "authenticated";

revoke delete on table "public"."order_items" from "anon";

revoke insert on table "public"."order_items" from "anon";

revoke references on table "public"."order_items" from "anon";

revoke select on table "public"."order_items" from "anon";

revoke trigger on table "public"."order_items" from "anon";

revoke truncate on table "public"."order_items" from "anon";

revoke update on table "public"."order_items" from "anon";

revoke delete on table "public"."order_items" from "authenticated";

revoke insert on table "public"."order_items" from "authenticated";

revoke references on table "public"."order_items" from "authenticated";

revoke trigger on table "public"."order_items" from "authenticated";

revoke truncate on table "public"."order_items" from "authenticated";

revoke update on table "public"."order_items" from "authenticated";

revoke delete on table "public"."orders" from "anon";

revoke insert on table "public"."orders" from "anon";

revoke references on table "public"."orders" from "anon";

revoke select on table "public"."orders" from "anon";

revoke trigger on table "public"."orders" from "anon";

revoke truncate on table "public"."orders" from "anon";

revoke update on table "public"."orders" from "anon";

revoke delete on table "public"."orders" from "authenticated";

revoke insert on table "public"."orders" from "authenticated";

revoke references on table "public"."orders" from "authenticated";

revoke trigger on table "public"."orders" from "authenticated";

revoke truncate on table "public"."orders" from "authenticated";

revoke update on table "public"."orders" from "authenticated";

revoke delete on table "public"."products" from "anon";

revoke insert on table "public"."products" from "anon";

revoke references on table "public"."products" from "anon";

revoke trigger on table "public"."products" from "anon";

revoke truncate on table "public"."products" from "anon";

revoke update on table "public"."products" from "anon";

revoke references on table "public"."products" from "authenticated";

revoke trigger on table "public"."products" from "authenticated";

revoke truncate on table "public"."products" from "authenticated";

revoke delete on table "public"."profiles" from "anon";

revoke insert on table "public"."profiles" from "anon";

revoke references on table "public"."profiles" from "anon";

revoke select on table "public"."profiles" from "anon";

revoke trigger on table "public"."profiles" from "anon";

revoke truncate on table "public"."profiles" from "anon";

revoke update on table "public"."profiles" from "anon";

revoke delete on table "public"."profiles" from "authenticated";

revoke insert on table "public"."profiles" from "authenticated";

revoke references on table "public"."profiles" from "authenticated";

revoke trigger on table "public"."profiles" from "authenticated";

revoke truncate on table "public"."profiles" from "authenticated";

revoke update on table "public"."profiles" from "authenticated";

revoke delete on table "public"."restaurants" from "anon";

revoke insert on table "public"."restaurants" from "anon";

revoke references on table "public"."restaurants" from "anon";

revoke trigger on table "public"."restaurants" from "anon";

revoke truncate on table "public"."restaurants" from "anon";

revoke update on table "public"."restaurants" from "anon";

revoke delete on table "public"."restaurants" from "authenticated";

revoke insert on table "public"."restaurants" from "authenticated";

revoke references on table "public"."restaurants" from "authenticated";

revoke trigger on table "public"."restaurants" from "authenticated";

revoke truncate on table "public"."restaurants" from "authenticated";

revoke update on table "public"."restaurants" from "authenticated";


  create table "public"."courier_profiles" (
    "user_id" uuid not null,
    "status" text not null default 'pending'::text,
    "is_available" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."courier_profiles" enable row level security;


  create table "public"."order_status_history" (
    "id" uuid not null default gen_random_uuid(),
    "order_id" uuid not null,
    "old_status" public.order_status,
    "new_status" public.order_status not null,
    "changed_by" uuid,
    "comment" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."order_status_history" enable row level security;


  create table "public"."platform_admins" (
    "user_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid
      );


alter table "public"."platform_admins" enable row level security;


  create table "public"."restaurant_applications" (
    "id" uuid not null default gen_random_uuid(),
    "applicant_id" uuid not null,
    "restaurant_id" uuid,
    "restaurant_name" text not null,
    "description" text,
    "address" text not null,
    "contact_phone" text not null,
    "status" text not null default 'pending'::text,
    "moderation_comment" text,
    "reviewed_by" uuid,
    "reviewed_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."restaurant_applications" enable row level security;


  create table "public"."restaurant_members" (
    "id" uuid not null default gen_random_uuid(),
    "restaurant_id" uuid not null,
    "user_id" uuid not null,
    "role" text not null,
    "created_at" timestamp with time zone not null default now(),
    "created_by" uuid
      );


alter table "public"."restaurant_members" enable row level security;

alter table "public"."categories" add column "created_at" timestamp with time zone not null default now();

alter table "public"."categories" add column "updated_at" timestamp with time zone not null default now();

alter table "public"."order_items" add column "product_description" text;

alter table "public"."order_items" add column "product_image_url" text;

alter table "public"."order_items" add column "product_name" text not null;

alter table "public"."order_items" add column "restaurant_id" uuid not null;

alter table "public"."order_items" add column "unit_price" numeric(12,2) not null;

alter table "public"."products" add column "updated_at" timestamp with time zone not null default now();

alter table "public"."restaurants" add column "is_accepting_orders" boolean not null default false;

alter table "public"."restaurants" add column "latitude" numeric(9,6);

alter table "public"."restaurants" add column "longitude" numeric(9,6);

alter table "public"."restaurants" add column "moderation_status" text not null default 'pending'::text;

alter table "public"."restaurants" add column "updated_at" timestamp with time zone not null default now();

CREATE UNIQUE INDEX categories_id_restaurant_unique ON public.categories USING btree (id, restaurant_id);

CREATE UNIQUE INDEX courier_profiles_pkey ON public.courier_profiles USING btree (user_id);

CREATE UNIQUE INDEX idx_categories_restaurant_name ON public.categories USING btree (restaurant_id, lower(name));

CREATE INDEX idx_categories_restaurant_sort ON public.categories USING btree (restaurant_id, sort_order);

CREATE INDEX idx_courier_profiles_status ON public.courier_profiles USING btree (status);

CREATE INDEX idx_order_items_order ON public.order_items USING btree (order_id);

CREATE INDEX idx_order_items_product ON public.order_items USING btree (product_id);

CREATE INDEX idx_order_items_restaurant ON public.order_items USING btree (restaurant_id);

CREATE INDEX idx_order_status_history_changed_by ON public.order_status_history USING btree (changed_by) WHERE (changed_by IS NOT NULL);

CREATE INDEX idx_order_status_history_order_created ON public.order_status_history USING btree (order_id, created_at DESC);

CREATE INDEX idx_orders_courier_status ON public.orders USING btree (courier_id, status) WHERE (courier_id IS NOT NULL);

CREATE INDEX idx_orders_customer_created ON public.orders USING btree (customer_id, created_at DESC);

CREATE INDEX idx_orders_restaurant_status_created ON public.orders USING btree (restaurant_id, status, created_at DESC);

CREATE INDEX idx_products_category ON public.products USING btree (category_id);

CREATE INDEX idx_products_restaurant_available ON public.products USING btree (restaurant_id, is_available);

CREATE INDEX idx_restaurant_applications_applicant ON public.restaurant_applications USING btree (applicant_id, created_at DESC);

CREATE INDEX idx_restaurant_applications_restaurant ON public.restaurant_applications USING btree (restaurant_id) WHERE (restaurant_id IS NOT NULL);

CREATE INDEX idx_restaurant_applications_status_created ON public.restaurant_applications USING btree (status, created_at DESC);

CREATE INDEX idx_restaurant_members_restaurant_role ON public.restaurant_members USING btree (restaurant_id, role);

CREATE INDEX idx_restaurant_members_user ON public.restaurant_members USING btree (user_id, restaurant_id);

CREATE INDEX idx_restaurants_accepting_orders ON public.restaurants USING btree (is_accepting_orders) WHERE (is_accepting_orders = true);

CREATE INDEX idx_restaurants_moderation_status ON public.restaurants USING btree (moderation_status);

CREATE UNIQUE INDEX order_status_history_pkey ON public.order_status_history USING btree (id);

CREATE UNIQUE INDEX orders_id_restaurant_unique ON public.orders USING btree (id, restaurant_id);

CREATE UNIQUE INDEX platform_admins_pkey ON public.platform_admins USING btree (user_id);

CREATE UNIQUE INDEX products_id_restaurant_unique ON public.products USING btree (id, restaurant_id);

CREATE UNIQUE INDEX restaurant_applications_one_pending_per_user ON public.restaurant_applications USING btree (applicant_id) WHERE (status = 'pending'::text);

CREATE UNIQUE INDEX restaurant_applications_pkey ON public.restaurant_applications USING btree (id);

CREATE UNIQUE INDEX restaurant_members_pkey ON public.restaurant_members USING btree (id);

CREATE UNIQUE INDEX restaurant_members_unique_user ON public.restaurant_members USING btree (restaurant_id, user_id);

alter table "public"."courier_profiles" add constraint "courier_profiles_pkey" PRIMARY KEY using index "courier_profiles_pkey";

alter table "public"."order_status_history" add constraint "order_status_history_pkey" PRIMARY KEY using index "order_status_history_pkey";

alter table "public"."platform_admins" add constraint "platform_admins_pkey" PRIMARY KEY using index "platform_admins_pkey";

alter table "public"."restaurant_applications" add constraint "restaurant_applications_pkey" PRIMARY KEY using index "restaurant_applications_pkey";

alter table "public"."restaurant_members" add constraint "restaurant_members_pkey" PRIMARY KEY using index "restaurant_members_pkey";

alter table "public"."categories" add constraint "categories_id_restaurant_unique" UNIQUE using index "categories_id_restaurant_unique";

alter table "public"."courier_profiles" add constraint "courier_available_only_when_active" CHECK (((is_available = false) OR (status = 'active'::text))) not valid;

alter table "public"."courier_profiles" validate constraint "courier_available_only_when_active";

alter table "public"."courier_profiles" add constraint "courier_profiles_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'active'::text, 'suspended'::text, 'rejected'::text]))) not valid;

alter table "public"."courier_profiles" validate constraint "courier_profiles_status_check";

alter table "public"."courier_profiles" add constraint "courier_profiles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."courier_profiles" validate constraint "courier_profiles_user_id_fkey";

alter table "public"."order_items" add constraint "order_items_order_restaurant_fk" FOREIGN KEY (order_id, restaurant_id) REFERENCES public.orders(id, restaurant_id) not valid;

alter table "public"."order_items" validate constraint "order_items_order_restaurant_fk";

alter table "public"."order_items" add constraint "order_items_product_restaurant_fk" FOREIGN KEY (product_id, restaurant_id) REFERENCES public.products(id, restaurant_id) not valid;

alter table "public"."order_items" validate constraint "order_items_product_restaurant_fk";

alter table "public"."order_items" add constraint "order_items_unit_price_nonnegative_check" CHECK ((unit_price >= (0)::numeric)) not valid;

alter table "public"."order_items" validate constraint "order_items_unit_price_nonnegative_check";

alter table "public"."order_status_history" add constraint "order_status_history_changed_by_fkey" FOREIGN KEY (changed_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."order_status_history" validate constraint "order_status_history_changed_by_fkey";

alter table "public"."order_status_history" add constraint "order_status_history_order_id_fkey" FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE RESTRICT not valid;

alter table "public"."order_status_history" validate constraint "order_status_history_order_id_fkey";

alter table "public"."orders" add constraint "orders_delivery_latitude_check" CHECK (((delivery_lat IS NULL) OR ((delivery_lat >= ('-90'::integer)::numeric) AND (delivery_lat <= (90)::numeric)))) not valid;

alter table "public"."orders" validate constraint "orders_delivery_latitude_check";

alter table "public"."orders" add constraint "orders_delivery_longitude_check" CHECK (((delivery_lng IS NULL) OR ((delivery_lng >= ('-180'::integer)::numeric) AND (delivery_lng <= (180)::numeric)))) not valid;

alter table "public"."orders" validate constraint "orders_delivery_longitude_check";

alter table "public"."orders" add constraint "orders_id_restaurant_unique" UNIQUE using index "orders_id_restaurant_unique";

alter table "public"."orders" add constraint "orders_total_price_nonnegative_check" CHECK ((total_price >= (0)::numeric)) not valid;

alter table "public"."orders" validate constraint "orders_total_price_nonnegative_check";

alter table "public"."platform_admins" add constraint "platform_admins_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."platform_admins" validate constraint "platform_admins_created_by_fkey";

alter table "public"."platform_admins" add constraint "platform_admins_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."platform_admins" validate constraint "platform_admins_user_id_fkey";

alter table "public"."products" add constraint "products_category_restaurant_fk" FOREIGN KEY (category_id, restaurant_id) REFERENCES public.categories(id, restaurant_id) not valid;

alter table "public"."products" validate constraint "products_category_restaurant_fk";

alter table "public"."products" add constraint "products_id_restaurant_unique" UNIQUE using index "products_id_restaurant_unique";

alter table "public"."products" add constraint "products_price_nonnegative_check" CHECK ((price >= (0)::numeric)) not valid;

alter table "public"."products" validate constraint "products_price_nonnegative_check";

alter table "public"."restaurant_applications" add constraint "application_review_consistency_check" CHECK ((((status = 'pending'::text) AND (reviewed_by IS NULL) AND (reviewed_at IS NULL)) OR ((status <> 'pending'::text) AND (reviewed_at IS NOT NULL)))) not valid;

alter table "public"."restaurant_applications" validate constraint "application_review_consistency_check";

alter table "public"."restaurant_applications" add constraint "restaurant_applications_applicant_id_fkey" FOREIGN KEY (applicant_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."restaurant_applications" validate constraint "restaurant_applications_applicant_id_fkey";

alter table "public"."restaurant_applications" add constraint "restaurant_applications_restaurant_id_fkey" FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE SET NULL not valid;

alter table "public"."restaurant_applications" validate constraint "restaurant_applications_restaurant_id_fkey";

alter table "public"."restaurant_applications" add constraint "restaurant_applications_reviewed_by_fkey" FOREIGN KEY (reviewed_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."restaurant_applications" validate constraint "restaurant_applications_reviewed_by_fkey";

alter table "public"."restaurant_applications" add constraint "restaurant_applications_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'withdrawn'::text]))) not valid;

alter table "public"."restaurant_applications" validate constraint "restaurant_applications_status_check";

alter table "public"."restaurant_members" add constraint "restaurant_members_created_by_fkey" FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."restaurant_members" validate constraint "restaurant_members_created_by_fkey";

alter table "public"."restaurant_members" add constraint "restaurant_members_restaurant_id_fkey" FOREIGN KEY (restaurant_id) REFERENCES public.restaurants(id) ON DELETE CASCADE not valid;

alter table "public"."restaurant_members" validate constraint "restaurant_members_restaurant_id_fkey";

alter table "public"."restaurant_members" add constraint "restaurant_members_role_check" CHECK ((role = ANY (ARRAY['owner'::text, 'manager'::text, 'staff'::text]))) not valid;

alter table "public"."restaurant_members" validate constraint "restaurant_members_role_check";

alter table "public"."restaurant_members" add constraint "restaurant_members_unique_user" UNIQUE using index "restaurant_members_unique_user";

alter table "public"."restaurant_members" add constraint "restaurant_members_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."restaurant_members" validate constraint "restaurant_members_user_id_fkey";

alter table "public"."restaurants" add constraint "restaurants_latitude_check" CHECK (((latitude IS NULL) OR ((latitude >= ('-90'::integer)::numeric) AND (latitude <= (90)::numeric)))) not valid;

alter table "public"."restaurants" validate constraint "restaurants_latitude_check";

alter table "public"."restaurants" add constraint "restaurants_longitude_check" CHECK (((longitude IS NULL) OR ((longitude >= ('-180'::integer)::numeric) AND (longitude <= (180)::numeric)))) not valid;

alter table "public"."restaurants" validate constraint "restaurants_longitude_check";

alter table "public"."restaurants" add constraint "restaurants_moderation_status_check" CHECK ((moderation_status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text, 'suspended'::text]))) not valid;

alter table "public"."restaurants" validate constraint "restaurants_moderation_status_check";

alter table "public"."restaurants" add constraint "restaurants_rating_check" CHECK (((rating IS NULL) OR ((rating >= (0)::numeric) AND (rating <= (5)::numeric)))) not valid;

alter table "public"."restaurants" validate constraint "restaurants_rating_check";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.has_restaurant_role(p_restaurant_id uuid, p_roles text[])
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM public.restaurant_members rm
        WHERE rm.restaurant_id = p_restaurant_id
          AND rm.user_id = (SELECT auth.uid())
          AND rm.role = ANY (p_roles)
    );
$function$
;

CREATE OR REPLACE FUNCTION public.is_platform_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM public.platform_admins pa
        WHERE pa.user_id = (SELECT auth.uid())
    );
$function$
;

CREATE OR REPLACE FUNCTION public.is_restaurant_member(p_restaurant_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM public.restaurant_members rm
        WHERE rm.restaurant_id = p_restaurant_id
          AND rm.user_id = (SELECT auth.uid())
    );
$function$
;

CREATE OR REPLACE FUNCTION public.record_order_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO public.order_status_history (
            order_id,
            old_status,
            new_status,
            changed_by
        )
        VALUES (
            NEW.id,
            NULL,
            NEW.status,
            auth.uid()
        );

    ELSIF OLD.status IS DISTINCT FROM NEW.status THEN
        INSERT INTO public.order_status_history (
            order_id,
            old_status,
            new_status,
            changed_by
        )
        VALUES (
            NEW.id,
            OLD.status,
            NEW.status,
            auth.uid()
        );
    END IF;

    RETURN NEW;
END;
$function$
;

grant select on table "public"."courier_profiles" to "authenticated";

grant delete on table "public"."courier_profiles" to "service_role";

grant insert on table "public"."courier_profiles" to "service_role";

grant references on table "public"."courier_profiles" to "service_role";

grant select on table "public"."courier_profiles" to "service_role";

grant trigger on table "public"."courier_profiles" to "service_role";

grant truncate on table "public"."courier_profiles" to "service_role";

grant update on table "public"."courier_profiles" to "service_role";

grant select on table "public"."order_status_history" to "authenticated";

grant delete on table "public"."order_status_history" to "service_role";

grant insert on table "public"."order_status_history" to "service_role";

grant references on table "public"."order_status_history" to "service_role";

grant select on table "public"."order_status_history" to "service_role";

grant trigger on table "public"."order_status_history" to "service_role";

grant truncate on table "public"."order_status_history" to "service_role";

grant update on table "public"."order_status_history" to "service_role";

grant select on table "public"."platform_admins" to "authenticated";

grant delete on table "public"."platform_admins" to "service_role";

grant insert on table "public"."platform_admins" to "service_role";

grant references on table "public"."platform_admins" to "service_role";

grant select on table "public"."platform_admins" to "service_role";

grant trigger on table "public"."platform_admins" to "service_role";

grant truncate on table "public"."platform_admins" to "service_role";

grant update on table "public"."platform_admins" to "service_role";

grant insert on table "public"."restaurant_applications" to "authenticated";

grant select on table "public"."restaurant_applications" to "authenticated";

grant delete on table "public"."restaurant_applications" to "service_role";

grant insert on table "public"."restaurant_applications" to "service_role";

grant references on table "public"."restaurant_applications" to "service_role";

grant select on table "public"."restaurant_applications" to "service_role";

grant trigger on table "public"."restaurant_applications" to "service_role";

grant truncate on table "public"."restaurant_applications" to "service_role";

grant update on table "public"."restaurant_applications" to "service_role";

grant select on table "public"."restaurant_members" to "authenticated";

grant delete on table "public"."restaurant_members" to "service_role";

grant insert on table "public"."restaurant_members" to "service_role";

grant references on table "public"."restaurant_members" to "service_role";

grant select on table "public"."restaurant_members" to "service_role";

grant trigger on table "public"."restaurant_members" to "service_role";

grant truncate on table "public"."restaurant_members" to "service_role";

grant update on table "public"."restaurant_members" to "service_role";


  create policy "categories_member_delete"
  on "public"."categories"
  as permissive
  for delete
  to authenticated
using ((( SELECT public.has_restaurant_role(categories.restaurant_id, ARRAY['owner'::text, 'manager'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "categories_member_insert"
  on "public"."categories"
  as permissive
  for insert
  to authenticated
with check ((( SELECT public.has_restaurant_role(categories.restaurant_id, ARRAY['owner'::text, 'manager'::text, 'staff'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "categories_member_update"
  on "public"."categories"
  as permissive
  for update
  to authenticated
using ((( SELECT public.has_restaurant_role(categories.restaurant_id, ARRAY['owner'::text, 'manager'::text, 'staff'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)))
with check ((( SELECT public.has_restaurant_role(categories.restaurant_id, ARRAY['owner'::text, 'manager'::text, 'staff'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "categories_public_read"
  on "public"."categories"
  as permissive
  for select
  to anon, authenticated
using (((EXISTS ( SELECT 1
   FROM public.restaurants r
  WHERE ((r.id = categories.restaurant_id) AND (r.moderation_status = 'approved'::text)))) OR ((( SELECT auth.uid() AS uid) IS NOT NULL) AND (( SELECT public.is_restaurant_member(categories.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)))));



  create policy "categories_visibility_restriction"
  on "public"."categories"
  as restrictive
  for select
  to anon, authenticated
using (((EXISTS ( SELECT 1
   FROM public.restaurants r
  WHERE ((r.id = categories.restaurant_id) AND (r.moderation_status = 'approved'::text)))) OR ((( SELECT auth.uid() AS uid) IS NOT NULL) AND (( SELECT public.is_restaurant_member(categories.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)))));



  create policy "courier_locations_visibility_restriction"
  on "public"."courier_locations"
  as restrictive
  for select
  to anon, authenticated
using (((( SELECT auth.uid() AS uid) IS NOT NULL) AND ((courier_id = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = courier_locations.order_id) AND ((o.customer_id = ( SELECT auth.uid() AS uid)) OR (o.courier_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_restaurant_member(o.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin))))))));



  create policy "courier_profiles_select"
  on "public"."courier_profiles"
  as permissive
  for select
  to authenticated
using (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "order_items_select_participants"
  on "public"."order_items"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_items.order_id) AND ((o.customer_id = ( SELECT auth.uid() AS uid)) OR ((o.courier_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
           FROM public.courier_profiles cp
          WHERE ((cp.user_id = ( SELECT auth.uid() AS uid)) AND (cp.status = 'active'::text))))) OR ( SELECT public.is_restaurant_member(o.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin))))));



  create policy "order_status_history_select_participants"
  on "public"."order_status_history"
  as permissive
  for select
  to authenticated
using ((EXISTS ( SELECT 1
   FROM public.orders o
  WHERE ((o.id = order_status_history.order_id) AND ((o.customer_id = ( SELECT auth.uid() AS uid)) OR ((o.courier_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
           FROM public.courier_profiles cp
          WHERE ((cp.user_id = ( SELECT auth.uid() AS uid)) AND (cp.status = 'active'::text))))) OR ( SELECT public.is_restaurant_member(o.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin))))));



  create policy "orders_select_participants"
  on "public"."orders"
  as permissive
  for select
  to authenticated
using (((customer_id = ( SELECT auth.uid() AS uid)) OR ((courier_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.courier_profiles cp
  WHERE ((cp.user_id = ( SELECT auth.uid() AS uid)) AND (cp.status = 'active'::text))))) OR ( SELECT public.is_restaurant_member(orders.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "platform_admins_select"
  on "public"."platform_admins"
  as permissive
  for select
  to authenticated
using (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "products_member_delete"
  on "public"."products"
  as permissive
  for delete
  to authenticated
using ((( SELECT public.has_restaurant_role(products.restaurant_id, ARRAY['owner'::text, 'manager'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "products_member_insert"
  on "public"."products"
  as permissive
  for insert
  to authenticated
with check ((( SELECT public.has_restaurant_role(products.restaurant_id, ARRAY['owner'::text, 'manager'::text, 'staff'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "products_member_update"
  on "public"."products"
  as permissive
  for update
  to authenticated
using ((( SELECT public.has_restaurant_role(products.restaurant_id, ARRAY['owner'::text, 'manager'::text, 'staff'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)))
with check ((( SELECT public.has_restaurant_role(products.restaurant_id, ARRAY['owner'::text, 'manager'::text, 'staff'::text]) AS has_restaurant_role) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "products_public_read"
  on "public"."products"
  as permissive
  for select
  to anon, authenticated
using (((EXISTS ( SELECT 1
   FROM public.restaurants r
  WHERE ((r.id = products.restaurant_id) AND (r.moderation_status = 'approved'::text) AND (products.is_available = true)))) OR ((( SELECT auth.uid() AS uid) IS NOT NULL) AND (( SELECT public.is_restaurant_member(products.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)))));



  create policy "products_visibility_restriction"
  on "public"."products"
  as restrictive
  for select
  to anon, authenticated
using ((((is_available = true) AND (EXISTS ( SELECT 1
   FROM public.restaurants r
  WHERE ((r.id = products.restaurant_id) AND (r.moderation_status = 'approved'::text))))) OR ((( SELECT auth.uid() AS uid) IS NOT NULL) AND (( SELECT public.is_restaurant_member(products.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)))));



  create policy "profiles_update_own_restriction"
  on "public"."profiles"
  as restrictive
  for update
  to authenticated
using ((id = ( SELECT auth.uid() AS uid)))
with check ((id = ( SELECT auth.uid() AS uid)));



  create policy "profiles_visibility_restriction"
  on "public"."profiles"
  as restrictive
  for select
  to authenticated
using (((id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_platform_admin() AS is_platform_admin) OR (EXISTS ( SELECT 1
   FROM public.orders o
  WHERE (((o.customer_id = profiles.id) OR (o.courier_id = profiles.id)) AND ((o.customer_id = ( SELECT auth.uid() AS uid)) OR (o.courier_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_restaurant_member(o.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin))))) OR (EXISTS ( SELECT 1
   FROM (public.restaurant_members current_member
     JOIN public.restaurant_members target_member ON ((target_member.restaurant_id = current_member.restaurant_id)))
  WHERE ((current_member.user_id = ( SELECT auth.uid() AS uid)) AND (target_member.user_id = profiles.id))))));



  create policy "restaurant_applications_insert"
  on "public"."restaurant_applications"
  as permissive
  for insert
  to authenticated
with check (((applicant_id = ( SELECT auth.uid() AS uid)) AND (status = 'pending'::text) AND (reviewed_by IS NULL) AND (reviewed_at IS NULL) AND (restaurant_id IS NULL)));



  create policy "restaurant_applications_select"
  on "public"."restaurant_applications"
  as permissive
  for select
  to authenticated
using (((applicant_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "restaurant_members_select"
  on "public"."restaurant_members"
  as permissive
  for select
  to authenticated
using (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_restaurant_member(restaurant_members.restaurant_id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));



  create policy "restaurants_anon_approved_only"
  on "public"."restaurants"
  as restrictive
  for select
  to anon
using ((moderation_status = 'approved'::text));



  create policy "restaurants_authenticated_visibility"
  on "public"."restaurants"
  as restrictive
  for select
  to authenticated
using (((moderation_status = 'approved'::text) OR ( SELECT public.is_restaurant_member(restaurants.id) AS is_restaurant_member) OR ( SELECT public.is_platform_admin() AS is_platform_admin)));


CREATE TRIGGER trg_record_order_status_change AFTER INSERT OR UPDATE OF status ON public.orders FOR EACH ROW EXECUTE FUNCTION public.record_order_status_change();
