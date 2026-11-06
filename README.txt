LEARNING HUB MARKETPLACE — INTERNATIONAL-READY EXISTING PROJECT PACKAGE
======================================================================

This package upgrades your existing Marketplace for users and listings in
multiple countries. It keeps your existing GitHub repository and Supabase
project. It does not create a new project or delete existing Auth users.

FILES
-----
market.html
  Marketplace interface with country selection, ISO currency selection,
  seller location fields, global browsing, currency-aware price display,
  authentication, listing ownership, photos, saved items and messaging.

config.js
  Add your existing Supabase Project URL and PUBLIC publishable/anon key.
  Never place a service_role or secret key in a browser file.

migration-existing-supabase.sql
  Additive migration for public.listings. Adds country_code, currency_code,
  and shipping_scope with safe defaults (PH, PHP, local), indexes, and keeps
  the four known listings RLS policies. It also prepares the listing photo
  bucket and owner-folder storage policies.

INTERNATIONAL DATABASE FIELDS
-----------------------------
country_code   ISO 3166-1 alpha-2 country code (PH, US, GB, etc.)
currency_code  ISO 4217 currency code (PHP, USD, EUR, etc.)
shipping_scope local | domestic | international

Existing records, if any, default to PH / PHP / local. The listing form lets
sellers choose from 249 country/territory entries and ISO currency codes.
The Marketplace shows each listing in its own currency. It does not silently
convert amounts. Price range and price sorting are only meaningful after a
currency is selected in the filter.

IMPORTANT LIMITATIONS
---------------------
This is an international listing/browsing marketplace, not a cross-border
payment or logistics platform. It does not process payments, convert FX,
provide escrow, calculate taxes/customs, create shipping labels, or guarantee
that a seller can ship to a buyer's country. Buyers and sellers must agree
on payment and delivery arrangements and comply with local laws.

DATABASE COMPATIBILITY
----------------------
The supplied RLS policy results confirm public.listings has user_id and
status, and four policies already exist. The existing policies are preserved:
- Public read: status <> 'removed'
- Authenticated insert: auth.uid() = user_id AND status = 'available'
- Owner update and delete: auth.uid() = user_id

The full listings column list and supporting-table schema were not supplied.
The original application still expects its supporting tables/relations
(profiles, conversations, messages, blocks, reports) and fields such as
id, title, description, price, category, condition, region, city, photos,
thumbs, status, created_at. Confirm those structures before relying on every
chat/report/profile feature. This migration intentionally does not invent
or replace those tables.

INSTALLATION
------------
1. Back up the existing Supabase project before any schema change.
2. Extract this ZIP.
3. Put market.html and config.js in the Marketplace location in your existing
   GitHub repository. Keep unrelated Learning Hub files unchanged.
4. Edit config.js with the existing Supabase Project URL and PUBLIC key.
5. Review migration-existing-supabase.sql, then run it in the existing
   Supabase SQL Editor. It is additive and does not drop existing records.
6. In Supabase Auth URL Configuration, set your GitHub Pages site as the
   Site URL and add the exact Marketplace URL to Redirect URLs.
7. Commit the updated files to your existing GitHub repository.

CONFIGURATION EXAMPLE
---------------------
window.MARKET_CONFIG = {
  url: "https://YOUR-PROJECT-REF.supabase.co",
  key: "YOUR_PUBLIC_PUBLISHABLE_OR_ANON_KEY",
  contact: ""
};

SECURITY
--------
Never expose the Supabase service_role/secret key. Keep RLS enabled. The
browser public key is safe only when database grants, RLS policies, and
Storage policies are configured correctly.
