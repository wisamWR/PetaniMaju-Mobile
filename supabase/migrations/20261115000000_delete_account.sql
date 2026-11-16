-- Hapus akun sendiri dari aplikasi.
-- Client tidak boleh memegang service_role, jadi penghapusan auth.users
-- dilakukan lewat fungsi SECURITY DEFINER yang hanya menghapus baris milik
-- pemanggil (auth.uid()). Semua tabel turunan (profiles, forum, kalender,
-- bookmark, riwayat scan, premium) sudah "on delete cascade".
-- Foto di storage dibersihkan oleh client sebelum fungsi ini dipanggil.

create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'not authenticated' using errcode = '42501';
  end if;

  delete from auth.users where id = uid;
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
