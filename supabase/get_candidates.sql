-- ============================================================================
-- Get Match Candidates RPC & Dog Read Policy
-- ============================================================================
-- Run this in your Supabase Dashboard -> SQL Editor
-- This ensures:
-- 1. Authenticated users can view other dogs in the app.
-- 2. The `get_candidates` RPC returns dogs that the user hasn't swiped on yet.
-- ============================================================================

-- 1. Enable RLS and allow authenticated users to view all dogs
alter table public.dogs enable row level security;

drop policy if exists "Allow authenticated users to read all dogs" on public.dogs;
create policy "Allow authenticated users to read all dogs"
on public.dogs for select
to authenticated
using (true);

-- 2. RPC Function: get_candidates(my_dog_id)
-- Returns all dogs except `my_dog_id` and dogs already swiped on by `my_dog_id`
create or replace function public.get_candidates(my_dog_id uuid)
returns setof public.dogs
language sql
security definer
stable
as $$
  select *
  from public.dogs
  where id <> my_dog_id
    and id not in (
      select target_dog_id
      from public.swipes
      where swiper_dog_id = my_dog_id
    )
  order by created_at desc
  limit 25;
$$;

