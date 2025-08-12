-- Location: supabase/migrations/20250810154634_animebytes_complete_schema.sql
-- Schema Analysis: Fresh project - no existing tables
-- Integration Type: Complete new schema creation
-- Dependencies: None - creating complete system from scratch

-- 1. Create Custom Types
CREATE TYPE public.user_role AS ENUM ('admin', 'premium_user', 'regular_user');
CREATE TYPE public.story_status AS ENUM ('draft', 'published', 'featured', 'archived');
CREATE TYPE public.interaction_type AS ENUM ('like', 'save', 'share', 'view');
CREATE TYPE public.notification_type AS ENUM ('new_story', 'trending_update', 'favorite_anime', 'system');

-- 2. Core User Management Table (References auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    role public.user_role DEFAULT 'regular_user'::public.user_role,
    is_active BOOLEAN DEFAULT true,
    daily_streak INTEGER DEFAULT 0,
    last_login_date DATE,
    preferred_genres TEXT[] DEFAULT '{}',
    favorite_characters TEXT[] DEFAULT '{}',
    push_notifications_enabled BOOLEAN DEFAULT true,
    dark_mode_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Anime Tags/Categories Management
CREATE TABLE public.anime_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    display_name TEXT NOT NULL,
    description TEXT,
    icon_emoji TEXT DEFAULT '📺',
    is_trending BOOLEAN DEFAULT false,
    is_system_tag BOOLEAN DEFAULT false,
    usage_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Anime Stories/Content Management
CREATE TABLE public.anime_stories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    summary TEXT NOT NULL,
    content TEXT,
    image_url TEXT,
    author_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    status public.story_status DEFAULT 'published'::public.story_status,
    view_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    save_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    is_trending BOOLEAN DEFAULT false,
    published_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Story-Tag Relationships (Many-to-Many)
CREATE TABLE public.story_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    story_id UUID REFERENCES public.anime_stories(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES public.anime_tags(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(story_id, tag_id)
);

-- 6. User Interactions with Stories
CREATE TABLE public.user_story_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    story_id UUID REFERENCES public.anime_stories(id) ON DELETE CASCADE,
    interaction_type public.interaction_type NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, story_id, interaction_type)
);

-- 7. User Preferences and Personalization
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    preferred_tags UUID[] DEFAULT '{}',
    blocked_tags UUID[] DEFAULT '{}',
    notification_settings JSONB DEFAULT '{"new_stories": true, "trending": true, "favorites": true}'::jsonb,
    reading_preferences JSONB DEFAULT '{"font_size": "medium", "reading_speed": "normal"}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- 8. Notifications System
CREATE TABLE public.user_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type public.notification_type NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT false,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 9. Essential Indexes for Performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_anime_stories_status ON public.anime_stories(status);
CREATE INDEX idx_anime_stories_published_at ON public.anime_stories(published_at DESC);
CREATE INDEX idx_anime_stories_trending ON public.anime_stories(is_trending) WHERE is_trending = true;
CREATE INDEX idx_anime_stories_featured ON public.anime_stories(is_featured) WHERE is_featured = true;
CREATE INDEX idx_anime_tags_trending ON public.anime_tags(is_trending) WHERE is_trending = true;
CREATE INDEX idx_story_tags_story_id ON public.story_tags(story_id);
CREATE INDEX idx_story_tags_tag_id ON public.story_tags(tag_id);
CREATE INDEX idx_user_story_interactions_user_id ON public.user_story_interactions(user_id);
CREATE INDEX idx_user_story_interactions_story_id ON public.user_story_interactions(story_id);
CREATE INDEX idx_user_story_interactions_type ON public.user_story_interactions(interaction_type);
CREATE INDEX idx_user_notifications_user_id ON public.user_notifications(user_id);
CREATE INDEX idx_user_notifications_unread ON public.user_notifications(user_id, is_read) WHERE is_read = false;

-- 10. Enable Row Level Security
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anime_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.anime_stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.story_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_story_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

-- 11. RLS Policies Using Corrected Patterns

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for anime_tags
CREATE POLICY "public_can_read_anime_tags"
ON public.anime_tags
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_anime_tags"
ON public.anime_tags
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Pattern 4: Public read, private write for anime_stories
CREATE POLICY "public_can_read_published_stories"
ON public.anime_stories
FOR SELECT
TO public
USING (status = 'published' OR status = 'featured');

CREATE POLICY "authors_manage_own_stories"
ON public.anime_stories
FOR ALL
TO authenticated
USING (author_id = auth.uid())
WITH CHECK (author_id = auth.uid());

CREATE POLICY "admins_manage_all_stories"
ON public.anime_stories
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- Pattern 2: Simple user ownership for user interactions
CREATE POLICY "users_manage_own_interactions"
ON public.user_story_interactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for user preferences
CREATE POLICY "users_manage_own_preferences"
ON public.user_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for notifications
CREATE POLICY "users_manage_own_notifications"
ON public.user_notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for story_tags
CREATE POLICY "public_can_read_story_tags"
ON public.story_tags
FOR SELECT
TO public
USING (true);

