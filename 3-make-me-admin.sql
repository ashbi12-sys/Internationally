-- =====================================================================
-- MAKE YOURSELF THE ADMINISTRATOR (run AFTER you sign up on your website).
-- 1. Change you@example.com below to the SAME email you used to sign up.
-- 2. Run it. Then log out and log in again on the website.
--    You will see an "Admin" link at the top.
-- =====================================================================
insert into public.marketplace_admins (user_id)
select id from auth.users where email = 'you@example.com'
on conflict do nothing;
