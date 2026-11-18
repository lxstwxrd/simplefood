export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: '14.18';
  };
  public: {
    Tables: {
      categories: {
        Row: {
          created_at: string;
          id: string;
          name: string;
          restaurant_id: string;
          sort_order: number | null;
          updated_at: string;
        };
        Insert: {
          created_at?: string;
          id?: string;
          name: string;
          restaurant_id: string;
          sort_order?: number | null;
          updated_at?: string;
        };
        Update: {
          created_at?: string;
          id?: string;
          name?: string;
          restaurant_id?: string;
          sort_order?: number | null;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'categories_restaurant_id_fkey';
            columns: ['restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'restaurants';
            referencedColumns: ['id'];
          },
        ];
      };
      courier_locations: {
        Row: {
          courier_id: string;
          lat: number;
          lng: number;
          order_id: string | null;
          updated_at: string | null;
        };
        Insert: {
          courier_id: string;
          lat: number;
          lng: number;
          order_id?: string | null;
          updated_at?: string | null;
        };
        Update: {
          courier_id?: string;
          lat?: number;
          lng?: number;
          order_id?: string | null;
          updated_at?: string | null;
        };
        Relationships: [
          {
            foreignKeyName: 'courier_locations_courier_id_fkey';
            columns: ['courier_id'];
            isOneToOne: true;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'courier_locations_order_id_fkey';
            columns: ['order_id'];
            isOneToOne: false;
            referencedRelation: 'orders';
            referencedColumns: ['id'];
          },
        ];
      };
      courier_profiles: {
        Row: {
          created_at: string;
          is_available: boolean;
          status: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          is_available?: boolean;
          status?: string;
          updated_at?: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          is_available?: boolean;
          status?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'courier_profiles_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: true;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
        ];
      };
      order_items: {
        Row: {
          id: string;
          order_id: string;
          price_at_purchase: number;
          product_description: string | null;
          product_id: string;
          product_image_url: string | null;
          product_name: string;
          quantity: number;
          restaurant_id: string;
          unit_price: number;
        };
        Insert: {
          id?: string;
          order_id: string;
          price_at_purchase: number;
          product_description?: string | null;
          product_id: string;
          product_image_url?: string | null;
          product_name: string;
          quantity: number;
          restaurant_id: string;
          unit_price: number;
        };
        Update: {
          id?: string;
          order_id?: string;
          price_at_purchase?: number;
          product_description?: string | null;
          product_id?: string;
          product_image_url?: string | null;
          product_name?: string;
          quantity?: number;
          restaurant_id?: string;
          unit_price?: number;
        };
        Relationships: [
          {
            foreignKeyName: 'order_items_order_id_fkey';
            columns: ['order_id'];
            isOneToOne: false;
            referencedRelation: 'orders';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'order_items_order_restaurant_fk';
            columns: ['order_id', 'restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'orders';
            referencedColumns: ['id', 'restaurant_id'];
          },
          {
            foreignKeyName: 'order_items_product_id_fkey';
            columns: ['product_id'];
            isOneToOne: false;
            referencedRelation: 'products';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'order_items_product_restaurant_fk';
            columns: ['product_id', 'restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'products';
            referencedColumns: ['id', 'restaurant_id'];
          },
        ];
      };
      order_status_history: {
        Row: {
          changed_by: string | null;
          comment: string | null;
          created_at: string;
          id: string;
          new_status: Database['public']['Enums']['order_status'];
          old_status: Database['public']['Enums']['order_status'] | null;
          order_id: string;
        };
        Insert: {
          changed_by?: string | null;
          comment?: string | null;
          created_at?: string;
          id?: string;
          new_status: Database['public']['Enums']['order_status'];
          old_status?: Database['public']['Enums']['order_status'] | null;
          order_id: string;
        };
        Update: {
          changed_by?: string | null;
          comment?: string | null;
          created_at?: string;
          id?: string;
          new_status?: Database['public']['Enums']['order_status'];
          old_status?: Database['public']['Enums']['order_status'] | null;
          order_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'order_status_history_changed_by_fkey';
            columns: ['changed_by'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'order_status_history_order_id_fkey';
            columns: ['order_id'];
            isOneToOne: false;
            referencedRelation: 'orders';
            referencedColumns: ['id'];
          },
        ];
      };
      orders: {
        Row: {
          courier_id: string | null;
          created_at: string | null;
          customer_id: string;
          delivery_address: string;
          delivery_lat: number | null;
          delivery_lng: number | null;
          id: string;
          payment_method: string | null;
          restaurant_id: string;
          status: Database['public']['Enums']['order_status'];
          total_price: number;
          updated_at: string | null;
        };
        Insert: {
          courier_id?: string | null;
          created_at?: string | null;
          customer_id: string;
          delivery_address: string;
          delivery_lat?: number | null;
          delivery_lng?: number | null;
          id?: string;
          payment_method?: string | null;
          restaurant_id: string;
          status?: Database['public']['Enums']['order_status'];
          total_price: number;
          updated_at?: string | null;
        };
        Update: {
          courier_id?: string | null;
          created_at?: string | null;
          customer_id?: string;
          delivery_address?: string;
          delivery_lat?: number | null;
          delivery_lng?: number | null;
          id?: string;
          payment_method?: string | null;
          restaurant_id?: string;
          status?: Database['public']['Enums']['order_status'];
          total_price?: number;
          updated_at?: string | null;
        };
        Relationships: [
          {
            foreignKeyName: 'orders_courier_id_fkey';
            columns: ['courier_id'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'orders_customer_id_fkey';
            columns: ['customer_id'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'orders_restaurant_id_fkey';
            columns: ['restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'restaurants';
            referencedColumns: ['id'];
          },
        ];
      };
      platform_admins: {
        Row: {
          created_at: string;
          created_by: string | null;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          created_by?: string | null;
          user_id: string;
        };
        Update: {
          created_at?: string;
          created_by?: string | null;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'platform_admins_created_by_fkey';
            columns: ['created_by'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'platform_admins_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: true;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
        ];
      };
      products: {
        Row: {
          category_id: string;
          created_at: string | null;
          description: string | null;
          id: string;
          image_url: string | null;
          is_available: boolean | null;
          name: string;
          price: number;
          restaurant_id: string;
          updated_at: string;
        };
        Insert: {
          category_id: string;
          created_at?: string | null;
          description?: string | null;
          id?: string;
          image_url?: string | null;
          is_available?: boolean | null;
          name: string;
          price: number;
          restaurant_id: string;
          updated_at?: string;
        };
        Update: {
          category_id?: string;
          created_at?: string | null;
          description?: string | null;
          id?: string;
          image_url?: string | null;
          is_available?: boolean | null;
          name?: string;
          price?: number;
          restaurant_id?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'products_category_id_fkey';
            columns: ['category_id'];
            isOneToOne: false;
            referencedRelation: 'categories';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'products_category_restaurant_fk';
            columns: ['category_id', 'restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'categories';
            referencedColumns: ['id', 'restaurant_id'];
          },
          {
            foreignKeyName: 'products_restaurant_id_fkey';
            columns: ['restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'restaurants';
            referencedColumns: ['id'];
          },
        ];
      };
      profiles: {
        Row: {
          avatar_url: string | null;
          created_at: string | null;
          full_name: string | null;
          id: string;
          phone: string | null;
          role: string | null;
        };
        Insert: {
          avatar_url?: string | null;
          created_at?: string | null;
          full_name?: string | null;
          id: string;
          phone?: string | null;
          role?: string | null;
        };
        Update: {
          avatar_url?: string | null;
          created_at?: string | null;
          full_name?: string | null;
          id?: string;
          phone?: string | null;
          role?: string | null;
        };
        Relationships: [];
      };
      restaurant_applications: {
        Row: {
          address: string;
          applicant_id: string;
          contact_phone: string;
          created_at: string;
          description: string | null;
          id: string;
          moderation_comment: string | null;
          restaurant_id: string | null;
          restaurant_name: string;
          reviewed_at: string | null;
          reviewed_by: string | null;
          status: string;
          updated_at: string;
        };
        Insert: {
          address: string;
          applicant_id: string;
          contact_phone: string;
          created_at?: string;
          description?: string | null;
          id?: string;
          moderation_comment?: string | null;
          restaurant_id?: string | null;
          restaurant_name: string;
          reviewed_at?: string | null;
          reviewed_by?: string | null;
          status?: string;
          updated_at?: string;
        };
        Update: {
          address?: string;
          applicant_id?: string;
          contact_phone?: string;
          created_at?: string;
          description?: string | null;
          id?: string;
          moderation_comment?: string | null;
          restaurant_id?: string | null;
          restaurant_name?: string;
          reviewed_at?: string | null;
          reviewed_by?: string | null;
          status?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'restaurant_applications_applicant_id_fkey';
            columns: ['applicant_id'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'restaurant_applications_restaurant_id_fkey';
            columns: ['restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'restaurants';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'restaurant_applications_reviewed_by_fkey';
            columns: ['reviewed_by'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
        ];
      };
      restaurant_members: {
        Row: {
          created_at: string;
          created_by: string | null;
          id: string;
          restaurant_id: string;
          role: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          created_by?: string | null;
          id?: string;
          restaurant_id: string;
          role: string;
          user_id: string;
        };
        Update: {
          created_at?: string;
          created_by?: string | null;
          id?: string;
          restaurant_id?: string;
          role?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'restaurant_members_created_by_fkey';
            columns: ['created_by'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'restaurant_members_restaurant_id_fkey';
            columns: ['restaurant_id'];
            isOneToOne: false;
            referencedRelation: 'restaurants';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'restaurant_members_user_id_fkey';
            columns: ['user_id'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
        ];
      };
      restaurants: {
        Row: {
          address: string | null;
          created_at: string | null;
          description: string | null;
          id: string;
          image_url: string | null;
          is_accepting_orders: boolean;
          is_active: boolean | null;
          latitude: number | null;
          longitude: number | null;
          moderation_status: string;
          name: string;
          owner_id: string | null;
          rating: number | null;
          updated_at: string;
        };
        Insert: {
          address?: string | null;
          created_at?: string | null;
          description?: string | null;
          id?: string;
          image_url?: string | null;
          is_accepting_orders?: boolean;
          is_active?: boolean | null;
          latitude?: number | null;
          longitude?: number | null;
          moderation_status?: string;
          name: string;
          owner_id?: string | null;
          rating?: number | null;
          updated_at?: string;
        };
        Update: {
          address?: string | null;
          created_at?: string | null;
          description?: string | null;
          id?: string;
          image_url?: string | null;
          is_accepting_orders?: boolean;
          is_active?: boolean | null;
          latitude?: number | null;
          longitude?: number | null;
          moderation_status?: string;
          name?: string;
          owner_id?: string | null;
          rating?: number | null;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'restaurants_owner_id_fkey';
            columns: ['owner_id'];
            isOneToOne: false;
            referencedRelation: 'profiles';
            referencedColumns: ['id'];
          },
        ];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      has_restaurant_role: {
        Args: { p_restaurant_id: string; p_roles: string[] };
        Returns: boolean;
      };
      is_platform_admin: { Args: never; Returns: boolean };
      is_restaurant_member: {
        Args: { p_restaurant_id: string };
        Returns: boolean;
      };
    };
    Enums: {
      order_status: 'pending' | 'accepted' | 'cooking' | 'delivering' | 'delivered' | 'cancelled';
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>;

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, 'public'>];

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])[TableName] extends {
      Row: infer R;
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
    ? (DefaultSchema['Tables'] & DefaultSchema['Views'])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R;
      }
      ? R
      : never
    : never;

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    keyof DefaultSchema['Tables'] | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Insert: infer I;
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I;
      }
      ? I
      : never
    : never;

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    keyof DefaultSchema['Tables'] | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Update: infer U;
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U;
      }
      ? U
      : never
    : never;

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    keyof DefaultSchema['Enums'] | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums']
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums'][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema['Enums']
    ? DefaultSchema['Enums'][DefaultSchemaEnumNameOrOptions]
    : never;

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    keyof DefaultSchema['CompositeTypes'] | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes']
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes'][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema['CompositeTypes']
    ? DefaultSchema['CompositeTypes'][PublicCompositeTypeNameOrOptions]
    : never;

export const Constants = {
  public: {
    Enums: {
      order_status: ['pending', 'accepted', 'cooking', 'delivering', 'delivered', 'cancelled'],
    },
  },
} as const;
