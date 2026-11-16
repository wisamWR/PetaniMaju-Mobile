-- Fitur tambahan PetaniMaju (diadaptasi dari Agrinova):
--   1. Riwayat scan penyakit tanaman  -> tabel prediction_history + bucket scan_images
--   2. Langganan PRO (Midtrans)       -> tabel user_premium + premium_orders
--
-- Jalankan di Supabase Dashboard > SQL Editor (project swahqjobmjlwpiuyyzdf),
-- atau lewat `supabase db push`.

-- ─── 1. Riwayat scan ───────────────────────────────────────────────────────

create table if not exists public.prediction_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  image_url text,
  plant_type text not null,
  disease text not null,
  confidence real,
  severity text default 'Pending',
  status text default 'Success',
  description text,
  recommendation text,
  prevention text,
  created_at timestamptz not null default now()
);

create index if not exists prediction_history_user_created_idx
  on public.prediction_history (user_id, created_at desc);

alter table public.prediction_history enable row level security;

drop policy if exists "select_own_history" on public.prediction_history;
create policy "select_own_history" on public.prediction_history
  for select to authenticated using ((select auth.uid()) = user_id);

drop policy if exists "insert_own_history" on public.prediction_history;
create policy "insert_own_history" on public.prediction_history
  for insert to authenticated with check ((select auth.uid()) = user_id);

drop policy if exists "delete_own_history" on public.prediction_history;
create policy "delete_own_history" on public.prediction_history
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Bucket foto scan: publik untuk dibaca (URL tidak bisa ditebak),
-- tulis/hapus hanya di folder milik user sendiri: <user_id>/<file>.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'scan_images', 'scan_images', true, 5242880,
  array['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'image/heif']
)
on conflict (id) do nothing;

drop policy if exists "scan_images_insert_own" on storage.objects;
create policy "scan_images_insert_own" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'scan_images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists "scan_images_delete_own" on storage.objects;
create policy "scan_images_delete_own" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'scan_images'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ─── 2. Langganan PRO ──────────────────────────────────────────────────────

-- Status PRO disimpan di tabel terpisah (tidak bergantung pada tabel profiles).
-- User hanya bisa MEMBACA statusnya sendiri; tidak ada policy insert/update,
-- sehingga hanya service_role (Edge Function setelah verifikasi Midtrans) yang bisa menulis.
create table if not exists public.user_premium (
  user_id uuid primary key references auth.users (id) on delete cascade,
  is_premium boolean not null default false,
  premium_until timestamptz,
  premium_plan text,
  updated_at timestamptz not null default now()
);

alter table public.user_premium enable row level security;

drop policy if exists "select_own_premium" on public.user_premium;
create policy "select_own_premium" on public.user_premium
  for select to authenticated using ((select auth.uid()) = user_id);

create table if not exists public.premium_orders (
  order_id text primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  plan_id text not null,
  amount integer not null,
  days integer not null,
  status text not null default 'pending',
  created_at timestamptz not null default now(),
  paid_at timestamptz
);

create index if not exists premium_orders_user_idx on public.premium_orders (user_id);

alter table public.premium_orders enable row level security;

-- User hanya bisa melihat order miliknya. Insert/update lewat service_role saja.
drop policy if exists "select_own_orders" on public.premium_orders;
create policy "select_own_orders" on public.premium_orders
  for select to authenticated using ((select auth.uid()) = user_id);
