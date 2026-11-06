-- Learning Hub Marketplace: international-ready migration for the EXISTING Supabase project.
-- Safe, additive migration: does not drop tables, rows, users, or existing RLS policies.
-- Based on verified current facts: public.listings has user_id/status and 4 owner/public policies.
-- Listings are currently empty (count reported as 0), but existing accounts are preserved.

begin;

alter table public.listings enable row level security;

-- International listing fields. Existing rows (if any) default to Philippines/PHP.
alter table public.listings
  add column if not exists country_code text not null default 'PH',
  add column if not exists currency_code text not null default 'PHP',
  add column if not exists shipping_scope text not null default 'local';

-- Validate ISO-style codes and the delivery scope without limiting which country/currency can be used.
do $$ begin
  if not exists (select 1 from pg_constraint where conname = 'listings_country_code_format' and conrelid = 'public.listings'::regclass) then
    alter table public.listings add constraint listings_country_code_format
      check (country_code ~ '^[A-Z]{2}$');
  end if;
  if not exists (select 1 from pg_constraint where conname = 'listings_currency_code_format' and conrelid = 'public.listings'::regclass) then
    alter table public.listings add constraint listings_currency_code_format
      check (currency_code ~ '^[A-Z]{3}$');
  end if;
  if not exists (select 1 from pg_constraint where conname = 'listings_shipping_scope_valid' and conrelid = 'public.listings'::regclass) then
    alter table public.listings add constraint listings_shipping_scope_valid
      check (shipping_scope in ('local','domestic','international'));
  end if;
end $$;

-- Defaults and indexes for owner and global browsing.
alter table public.listings alter column user_id set default auth.uid();
create index if not exists listings_user_id_idx on public.listings (user_id);
create index if not exists listings_country_currency_status_idx
  on public.listings (country_code, currency_code, status);

-- Ordinary authenticated users must not have table-wide admin-like privileges.
revoke truncate, references, trigger on table public.listings from authenticated;
grant select on table public.listings to anon, authenticated;
grant insert, update, delete on table public.listings to authenticated;

-- Existing four RLS policies are intentionally retained:
-- SELECT: status <> 'removed'
-- INSERT: auth.uid() = user_id AND status = 'available'
-- UPDATE: auth.uid() = user_id (USING and WITH CHECK)
-- DELETE: auth.uid() = user_id

-- Public read bucket for listing photos; uploads/deletes are owner-folder restricted.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('listing-photos', 'listing-photos', true, 3145728,
        array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

do $$ begin
  if not exists (select 1 from pg_policies where schemaname='storage' and tablename='objects' and policyname='learning hub listing photos public read') then
    create policy "learning hub listing photos public read" on storage.objects
      for select to anon, authenticated using (bucket_id = 'listing-photos');
  end if;
  if not exists (select 1 from pg_policies where schemaname='storage' and tablename='objects' and policyname='learning hub listing photos owner upload') then
    create policy "learning hub listing photos owner upload" on storage.objects
      for insert to authenticated with check (bucket_id = 'listing-photos' and (storage.foldername(name))[1] = auth.uid()::text);
  end if;
  if not exists (select 1 from pg_policies where schemaname='storage' and tablename='objects' and policyname='learning hub listing photos owner delete') then
    create policy "learning hub listing photos owner delete" on storage.objects
      for delete to authenticated using (bucket_id = 'listing-photos' and (storage.foldername(name))[1] = auth.uid()::text);
  end if;
end $$;

commit;

-- INTERNATIONAL MARKETPLACE NOTES:
-- country_code: ISO 3166-1 alpha-2 country code (e.g. PH, US, GB).
-- currency_code: ISO 4217 currency code (e.g. PHP, USD, EUR).
-- shipping_scope: seller's stated arrangement only; this app does not book shipping.
-- The app does not process payments, perform currency conversion, escrow funds,
-- calculate taxes/customs, or guarantee cross-border delivery. Buyers and sellers
-- must agree on payment, shipping, duties, and local legal requirements themselves.
