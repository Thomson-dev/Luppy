-- Demo data for the New Matches section.
-- Run this in Supabase Dashboard -> SQL Editor as a database administrator.
-- It uses existing rows in auth.users; create at least two accounts first.

do $$
declare
  user_row record;
  user_count integer := 0;
  demo_dog_id uuid;
begin
  for user_row in
    select
      id,
      row_number() over (order by created_at, id) as dog_number
    from auth.users
    order by created_at, id
  loop
    user_count := user_count + 1;
    demo_dog_id := md5(user_row.id::text || ':luppy-demo-dog')::uuid;

    insert into public.dogs (
      id,
      owner_id,
      name,
      about,
      birth_date,
      breed,
      gender,
      size,
      photos,
      image_url,
      temperaments,
      interests,
      energy_level,
      is_trained,
      instagram,
      is_verified
    )
    values (
      demo_dog_id,
      user_row.id,
      case user_row.dog_number
        when 1 then 'Duke'
        when 2 then 'Biscuit'
        when 3 then 'Mochi'
        when 4 then 'Luna'
        else 'Buddy ' || user_row.dog_number::text
      end,
      'A friendly demo profile for testing matches.',
      case user_row.dog_number
        when 1 then date '2021-04-12'
        when 2 then date '2022-08-25'
        when 3 then date '2020-11-03'
        else date '2021-09-18'
      end,
      case user_row.dog_number
        when 1 then 'Boston Terrier'
        when 2 then 'Pomeranian'
        when 3 then 'Golden Retriever'
        else 'Mixed Breed'
      end,
      case when mod(user_row.dog_number::integer, 2) = 0
        then 'female'::dog_gender
        else 'male'::dog_gender
      end,
      case
        when mod(user_row.dog_number::integer, 3) = 0 then 'large'::dog_size
        when mod(user_row.dog_number::integer, 2) = 0 then 'small'::dog_size
        else 'medium'::dog_size
      end,
      case user_row.dog_number
        when 1 then array['https://images.unsplash.com/photo-1583511655857-d19b40a7a54e']
        when 2 then array['https://images.unsplash.com/photo-1543466835-00a7907e9de1']
        when 3 then array['https://images.unsplash.com/photo-1552053831-71594a27632d']
        else array['https://images.unsplash.com/photo-1537151608828-ea2b11777ee8']
      end,
      null,
      array['playful', 'friendly'],
      array['walks', 'park visits'],
      0.7,
      true,
      '',
      true
    )
    on conflict (id) do update set
      name = excluded.name,
      about = excluded.about,
      birth_date = excluded.birth_date,
      breed = excluded.breed,
      gender = excluded.gender,
      size = excluded.size,
      photos = excluded.photos,
      image_url = excluded.image_url,
      temperaments = excluded.temperaments,
      interests = excluded.interests,
      energy_level = excluded.energy_level,
      is_trained = excluded.is_trained,
      instagram = excluded.instagram,
      is_verified = excluded.is_verified;
  end loop;

  if user_count < 2 then
    raise exception 'Create at least two Supabase Auth users before running this seed.';
  end if;

  insert into public.matches (dog_a, dog_b, matched_at)
  select
    least(first_dog.id, other_dog.id),
    greatest(first_dog.id, other_dog.id),
    now()
  from (
    select id
    from public.dogs
    where id = md5((
      select id::text from auth.users order by created_at, id limit 1
    ) || ':luppy-demo-dog')::uuid
  ) as first_dog
  cross join lateral (
    select id
    from public.dogs
    where id <> first_dog.id
      and id in (
        select md5(id::text || ':luppy-demo-dog')::uuid
        from auth.users
      )
  ) as other_dog
  on conflict (dog_a, dog_b) do update
    set matched_at = excluded.matched_at;
end $$;

-- Verify the rows visible to the app's getMatches query.
select
  m.id,
  m.dog_a,
  m.dog_b,
  m.matched_at,
  dog_a.name as dog_a_name,
  dog_b.name as dog_b_name
from public.matches m
join public.dogs dog_a on dog_a.id = m.dog_a
join public.dogs dog_b on dog_b.id = m.dog_b
order by m.matched_at desc;