CREATE POLICY "authenticated_manage_story_tags"
ON public.story_tags
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.anime_stories s
        WHERE s.id = story_id AND s.author_id = auth.uid()
    ) OR
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.anime_stories s
        WHERE s.id = story_id AND s.author_id = auth.uid()
    ) OR
    EXISTS (
        SELECT 1 FROM public.user_profiles up
        WHERE up.id = auth.uid() AND up.role = 'admin'
    )
);

-- 12. Automatic User Profile Creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'role', 'regular_user')::public.user_role
    );
    RETURN NEW;
END;
$$;

-- Create trigger for automatic profile creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 13. Update Functions for Counts
CREATE OR REPLACE FUNCTION public.update_story_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Update story interaction counts
    IF TG_OP = 'INSERT' THEN
        UPDATE public.anime_stories
        SET
            like_count = CASE WHEN NEW.interaction_type = 'like' THEN like_count + 1 ELSE like_count END,
            save_count = CASE WHEN NEW.interaction_type = 'save' THEN save_count + 1 ELSE save_count END,
            share_count = CASE WHEN NEW.interaction_type = 'share' THEN share_count + 1 ELSE share_count END,
            view_count = CASE WHEN NEW.interaction_type = 'view' THEN view_count + 1 ELSE view_count END
        WHERE id = NEW.story_id;
        RETURN NEW;
    END IF;
    
    IF TG_OP = 'DELETE' THEN
        UPDATE public.anime_stories
        SET
            like_count = CASE WHEN OLD.interaction_type = 'like' THEN GREATEST(like_count - 1, 0) ELSE like_count END,
            save_count = CASE WHEN OLD.interaction_type = 'save' THEN GREATEST(save_count - 1, 0) ELSE save_count END,
            share_count = CASE WHEN OLD.interaction_type = 'share' THEN GREATEST(share_count - 1, 0) ELSE share_count END
        WHERE id = OLD.story_id;
        RETURN OLD;
    END IF;
    
    RETURN NULL;
END;
$$;

-- Create trigger for updating story stats
CREATE TRIGGER update_story_stats_trigger
    AFTER INSERT OR DELETE ON public.user_story_interactions
    FOR EACH ROW EXECUTE FUNCTION public.update_story_stats();

-- 14. Mock Data for Development and Preview
DO $$
DECLARE
    admin_user_id UUID := gen_random_uuid();
    regular_user_id UUID := gen_random_uuid();
    author_user_id UUID := gen_random_uuid();
    
    -- Story IDs
    story1_id UUID := gen_random_uuid();
    story2_id UUID := gen_random_uuid();
    story3_id UUID := gen_random_uuid();
    story4_id UUID := gen_random_uuid();
    story5_id UUID := gen_random_uuid();
    
    -- Tag IDs
    tag_demon_slayer UUID := gen_random_uuid();
    tag_attack_titan UUID := gen_random_uuid();
    tag_jujutsu_kaisen UUID := gen_random_uuid();
    tag_chainsaw_man UUID := gen_random_uuid();
    tag_one_piece UUID := gen_random_uuid();
    tag_news UUID := gen_random_uuid();
    tag_review UUID := gen_random_uuid();
    tag_episode UUID := gen_random_uuid();
