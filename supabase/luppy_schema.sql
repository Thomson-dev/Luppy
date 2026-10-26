-- =====================================================================
-- LUPPY: complete Supabase schema (run once on a fresh project)
-- Paste into: Supabase dashboard -> SQL Editor -> New query -> Run
-- =====================================================================

-- ---------- 1. ENUMS ----------
create type dog_gender as enum ('male', 'female');
create type dog_size as enum ('small', 'medium', 'large');
create type swipe_action as enum ('pass', 'like');
create type notification_type as enum
  ('newMatch', 'like', 'message', 'playdateInvite', 'newEvent', 'boosted');

-- ---------- 2. PROFILES (your "Member") ----------
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  avatar_url text,
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create policy "profiles readable by logged-in users"
  on public.profiles for select to authenticated using (true);
create policy "users insert own profile"
  on public.profiles for insert to authenticated with check (id = auth.uid());
create policy "users update own profile"
  on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

-- ---------- 3. DOGS (SignUpData, Dog, DogProfile) ----------
create table public.dogs (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  about text not null default '' check (char_length(about) <= 450),
  birth_date date not null,
  breed text not null,
  gender dog_gender not null,
  size dog_size not null,
  photos text[] not null default '{}',
  image_url text,
  temperaments text[] not null default '{}',
  interests text[] not null default '{}',
  energy_level double precision not null default 0.5
    check (energy_level between 0 and 1),
  is_trained boolean not null default false,
  instagram text not null default '',
  is_verified boolean not null default false,
  created_at timestamptz not null default now(),
  constraint dogs_max_photos check (cardinality(photos) <= 6)
);
create index dogs_owner_id_idx on public.dogs(owner_id);
alter table public.dogs enable row level security;

create policy "dogs are readable by logged-in users"
  on public.dogs for select to authenticated using (true);
create policy "owners insert their dogs"
  on public.dogs for insert to authenticated with check (owner_id = auth.uid());
create policy "owners update their dogs"
  on public.dogs for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "owners delete their dogs"
  on public.dogs for delete to authenticated using (owner_id = auth.uid());

-- Owners cannot set is_verified or change owner_id
revoke insert, update on public.dogs from authenticated;
grant insert (owner_id, name, about, birth_date, breed, gender, size, photos,
              image_url, temperaments, interests, energy_level, is_trained, instagram)
  on public.dogs to authenticated;
grant update (name, about, birth_date, breed, gender, size, photos,
              image_url, temperaments, interests, energy_level, is_trained, instagram)
  on public.dogs to authenticated;

-- Creates/updates the user's profile row from their dog (name + first photo)
create function public.sync_profile_from_dog() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into profiles (id, display_name, avatar_url)
  values (new.owner_id, new.name, new.photos[1])
  on conflict (id) do update
    set display_name = excluded.display_name,
        avatar_url = excluded.avatar_url;
  return new;
end $$;

create trigger on_dog_saved after insert or update of name, photos on public.dogs
  for each row execute function public.sync_profile_from_dog();

-- ---------- 4. USER LOCATIONS (private) ----------
create table public.user_locations (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  updated_at timestamptz not null default now()
);
alter table public.user_locations enable row level security;

create policy "own location select" on public.user_locations
  for select to authenticated using (user_id = auth.uid());
create policy "own location insert" on public.user_locations
  for insert to authenticated with check (user_id = auth.uid());
create policy "own location update" on public.user_locations
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- ---------- 5. CHATS + MESSAGES ----------
create table public.chats (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references public.profiles(id) on delete cascade,
  user_b uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  check (user_a < user_b),
  unique (user_a, user_b)
);
alter table public.chats enable row level security;

create policy "participants read chats"
  on public.chats for select to authenticated
  using (auth.uid() in (user_a, user_b));
create policy "participants create chats"
  on public.chats for insert to authenticated
  with check (auth.uid() in (user_a, user_b));

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null default auth.uid() references public.profiles(id),
  text text not null,
  sent_at timestamptz not null default now()
);
create index messages_chat_sent_idx on public.messages(chat_id, sent_at);
alter table public.messages enable row level security;

