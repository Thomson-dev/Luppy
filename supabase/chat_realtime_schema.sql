-- ============================================================================
-- Luppy Realtime 1-on-1 Chat Schema & WebSocket Setup
-- ============================================================================
-- Run this in your Supabase Dashboard -> SQL Editor
-- This enables:
-- 1. Real 1-on-1 chat rooms between matched pet owners.
-- 2. Message persistence.
-- 3. Supabase Realtime WebSocket broadcast for instant messaging.
-- ============================================================================

-- 1. Chats Table (each row represents a 1-on-1 conversation between user_a and user_b)
create table if not exists public.chats (
  id uuid primary key default gen_random_uuid(),
  user_a uuid not null references auth.users(id) on delete cascade,
  user_b uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint unique_chat_users unique (user_a, user_b),
  constraint chat_user_order check (user_a < user_b)
);

-- 2. Messages Table
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  chat_id uuid not null references public.chats(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  text text not null check (length(trim(text)) > 0),
  sent_at timestamptz not null default now()
);

-- Indexes for fast chat retrieval
create index if not exists idx_chats_user_a on public.chats(user_a);
create index if not exists idx_chats_user_b on public.chats(user_b);
create index if not exists idx_messages_chat_id on public.messages(chat_id, sent_at);

-- 3. Row Level Security (RLS)
alter table public.chats enable row level security;
alter table public.messages enable row level security;

-- Only participants in the chat can view the chat room
drop policy if exists "Users can read own chats" on public.chats;
create policy "Users can read own chats" on public.chats
for select to authenticated
using (auth.uid() = user_a or auth.uid() = user_b);

-- Only participants can create a chat room
drop policy if exists "Users can insert own chats" on public.chats;
create policy "Users can insert own chats" on public.chats
for insert to authenticated
with check (auth.uid() = user_a or auth.uid() = user_b);

-- Only chat participants can read messages
drop policy if exists "Users can read messages in their chats" on public.messages;
create policy "Users can read messages in their chats" on public.messages
for select to authenticated
using (
  exists (
    select 1 from public.chats c
    where c.id = messages.chat_id
      and (c.user_a = auth.uid() or c.user_b = auth.uid())
  )
);

-- Only chat participants can send messages as themselves
drop policy if exists "Users can send messages to their chats" on public.messages;
create policy "Users can send messages to their chats" on public.messages
for insert to authenticated
with check (
  auth.uid() = sender_id and
  exists (
    select 1 from public.chats c
    where c.id = messages.chat_id
      and (c.user_a = auth.uid() or c.user_b = auth.uid())
  )
);

-- 4. Enable Supabase Realtime WebSocket broadcast for messages
-- This pushes new messages to connected Flutter clients via WebSockets
do $$
begin
  if not exists (
    select 1 from pg_publication_tables 
    where pubname = 'supabase_realtime' 
      and schemaname = 'public' 
      and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;

