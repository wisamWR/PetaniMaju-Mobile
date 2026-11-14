-- Bucket gambar konten (tips, hama & penyakit).
-- Publik untuk dibaca lewat URL. Tidak ada policy insert/update/delete,
-- jadi client tidak bisa menulis; isinya dikelola lewat dashboard atau
-- CLI (`supabase storage cp`) yang memakai service role.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'content_images', 'content_images', true, 5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;