BEGIN
    -- Create complete auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@animebytes.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (regular_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'user@animebytes.com', crypt('user123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Anime Fan", "role": "regular_user"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (author_user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'author@animebytes.com', crypt('author123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Story Writer", "role": "premium_user"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Insert anime tags
    INSERT INTO public.anime_tags (id, name, display_name, description, icon_emoji, is_trending, is_system_tag, usage_count) VALUES
        (tag_demon_slayer, 'demon-slayer', 'Demon Slayer', 'Updates about Demon Slayer anime and manga', '⚔️', true, false, 15),
        (tag_attack_titan, 'attack-on-titan', 'Attack on Titan', 'News and updates from Attack on Titan', '🏛️', true, false, 12),
        (tag_jujutsu_kaisen, 'jujutsu-kaisen', 'Jujutsu Kaisen', 'Latest from Jujutsu Kaisen series', '👻', true, false, 18),
        (tag_chainsaw_man, 'chainsaw-man', 'Chainsaw Man', 'Chainsaw Man anime and manga news', '⚡', true, false, 9),
        (tag_one_piece, 'one-piece', 'One Piece', 'Endless adventures from One Piece', '🏴‍☠️', true, false, 25),
        (tag_news, 'news', 'News', 'General anime news and announcements', '📰', false, true, 45),
        (tag_review, 'review', 'Review', 'Episode and series reviews', '⭐', false, true, 32),
        (tag_episode, 'episode-update', 'Episode Update', 'New episode releases and highlights', '📺', false, true, 28);

    -- Insert anime stories
    INSERT INTO public.anime_stories (id, title, summary, content, image_url, author_id, status, view_count, like_count, save_count, share_count, is_featured, is_trending, published_at) VALUES
        (story1_id, 'Demon Slayer Season 4 Confirmed!', 'Studio Ufotable announces the highly anticipated fourth season of Demon Slayer with stunning new visuals.', 'The wait is finally over! Studio Ufotable has officially confirmed that Demon Slayer Season 4 is in production. The announcement came with a breathtaking 30-second teaser that showcases the incredible animation quality fans have come to expect. The new season will adapt the final arc of the manga, promising epic battles and emotional moments that will conclude Tanjiro''s journey. Fans worldwide are already expressing their excitement on social media, making this one of the most anticipated anime releases of the year.', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800', author_user_id, 'featured', 1250, 89, 34, 12, true, true, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
        
        (story2_id, 'Jujutsu Kaisen Movie Breaks Records', 'The latest Jujutsu Kaisen movie has broken box office records in Japan, earning over 2 billion yen in its opening weekend.', 'Jujutsu Kaisen 0 continues its phenomenal success, becoming the highest-grossing anime film of 2024. The movie, which focuses on Yuta Okkotsu''s backstory, has resonated with both longtime fans and newcomers to the series. Critics praise the film''s emotional depth and spectacular fight sequences. The movie''s success has also boosted manga sales, with volumes flying off shelves across Japan. International release dates are expected to be announced soon.', 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800', author_user_id, 'published', 2100, 156, 78, 23, false, true, CURRENT_TIMESTAMP - INTERVAL '5 hours'),
        
        (story3_id, 'Attack on Titan Final Season Analysis', 'A deep dive into the controversial ending of Attack on Titan and what it means for the series legacy.', 'The conclusion of Attack on Titan has sparked intense debate among fans worldwide. While some praise Hajime Isayama''s bold narrative choices, others question the resolution of key character arcs. This analysis explores the themes of freedom, sacrifice, and the cycle of hatred that defined the series. We examine how the ending reflects real-world conflicts and the difficulty of breaking generational trauma. Whether you loved or hated the ending, there''s no denying Attack on Titan''s massive impact on anime and manga culture.', 'https://images.unsplash.com/photo-1601538847996-5da0c8935e72?w=800', admin_user_id, 'published', 890, 67, 45, 8, false, false, CURRENT_TIMESTAMP - INTERVAL '8 hours'),
        
        (story4_id, 'One Piece Episode 1000 Celebration', 'Eiichiro Oda and the animation team celebrate reaching the incredible milestone of 1000 episodes.', 'One Piece has achieved what many thought impossible - 1000 episodes of continuous storytelling. This milestone episode featured special animation, emotional callbacks to early adventures, and a heartfelt message from creator Eiichiro Oda. The episode showcased the growth of the Straw Hat crew and highlighted pivotal moments from their journey. Fans around the world organized watch parties and shared their favorite One Piece memories on social media. The celebration proves that after more than two decades, the Grand Line adventure is far from over.', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800', admin_user_id, 'published', 3500, 234, 112, 45, true, false, CURRENT_TIMESTAMP - INTERVAL '12 hours'),
        
        (story5_id, 'Chainsaw Man Episode 5 Review', 'The latest Chainsaw Man episode delivers on both action and character development, setting up major plot points.', 'Episode 5 of Chainsaw Man masterfully balances Denji''s internal struggles with explosive devil-hunting action. The animation quality remains consistently impressive, with Studio MAPPA showcasing their expertise in both quiet character moments and chaotic battle sequences. This episode introduces key supporting characters who will play crucial roles in upcoming arcs. The sound design deserves special mention, creating an atmosphere that perfectly captures the manga''s unique tone. Fans can expect the intensity to only increase from here.', 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800', author_user_id, 'published', 720, 54, 28, 6, false, false, CURRENT_TIMESTAMP - INTERVAL '1 day');

    -- Link stories to tags
    INSERT INTO public.story_tags (story_id, tag_id) VALUES
        (story1_id, tag_demon_slayer),
        (story1_id, tag_news),
        (story2_id, tag_jujutsu_kaisen),
        (story2_id, tag_news),
        (story3_id, tag_attack_titan),
        (story3_id, tag_review),
        (story4_id, tag_one_piece),
        (story4_id, tag_episode),
        (story5_id, tag_chainsaw_man),
        (story5_id, tag_review),
        (story5_id, tag_episode);

    -- Add user interactions
    INSERT INTO public.user_story_interactions (user_id, story_id, interaction_type) VALUES
        (regular_user_id, story1_id, 'like'),
        (regular_user_id, story1_id, 'save'),
        (regular_user_id, story2_id, 'like'),
        (regular_user_id, story4_id, 'like'),
        (regular_user_id, story4_id, 'save'),
        (admin_user_id, story1_id, 'like'),
        (admin_user_id, story2_id, 'like'),
        (author_user_id, story3_id, 'like');

    -- Add user preferences
    INSERT INTO public.user_preferences (user_id, preferred_tags, notification_settings) VALUES
        (regular_user_id, ARRAY[tag_demon_slayer, tag_jujutsu_kaisen, tag_one_piece]::UUID[], '{"new_stories": true, "trending": true, "favorites": true}'::jsonb),
        (admin_user_id, ARRAY[tag_attack_titan, tag_chainsaw_man]::UUID[], '{"new_stories": true, "trending": false, "favorites": true}'::jsonb);

    RAISE NOTICE 'Mock data inserted successfully with % stories and % tags', 5, 8;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;