create policy "participants read messages"
  on public.messages for select to authenticated
  using (exists (
    select 1 from public.chats c
    where c.id = chat_id and auth.uid() in (c.user_a, c.user_b)
  ));
create policy "participants send messages"
  on public.messages for insert to authenticated
  with check (
    sender_id = auth.uid() and exists (
      select 1 from public.chats c
      where c.id = chat_id and auth.uid() in (c.user_a, c.user_b)
    )
  );

-- ---------- 6. EVENTS ----------
create table public.events (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  name text not null,
  description text not null default '',
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  venue_name text,
  address text not null,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at)
);

create table public.event_members (
  event_id uuid not null references public.events(id) on delete cascade,
  user_id uuid not null default auth.uid() references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  primary key (event_id, user_id)
);
create index event_members_user_idx on public.event_members(user_id);

alter table public.events enable row level security;
alter table public.event_members enable row level security;

create policy "events readable" on public.events
  for select to authenticated using (true);
create policy "admin creates events" on public.events
  for insert to authenticated with check (admin_id = auth.uid());
create policy "admin updates events" on public.events
  for update to authenticated
  using (admin_id = auth.uid()) with check (admin_id = auth.uid());
create policy "admin deletes events" on public.events
  for delete to authenticated using (admin_id = auth.uid());

create policy "members readable" on public.event_members
  for select to authenticated using (true);
create policy "join as yourself" on public.event_members
  for insert to authenticated with check (user_id = auth.uid());
create policy "leave as yourself" on public.event_members
  for delete to authenticated using (user_id = auth.uid());

-- ---------- 7. SWIPES + MATCHES ----------
create table public.swipes (
  swiper_dog_id uuid not null references public.dogs(id) on delete cascade,
  target_dog_id uuid not null references public.dogs(id) on delete cascade,
  action swipe_action not null,
  created_at timestamptz not null default now(),
  primary key (swiper_dog_id, target_dog_id),
  check (swiper_dog_id <> target_dog_id)
);
alter table public.swipes enable row level security;

create policy "read my swipes" on public.swipes
  for select to authenticated
  using (exists (select 1 from public.dogs d where d.id = swiper_dog_id and d.owner_id = auth.uid()));
create policy "swipe with my dog" on public.swipes
  for insert to authenticated
  with check (exists (select 1 from public.dogs d where d.id = swiper_dog_id and d.owner_id = auth.uid()));

create table public.matches (
  id uuid primary key default gen_random_uuid(),
  dog_a uuid not null references public.dogs(id) on delete cascade,
  dog_b uuid not null references public.dogs(id) on delete cascade,
  matched_at timestamptz not null default now(),
  check (dog_a < dog_b),
  unique (dog_a, dog_b)
);
alter table public.matches enable row level security;

-- Read-only for users. Only the trigger creates matches.
create policy "read my matches" on public.matches
  for select to authenticated
  using (exists (
    select 1 from public.dogs d
    where d.id in (dog_a, dog_b) and d.owner_id = auth.uid()
  ));

-- ---------- 8. NOTIFICATIONS ----------
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  type notification_type not null,
  text text not null,
  highlight text,
  target_id uuid,
  is_unread boolean not null default true,
  created_at timestamptz not null default now()
);
create index notifications_user_idx on public.notifications(user_id, created_at desc);
alter table public.notifications enable row level security;

create policy "read my notifications" on public.notifications
  for select to authenticated using (user_id = auth.uid());
create policy "mark my notifications read" on public.notifications
  for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Users can only change is_unread. No insert policy: only triggers create rows.
revoke update on public.notifications from authenticated;
grant update (is_unread) on public.notifications to authenticated;

-- ---------- 9. SUBSCRIPTION PLANS ----------
create table public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  price numeric(6,2) not null,
  sort_order int not null default 0
);
alter table public.subscription_plans enable row level security;
create policy "plans readable" on public.subscription_plans
  for select to authenticated using (true);

-- Edit names and prices to match your design
insert into public.subscription_plans (name, price, sort_order) values
  ('No ads', 4.99, 1),
  ('See who liked you', 6.99, 2),
  ('Unlimited likes', 9.99, 3);

