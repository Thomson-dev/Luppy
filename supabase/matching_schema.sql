-- ============================================================================
-- Luppy Matching & Chat Permission Schema
-- ============================================================================
-- Flow:
-- 1. User A likes Bella (stored in public.swipes).
-- 2. User B likes Bruno (stored in public.swipes).
-- 3. Backend trigger checks if reverse like exists.
-- 4. If both likes exist, creates one match record in public.matches.
-- 5. Match appears in both users' match lists.
-- 6. Allows chat ONLY for participants in that match.
-- ============================================================================

-- 1. Swipes Table
create table if not exists public.swipes (
  id uuid primary key default gen_random_uuid(),
  swiper_dog_id uuid not null references public.dogs(id) on delete cascade,
  target_dog_id uuid not null references public.dogs(id) on delete cascade,
  action text not null check (action in ('like', 'pass')),
  created_at timestamptz not null default now(),
  constraint unique_swipe unique (swiper_dog_id, target_dog_id)
);

-- 2. Matches Table (dog_a is always < dog_b to guarantee single unique record per pair)
create table if not exists public.matches (
  id uuid primary key default gen_random_uuid(),
  dog_a uuid not null references public.dogs(id) on delete cascade,
  dog_b uuid not null references public.dogs(id) on delete cascade,
  matched_at timestamptz not null default now(),
  constraint unique_match_pair unique (dog_a, dog_b),
  constraint dog_pair_order check (dog_a < dog_b)
);

-- Indexes for lightning fast lookups
create index if not exists idx_swipes_lookup on public.swipes (swiper_dog_id, target_dog_id, action);
create index if not exists idx_matches_dog_a on public.matches (dog_a);
create index if not exists idx_matches_dog_b on public.matches (dog_b);

-- 3. Trigger Function: Mutual Like Detection & Match Creation
create or replace function public.handle_swipe_match()
returns trigger
language plpgsql
security definer
as $$
declare
  _reverse_like_exists boolean;
  _first_dog_id uuid;
  _second_dog_id uuid;
  _swiper_owner_id uuid;
  _target_owner_id uuid;
  _swiper_dog_name text;
  _target_dog_name text;
begin
  -- Only evaluate when action is 'like'
  if new.action <> 'like' then
    return new;
  end if;

  -- Check if the reverse like exists
  select exists (
    select 1
    from public.swipes
    where swiper_dog_id = new.target_dog_id
      and target_dog_id = new.swiper_dog_id
      and action = 'like'
  ) into _reverse_like_exists;

  -- A match requires mutual interest!
  if _reverse_like_exists then
    -- Order dog IDs so dog_a < dog_b
    if new.swiper_dog_id < new.target_dog_id then
      _first_dog_id := new.swiper_dog_id;
      _second_dog_id := new.target_dog_id;
    else
      _first_dog_id := new.target_dog_id;
      _second_dog_id := new.swiper_dog_id;
    end if;

    -- Create single match record
    insert into public.matches (dog_a, dog_b, matched_at)
    values (_first_dog_id, _second_dog_id, now())
    on conflict (dog_a, dog_b) do nothing;

    -- Fetch owner IDs & names for notifications
    select owner_id, name into _swiper_owner_id, _swiper_dog_name from public.dogs where id = new.swiper_dog_id;
    select owner_id, name into _target_owner_id, _target_dog_name from public.dogs where id = new.target_dog_id;

    -- Send notifications to both owners (if notifications table exists)
    if exists (select from pg_tables where schemaname = 'public' and tablename = 'notifications') then
      -- Notify swiper
      insert into public.notifications (user_id, type, text, highlight, created_at, target_id)
      values (
        _swiper_owner_id,
        'newMatch',
        'Your dog, ' || _swiper_dog_name || ', matched with ' || _target_dog_name || '!',
        _target_dog_name,
        now(),
        new.target_dog_id::text
      );

      -- Notify target owner
      insert into public.notifications (user_id, type, text, highlight, created_at, target_id)
      values (
        _target_owner_id,
        'newMatch',
        'Your dog, ' || _target_dog_name || ', matched with ' || _swiper_dog_name || '!',
        _swiper_dog_name,
        now(),
        new.swiper_dog_id::text
      );
    end if;
  end if;

  return new;
end;
$$;

-- Drop trigger if exists and recreate
drop trigger if exists on_swipe_inserted on public.swipes;
create trigger on_swipe_inserted
after insert or update of action
on public.swipes
for each row
execute function public.handle_swipe_match();

-- 4. Enable Row Level Security (RLS)
alter table public.swipes enable row level security;
alter table public.matches enable row level security;

-- Policies for Swipes:
-- Users can read swipes they participated in
create policy "Users can read own swipes" on public.swipes
for select to authenticated
using (
  swiper_dog_id in (select id from public.dogs where owner_id = auth.uid()) or
  target_dog_id in (select id from public.dogs where owner_id = auth.uid())
);

-- Users can insert swipes for their own dogs
create policy "Users can insert swipes for own dog" on public.swipes
for insert to authenticated
with check (
  swiper_dog_id in (select id from public.dogs where owner_id = auth.uid())
);

-- Policies for Matches:
-- Users can see matches that involve their dog
create policy "Users can view their matches" on public.matches
for select to authenticated
using (
  dog_a in (select id from public.dogs where owner_id = auth.uid()) or
  dog_b in (select id from public.dogs where owner_id = auth.uid())
);

-- Users can insert matches (used by client-side fallback)
create policy "Users can insert mutual matches" on public.matches
for insert to authenticated
with check (
  dog_a in (select id from public.dogs where owner_id = auth.uid()) or
  dog_b in (select id from public.dogs where owner_id = auth.uid())
);

-- 5. Chat Permission: Only allow chats/messages between matched users!
create or replace function public.is_matched_with_user(other_user_id uuid)
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1
    from public.matches m
    join public.dogs d1 on (m.dog_a = d1.id or m.dog_b = d1.id) and d1.owner_id = auth.uid()
    join public.dogs d2 on (m.dog_a = d2.id or m.dog_b = d2.id) and d2.owner_id = other_user_id
    where d1.id <> d2.id
  );
$$;

