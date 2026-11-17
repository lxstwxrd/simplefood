


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."order_status" AS ENUM (
    'pending',
    'accepted',
    'cooking',
    'delivering',
    'delivered',
    'cancelled'
);


ALTER TYPE "public"."order_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;


ALTER FUNCTION "public"."handle_new_user"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."has_restaurant_role"("p_restaurant_id" "uuid", "p_roles" "text"[]) RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.restaurant_members rm
        WHERE rm.restaurant_id = p_restaurant_id
          AND rm.user_id = (SELECT auth.uid())
          AND rm.role = ANY (p_roles)
    );
$$;


ALTER FUNCTION "public"."has_restaurant_role"("p_restaurant_id" "uuid", "p_roles" "text"[]) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_platform_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.platform_admins pa
        WHERE pa.user_id = (SELECT auth.uid())
    );
$$;


ALTER FUNCTION "public"."is_platform_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_restaurant_member"("p_restaurant_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.restaurant_members rm
        WHERE rm.restaurant_id = p_restaurant_id
          AND rm.user_id = (SELECT auth.uid())
    );
$$;


ALTER FUNCTION "public"."is_restaurant_member"("p_restaurant_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."record_order_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
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
$$;


ALTER FUNCTION "public"."record_order_status_change"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."categories" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "restaurant_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "sort_order" integer DEFAULT 0,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."categories" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."courier_locations" (
    "courier_id" "uuid" NOT NULL,
    "order_id" "uuid",
    "lat" numeric(10,7) NOT NULL,
    "lng" numeric(10,7) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."courier_locations" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."courier_profiles" (
    "user_id" "uuid" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "is_available" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "courier_available_only_when_active" CHECK ((("is_available" = false) OR ("status" = 'active'::"text"))),
    CONSTRAINT "courier_profiles_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'active'::"text", 'suspended'::"text", 'rejected'::"text"])))
);


ALTER TABLE "public"."courier_profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_items" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "product_id" "uuid" NOT NULL,
    "quantity" integer NOT NULL,
    "price_at_purchase" numeric(10,2) NOT NULL,
    "restaurant_id" "uuid" NOT NULL,
    "product_name" "text" NOT NULL,
    "product_description" "text",
    "product_image_url" "text",
    "unit_price" numeric(12,2) NOT NULL,
    CONSTRAINT "order_items_quantity_check" CHECK (("quantity" > 0)),
    CONSTRAINT "order_items_unit_price_nonnegative_check" CHECK (("unit_price" >= (0)::numeric))
);


ALTER TABLE "public"."order_items" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."order_status_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "order_id" "uuid" NOT NULL,
    "old_status" "public"."order_status",
    "new_status" "public"."order_status" NOT NULL,
    "changed_by" "uuid",
    "comment" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."order_status_history" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."orders" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "customer_id" "uuid" NOT NULL,
    "restaurant_id" "uuid" NOT NULL,
    "courier_id" "uuid",
    "status" "public"."order_status" DEFAULT 'pending'::"public"."order_status",
    "total_price" numeric(10,2) NOT NULL,
    "delivery_address" "text" NOT NULL,
    "delivery_lat" numeric(10,7),
    "delivery_lng" numeric(10,7),
    "payment_method" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "orders_delivery_latitude_check" CHECK ((("delivery_lat" IS NULL) OR (("delivery_lat" >= ('-90'::integer)::numeric) AND ("delivery_lat" <= (90)::numeric)))),
    CONSTRAINT "orders_delivery_longitude_check" CHECK ((("delivery_lng" IS NULL) OR (("delivery_lng" >= ('-180'::integer)::numeric) AND ("delivery_lng" <= (180)::numeric)))),
    CONSTRAINT "orders_total_price_nonnegative_check" CHECK (("total_price" >= (0)::numeric))
);


ALTER TABLE "public"."orders" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."platform_admins" (
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid"
);


ALTER TABLE "public"."platform_admins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."products" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "restaurant_id" "uuid" NOT NULL,
    "category_id" "uuid" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "price" numeric(10,2) NOT NULL,
    "image_url" "text",
    "is_available" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "products_price_nonnegative_check" CHECK (("price" >= (0)::numeric))
);


