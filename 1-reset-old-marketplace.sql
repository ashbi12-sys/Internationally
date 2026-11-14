-- =====================================================================
-- RESET THE OLD MARKETPLACE  (run ONCE, only if this Supabase project
-- was used for an older marketplace).
--
-- WARNING: this DELETES the old marketplace tables and their rows
-- (old listings, chats, reports, profiles). User logins are NOT deleted.
-- If you are using a brand-new Supabase project, SKIP this file.
-- After it succeeds, run 2-setup.sql.
-- =====================================================================
drop table if exists public.messages cascade;
drop table if exists public.conversations cascade;
drop table if exists public.reports cascade;
drop table if exists public.blocks cascade;
drop table if exists public.listings cascade;
drop table if exists public.marketplace_admins cascade;
drop table if exists public.profiles cascade;

drop function if exists public.handle_new_user() cascade;
drop function if exists public.is_marketplace_admin() cascade;
drop function if exists public.admin_set_ban(uuid, boolean);
drop function if exists public.delete_my_account();
drop function if exists public.can_message(uuid);
drop function if exists public.is_participant(uuid);
drop function if exists public.not_banned();
drop function if exists public.limit_listings();
drop function if exists public.limit_messages();
drop function if exists public.on_message_insert();

drop policy if exists "learning hub listing photos public read" on storage.objects;
drop policy if exists "learning hub listing photos owner upload" on storage.objects;
drop policy if exists "learning hub listing photos owner delete" on storage.objects;
drop policy if exists "mk photos upload own folder" on storage.objects;
drop policy if exists "mk photos see own folder" on storage.objects;
drop policy if exists "mk photos delete own folder" on storage.objects;
