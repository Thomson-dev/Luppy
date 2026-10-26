-- ============================================================================
-- Supabase Storage Policies for `dog_photos` Bucket
-- ============================================================================
-- Run this in your Supabase Dashboard -> SQL Editor (or via Policies tab)
-- This allows authenticated users to upload, update, and delete their dog photos,
-- and allows public read access so other dog owners can view profiles.
-- ============================================================================

-- 1. Allow public view/read access to all photos in `dog_photos`
create policy "Public Access to Dog Photos"
on storage.objects for select
to public
using (bucket_id = 'dog_photos');

-- 2. Allow authenticated users to upload photos into `dog_photos`
create policy "Authenticated Users can upload Dog Photos"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'dog_photos'
);

-- 3. Allow users to update their own photos
create policy "Users can update own Dog Photos"
on storage.objects for update
to authenticated
using (
  bucket_id = 'dog_photos' and
  (auth.uid()::text = (storage.foldername(name))[1] or auth.uid() = owner)
);

-- 4. Allow users to delete their own photos
create policy "Users can delete own Dog Photos"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'dog_photos' and
  (auth.uid()::text = (storage.foldername(name))[1] or auth.uid() = owner)
);