ALTER TABLE "public"."products" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "role" "text" DEFAULT 'customer'::"text",
    "full_name" "text",
    "phone" "text",
    "avatar_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "profiles_role_check" CHECK (("role" = ANY (ARRAY['customer'::"text", 'restaurant_admin'::"text", 'courier'::"text"])))
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."restaurant_applications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "applicant_id" "uuid" NOT NULL,
    "restaurant_id" "uuid",
    "restaurant_name" "text" NOT NULL,
    "description" "text",
    "address" "text" NOT NULL,
    "contact_phone" "text" NOT NULL,
    "status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "moderation_comment" "text",
    "reviewed_by" "uuid",
    "reviewed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "application_review_consistency_check" CHECK (((("status" = 'pending'::"text") AND ("reviewed_by" IS NULL) AND ("reviewed_at" IS NULL)) OR (("status" <> 'pending'::"text") AND ("reviewed_at" IS NOT NULL)))),
    CONSTRAINT "restaurant_applications_status_check" CHECK (("status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text", 'withdrawn'::"text"])))
);


ALTER TABLE "public"."restaurant_applications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."restaurant_members" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "restaurant_id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "role" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "created_by" "uuid",
    CONSTRAINT "restaurant_members_role_check" CHECK (("role" = ANY (ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"])))
);


ALTER TABLE "public"."restaurant_members" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."restaurants" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "owner_id" "uuid",
    "name" "text" NOT NULL,
    "description" "text",
    "image_url" "text",
    "address" "text",
    "rating" numeric(2,1) DEFAULT 0.0,
    "is_active" boolean DEFAULT true,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "latitude" numeric(9,6),
    "longitude" numeric(9,6),
    "moderation_status" "text" DEFAULT 'pending'::"text" NOT NULL,
    "is_accepting_orders" boolean DEFAULT false NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "restaurants_latitude_check" CHECK ((("latitude" IS NULL) OR (("latitude" >= ('-90'::integer)::numeric) AND ("latitude" <= (90)::numeric)))),
    CONSTRAINT "restaurants_longitude_check" CHECK ((("longitude" IS NULL) OR (("longitude" >= ('-180'::integer)::numeric) AND ("longitude" <= (180)::numeric)))),
    CONSTRAINT "restaurants_moderation_status_check" CHECK (("moderation_status" = ANY (ARRAY['pending'::"text", 'approved'::"text", 'rejected'::"text", 'suspended'::"text"]))),
    CONSTRAINT "restaurants_rating_check" CHECK ((("rating" IS NULL) OR (("rating" >= (0)::numeric) AND ("rating" <= (5)::numeric))))
);


ALTER TABLE "public"."restaurants" OWNER TO "postgres";


ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_id_restaurant_unique" UNIQUE ("id", "restaurant_id");



ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."courier_locations"
    ADD CONSTRAINT "courier_locations_pkey" PRIMARY KEY ("courier_id");



ALTER TABLE ONLY "public"."courier_profiles"
    ADD CONSTRAINT "courier_profiles_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."order_status_history"
    ADD CONSTRAINT "order_status_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_id_restaurant_unique" UNIQUE ("id", "restaurant_id");



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."platform_admins"
    ADD CONSTRAINT "platform_admins_pkey" PRIMARY KEY ("user_id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_id_restaurant_unique" UNIQUE ("id", "restaurant_id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."restaurant_applications"
    ADD CONSTRAINT "restaurant_applications_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."restaurant_members"
    ADD CONSTRAINT "restaurant_members_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."restaurant_members"
    ADD CONSTRAINT "restaurant_members_unique_user" UNIQUE ("restaurant_id", "user_id");



ALTER TABLE ONLY "public"."restaurants"
    ADD CONSTRAINT "restaurants_pkey" PRIMARY KEY ("id");



CREATE UNIQUE INDEX "idx_categories_restaurant_name" ON "public"."categories" USING "btree" ("restaurant_id", "lower"("name"));



CREATE INDEX "idx_categories_restaurant_sort" ON "public"."categories" USING "btree" ("restaurant_id", "sort_order");



CREATE INDEX "idx_courier_profiles_status" ON "public"."courier_profiles" USING "btree" ("status");



CREATE INDEX "idx_order_items_order" ON "public"."order_items" USING "btree" ("order_id");



CREATE INDEX "idx_order_items_product" ON "public"."order_items" USING "btree" ("product_id");



CREATE INDEX "idx_order_items_restaurant" ON "public"."order_items" USING "btree" ("restaurant_id");



CREATE INDEX "idx_order_status_history_changed_by" ON "public"."order_status_history" USING "btree" ("changed_by") WHERE ("changed_by" IS NOT NULL);



CREATE INDEX "idx_order_status_history_order_created" ON "public"."order_status_history" USING "btree" ("order_id", "created_at" DESC);



CREATE INDEX "idx_orders_courier_status" ON "public"."orders" USING "btree" ("courier_id", "status") WHERE ("courier_id" IS NOT NULL);



CREATE INDEX "idx_orders_customer_created" ON "public"."orders" USING "btree" ("customer_id", "created_at" DESC);



CREATE INDEX "idx_orders_restaurant_status_created" ON "public"."orders" USING "btree" ("restaurant_id", "status", "created_at" DESC);



CREATE INDEX "idx_products_category" ON "public"."products" USING "btree" ("category_id");



CREATE INDEX "idx_products_restaurant_available" ON "public"."products" USING "btree" ("restaurant_id", "is_available");



CREATE INDEX "idx_restaurant_applications_applicant" ON "public"."restaurant_applications" USING "btree" ("applicant_id", "created_at" DESC);



CREATE INDEX "idx_restaurant_applications_restaurant" ON "public"."restaurant_applications" USING "btree" ("restaurant_id") WHERE ("restaurant_id" IS NOT NULL);



CREATE INDEX "idx_restaurant_applications_status_created" ON "public"."restaurant_applications" USING "btree" ("status", "created_at" DESC);



CREATE INDEX "idx_restaurant_members_restaurant_role" ON "public"."restaurant_members" USING "btree" ("restaurant_id", "role");



CREATE INDEX "idx_restaurant_members_user" ON "public"."restaurant_members" USING "btree" ("user_id", "restaurant_id");



CREATE INDEX "idx_restaurants_accepting_orders" ON "public"."restaurants" USING "btree" ("is_accepting_orders") WHERE ("is_accepting_orders" = true);



CREATE INDEX "idx_restaurants_moderation_status" ON "public"."restaurants" USING "btree" ("moderation_status");



CREATE UNIQUE INDEX "restaurant_applications_one_pending_per_user" ON "public"."restaurant_applications" USING "btree" ("applicant_id") WHERE ("status" = 'pending'::"text");



CREATE OR REPLACE TRIGGER "trg_record_order_status_change" AFTER INSERT OR UPDATE OF "status" ON "public"."orders" FOR EACH ROW EXECUTE FUNCTION "public"."record_order_status_change"();



ALTER TABLE ONLY "public"."categories"
    ADD CONSTRAINT "categories_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."courier_locations"
    ADD CONSTRAINT "courier_locations_courier_id_fkey" FOREIGN KEY ("courier_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."courier_locations"
    ADD CONSTRAINT "courier_locations_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."courier_profiles"
    ADD CONSTRAINT "courier_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_order_restaurant_fk" FOREIGN KEY ("order_id", "restaurant_id") REFERENCES "public"."orders"("id", "restaurant_id");



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."order_items"
    ADD CONSTRAINT "order_items_product_restaurant_fk" FOREIGN KEY ("product_id", "restaurant_id") REFERENCES "public"."products"("id", "restaurant_id");



ALTER TABLE ONLY "public"."order_status_history"
    ADD CONSTRAINT "order_status_history_changed_by_fkey" FOREIGN KEY ("changed_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."order_status_history"
    ADD CONSTRAINT "order_status_history_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "public"."orders"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_courier_id_fkey" FOREIGN KEY ("courier_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."orders"
    ADD CONSTRAINT "orders_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."platform_admins"
    ADD CONSTRAINT "platform_admins_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."platform_admins"
    ADD CONSTRAINT "platform_admins_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_category_restaurant_fk" FOREIGN KEY ("category_id", "restaurant_id") REFERENCES "public"."categories"("id", "restaurant_id");



ALTER TABLE ONLY "public"."products"
    ADD CONSTRAINT "products_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."restaurant_applications"
    ADD CONSTRAINT "restaurant_applications_applicant_id_fkey" FOREIGN KEY ("applicant_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."restaurant_applications"
    ADD CONSTRAINT "restaurant_applications_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."restaurant_applications"
    ADD CONSTRAINT "restaurant_applications_reviewed_by_fkey" FOREIGN KEY ("reviewed_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."restaurant_members"
    ADD CONSTRAINT "restaurant_members_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."restaurant_members"
    ADD CONSTRAINT "restaurant_members_restaurant_id_fkey" FOREIGN KEY ("restaurant_id") REFERENCES "public"."restaurants"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."restaurant_members"
    ADD CONSTRAINT "restaurant_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."restaurants"
    ADD CONSTRAINT "restaurants_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



CREATE POLICY "Anyone can view courier locations" ON "public"."courier_locations" FOR SELECT USING (true);



CREATE POLICY "Categories are viewable by everyone" ON "public"."categories" FOR SELECT USING (true);



CREATE POLICY "Products are viewable by everyone" ON "public"."products" FOR SELECT USING (true);



CREATE POLICY "Public profiles are viewable by everyone" ON "public"."profiles" FOR SELECT USING (true);



CREATE POLICY "Restaurants are viewable by everyone" ON "public"."restaurants" FOR SELECT USING (true);



CREATE POLICY "Users can update own profile" ON "public"."profiles" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Users can view own orders" ON "public"."orders" FOR SELECT USING (("auth"."uid"() = "customer_id"));



ALTER TABLE "public"."categories" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "categories_member_delete" ON "public"."categories" FOR DELETE TO "authenticated" USING ((( SELECT "public"."has_restaurant_role"("categories"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



CREATE POLICY "categories_member_insert" ON "public"."categories" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "public"."has_restaurant_role"("categories"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



CREATE POLICY "categories_member_update" ON "public"."categories" FOR UPDATE TO "authenticated" USING ((( SELECT "public"."has_restaurant_role"("categories"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin"))) WITH CHECK ((( SELECT "public"."has_restaurant_role"("categories"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



CREATE POLICY "categories_public_read" ON "public"."categories" FOR SELECT TO "authenticated", "anon" USING (((EXISTS ( SELECT 1
   FROM "public"."restaurants" "r"
  WHERE (("r"."id" = "categories"."restaurant_id") AND ("r"."moderation_status" = 'approved'::"text")))) OR ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (( SELECT "public"."is_restaurant_member"("categories"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")))));



CREATE POLICY "categories_visibility_restriction" ON "public"."categories" AS RESTRICTIVE FOR SELECT TO "authenticated", "anon" USING (((EXISTS ( SELECT 1
   FROM "public"."restaurants" "r"
  WHERE (("r"."id" = "categories"."restaurant_id") AND ("r"."moderation_status" = 'approved'::"text")))) OR ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (( SELECT "public"."is_restaurant_member"("categories"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")))));



ALTER TABLE "public"."courier_locations" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "courier_locations_visibility_restriction" ON "public"."courier_locations" AS RESTRICTIVE FOR SELECT TO "authenticated", "anon" USING (((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (("courier_id" = ( SELECT "auth"."uid"() AS "uid")) OR (EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "courier_locations"."order_id") AND (("o"."customer_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("o"."courier_id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_restaurant_member"("o"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin"))))))));



ALTER TABLE "public"."courier_profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "courier_profiles_select" ON "public"."courier_profiles" FOR SELECT TO "authenticated" USING ((("user_id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



ALTER TABLE "public"."order_items" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "order_items_select_participants" ON "public"."order_items" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_items"."order_id") AND (("o"."customer_id" = ( SELECT "auth"."uid"() AS "uid")) OR (("o"."courier_id" = ( SELECT "auth"."uid"() AS "uid")) AND (EXISTS ( SELECT 1
           FROM "public"."courier_profiles" "cp"
          WHERE (("cp"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("cp"."status" = 'active'::"text"))))) OR ( SELECT "public"."is_restaurant_member"("o"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin"))))));



ALTER TABLE "public"."order_status_history" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "order_status_history_select_participants" ON "public"."order_status_history" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE (("o"."id" = "order_status_history"."order_id") AND (("o"."customer_id" = ( SELECT "auth"."uid"() AS "uid")) OR (("o"."courier_id" = ( SELECT "auth"."uid"() AS "uid")) AND (EXISTS ( SELECT 1
           FROM "public"."courier_profiles" "cp"
          WHERE (("cp"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("cp"."status" = 'active'::"text"))))) OR ( SELECT "public"."is_restaurant_member"("o"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin"))))));



ALTER TABLE "public"."orders" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "orders_select_participants" ON "public"."orders" FOR SELECT TO "authenticated" USING ((("customer_id" = ( SELECT "auth"."uid"() AS "uid")) OR (("courier_id" = ( SELECT "auth"."uid"() AS "uid")) AND (EXISTS ( SELECT 1
   FROM "public"."courier_profiles" "cp"
  WHERE (("cp"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("cp"."status" = 'active'::"text"))))) OR ( SELECT "public"."is_restaurant_member"("orders"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



ALTER TABLE "public"."platform_admins" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "platform_admins_select" ON "public"."platform_admins" FOR SELECT TO "authenticated" USING ((("user_id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



ALTER TABLE "public"."products" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "products_member_delete" ON "public"."products" FOR DELETE TO "authenticated" USING ((( SELECT "public"."has_restaurant_role"("products"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



CREATE POLICY "products_member_insert" ON "public"."products" FOR INSERT TO "authenticated" WITH CHECK ((( SELECT "public"."has_restaurant_role"("products"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



CREATE POLICY "products_member_update" ON "public"."products" FOR UPDATE TO "authenticated" USING ((( SELECT "public"."has_restaurant_role"("products"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin"))) WITH CHECK ((( SELECT "public"."has_restaurant_role"("products"."restaurant_id", ARRAY['owner'::"text", 'manager'::"text", 'staff'::"text"]) AS "has_restaurant_role") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



CREATE POLICY "products_public_read" ON "public"."products" FOR SELECT TO "authenticated", "anon" USING (((EXISTS ( SELECT 1
   FROM "public"."restaurants" "r"
  WHERE (("r"."id" = "products"."restaurant_id") AND ("r"."moderation_status" = 'approved'::"text") AND ("products"."is_available" = true)))) OR ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (( SELECT "public"."is_restaurant_member"("products"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")))));



CREATE POLICY "products_visibility_restriction" ON "public"."products" AS RESTRICTIVE FOR SELECT TO "authenticated", "anon" USING (((("is_available" = true) AND (EXISTS ( SELECT 1
   FROM "public"."restaurants" "r"
  WHERE (("r"."id" = "products"."restaurant_id") AND ("r"."moderation_status" = 'approved'::"text"))))) OR ((( SELECT "auth"."uid"() AS "uid") IS NOT NULL) AND (( SELECT "public"."is_restaurant_member"("products"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")))));



ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "profiles_update_own_restriction" ON "public"."profiles" AS RESTRICTIVE FOR UPDATE TO "authenticated" USING (("id" = ( SELECT "auth"."uid"() AS "uid"))) WITH CHECK (("id" = ( SELECT "auth"."uid"() AS "uid")));



CREATE POLICY "profiles_visibility_restriction" ON "public"."profiles" AS RESTRICTIVE FOR SELECT TO "authenticated" USING ((("id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin") OR (EXISTS ( SELECT 1
   FROM "public"."orders" "o"
  WHERE ((("o"."customer_id" = "profiles"."id") OR ("o"."courier_id" = "profiles"."id")) AND (("o"."customer_id" = ( SELECT "auth"."uid"() AS "uid")) OR ("o"."courier_id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_restaurant_member"("o"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin"))))) OR (EXISTS ( SELECT 1
   FROM ("public"."restaurant_members" "current_member"
     JOIN "public"."restaurant_members" "target_member" ON (("target_member"."restaurant_id" = "current_member"."restaurant_id")))
  WHERE (("current_member"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("target_member"."user_id" = "profiles"."id"))))));



ALTER TABLE "public"."restaurant_applications" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "restaurant_applications_insert" ON "public"."restaurant_applications" FOR INSERT TO "authenticated" WITH CHECK ((("applicant_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("status" = 'pending'::"text") AND ("reviewed_by" IS NULL) AND ("reviewed_at" IS NULL) AND ("restaurant_id" IS NULL)));



CREATE POLICY "restaurant_applications_select" ON "public"."restaurant_applications" FOR SELECT TO "authenticated" USING ((("applicant_id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



ALTER TABLE "public"."restaurant_members" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "restaurant_members_select" ON "public"."restaurant_members" FOR SELECT TO "authenticated" USING ((("user_id" = ( SELECT "auth"."uid"() AS "uid")) OR ( SELECT "public"."is_restaurant_member"("restaurant_members"."restaurant_id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



ALTER TABLE "public"."restaurants" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "restaurants_anon_approved_only" ON "public"."restaurants" AS RESTRICTIVE FOR SELECT TO "anon" USING (("moderation_status" = 'approved'::"text"));



CREATE POLICY "restaurants_authenticated_visibility" ON "public"."restaurants" AS RESTRICTIVE FOR SELECT TO "authenticated" USING ((("moderation_status" = 'approved'::"text") OR ( SELECT "public"."is_restaurant_member"("restaurants"."id") AS "is_restaurant_member") OR ( SELECT "public"."is_platform_admin"() AS "is_platform_admin")));



GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."has_restaurant_role"("p_restaurant_id" "uuid", "p_roles" "text"[]) FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."has_restaurant_role"("p_restaurant_id" "uuid", "p_roles" "text"[]) TO "anon";
GRANT ALL ON FUNCTION "public"."has_restaurant_role"("p_restaurant_id" "uuid", "p_roles" "text"[]) TO "authenticated";
GRANT ALL ON FUNCTION "public"."has_restaurant_role"("p_restaurant_id" "uuid", "p_roles" "text"[]) TO "service_role";



REVOKE ALL ON FUNCTION "public"."is_platform_admin"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_platform_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_platform_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_platform_admin"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."is_restaurant_member"("p_restaurant_id" "uuid") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."is_restaurant_member"("p_restaurant_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_restaurant_member"("p_restaurant_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_restaurant_member"("p_restaurant_id" "uuid") TO "service_role";



REVOKE ALL ON FUNCTION "public"."record_order_status_change"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."record_order_status_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."record_order_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."record_order_status_change"() TO "service_role";



GRANT ALL ON TABLE "public"."categories" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."categories" TO "authenticated";
GRANT SELECT ON TABLE "public"."categories" TO "anon";



GRANT ALL ON TABLE "public"."courier_locations" TO "service_role";
GRANT SELECT ON TABLE "public"."courier_locations" TO "authenticated";



GRANT ALL ON TABLE "public"."courier_profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."courier_profiles" TO "authenticated";



GRANT ALL ON TABLE "public"."order_items" TO "service_role";
GRANT SELECT ON TABLE "public"."order_items" TO "authenticated";



GRANT ALL ON TABLE "public"."order_status_history" TO "service_role";
GRANT SELECT ON TABLE "public"."order_status_history" TO "authenticated";



GRANT ALL ON TABLE "public"."orders" TO "service_role";
GRANT SELECT ON TABLE "public"."orders" TO "authenticated";



GRANT ALL ON TABLE "public"."platform_admins" TO "service_role";
GRANT SELECT ON TABLE "public"."platform_admins" TO "authenticated";



GRANT ALL ON TABLE "public"."products" TO "service_role";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "public"."products" TO "authenticated";
GRANT SELECT ON TABLE "public"."products" TO "anon";



GRANT ALL ON TABLE "public"."profiles" TO "service_role";
GRANT SELECT ON TABLE "public"."profiles" TO "authenticated";



GRANT UPDATE("full_name") ON TABLE "public"."profiles" TO "authenticated";



GRANT UPDATE("phone") ON TABLE "public"."profiles" TO "authenticated";



GRANT UPDATE("avatar_url") ON TABLE "public"."profiles" TO "authenticated";



GRANT ALL ON TABLE "public"."restaurant_applications" TO "service_role";
GRANT SELECT,INSERT ON TABLE "public"."restaurant_applications" TO "authenticated";



GRANT ALL ON TABLE "public"."restaurant_members" TO "service_role";
GRANT SELECT ON TABLE "public"."restaurant_members" TO "authenticated";



GRANT ALL ON TABLE "public"."restaurants" TO "service_role";
GRANT SELECT ON TABLE "public"."restaurants" TO "authenticated";
GRANT SELECT ON TABLE "public"."restaurants" TO "anon";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