-- ---------- 10. FUNCTIONS + TRIGGERS ----------

-- Like -> notification, or mutual like -> match + chat + notifications
create function public.handle_like() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  owner_me uuid; owner_other uuid;
  me_name text; other_name text; other_dog_name text;
  chat_uuid uuid;
begin
  if new.action <> 'like' then return new; end if;

  select owner_id into owner_me from dogs where id = new.swiper_dog_id;
  select owner_id, name into owner_other, other_dog_name from dogs where id = new.target_dog_id;
  select coalesce(display_name, 'Someone') into me_name from profiles where id = owner_me;
  select coalesce(display_name, 'Someone') into other_name from profiles where id = owner_other;

  -- Not mutual yet: tell the other owner they were liked
  if not exists (
    select 1 from swipes
    where swiper_dog_id = new.target_dog_id
      and target_dog_id = new.swiper_dog_id
      and action = 'like'
  ) then
    insert into notifications (user_id, actor_id, type, text, highlight, target_id)
    values (owner_other, owner_me, 'like',
            me_name || ' has liked your dog, ' || other_dog_name || '!',
            me_name, new.swiper_dog_id);
    return new;
  end if;

  -- Mutual: create match + chat, notify both owners
  insert into matches (dog_a, dog_b)
  values (least(new.swiper_dog_id, new.target_dog_id),
          greatest(new.swiper_dog_id, new.target_dog_id))
  on conflict do nothing;

  if owner_me <> owner_other then
    insert into chats (user_a, user_b)
    values (least(owner_me, owner_other), greatest(owner_me, owner_other))
    on conflict do nothing;

    select id into chat_uuid from chats
    where user_a = least(owner_me, owner_other) and user_b = greatest(owner_me, owner_other);

    insert into notifications (user_id, actor_id, type, text, highlight, target_id) values
      (owner_me, owner_other, 'newMatch', 'You and ' || other_name || ' are a match!', other_name, chat_uuid),
      (owner_other, owner_me, 'newMatch', 'You and ' || me_name || ' are a match!', me_name, chat_uuid);
  end if;

  return new;
end $$;

create trigger on_swipe after insert on public.swipes
  for each row execute function public.handle_like();

-- New chat message -> notify the other person
create function public.handle_message() returns trigger
language plpgsql security definer set search_path = public as $$
declare
  recipient uuid;
  sender_name text;
begin
  select case when user_a = new.sender_id then user_b else user_a end
    into recipient from chats where id = new.chat_id;
  select coalesce(display_name, 'Someone') into sender_name from profiles where id = new.sender_id;

  insert into notifications (user_id, actor_id, type, text, highlight, target_id)
  values (recipient, new.sender_id, 'message',
          sender_name || ' sent you a message', sender_name, new.chat_id);
  return new;
end $$;

create trigger on_message after insert on public.messages
  for each row execute function public.handle_message();

-- Dogs you haven't swiped on yet, nearest first (haversine distance)
create function public.get_candidates(my_dog_id uuid)
returns table (
  id uuid, name text, breed text, birth_date date, image_url text,
  is_verified boolean, photos text[], distance_km double precision
)
language sql stable security definer set search_path = public as $$
  select d.id, d.name, d.breed, d.birth_date, d.image_url, d.is_verified, d.photos,
    6371 * 2 * asin(sqrt(
      power(sin(radians(l.lat - me.lat) / 2), 2) +
      cos(radians(me.lat)) * cos(radians(l.lat)) *
      power(sin(radians(l.lng - me.lng) / 2), 2)
    )) as distance_km
  from dogs d
  left join user_locations l on l.user_id = d.owner_id
  left join user_locations me on me.user_id = auth.uid()
  where d.owner_id <> auth.uid()
    and exists (select 1 from dogs mine where mine.id = my_dog_id and mine.owner_id = auth.uid())
    and not exists (
      select 1 from swipes s
      where s.swiper_dog_id = my_dog_id and s.target_dog_id = d.id
    )
  order by distance_km nulls last
  limit 20;
$$;

-- ---------- 11. REALTIME ----------
alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.notifications;