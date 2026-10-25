-- MISE À JOUR (communes + frais de livraison) : à lancer UNE fois dans Supabase > SQL Editor
create table if not exists communes(id uuid primary key default gen_random_uuid(),name text not null unique,fee integer not null default 0,active boolean default true);
alter table orders add column if not exists commune text;
alter table orders add column if not exists delivery_fee integer default 0;
alter table communes enable row level security;
create policy "communes: lecture publique" on communes for select using(active or is_admin());
create policy "communes: admin écrit" on communes for all using(is_admin()) with check(is_admin());
insert into communes(name,fee) values('Abobo',1500),('Adjamé',1500),('Anyama',2500),('Attécoubé',1500),('Bingerville',2500),('Cocody',1500),('Koumassi',1500),('Marcory',1500),('Plateau',1500),('Port-Bouët',2000),('Songon',3000),('Treichville',1500),('Yopougon',1500) on conflict do nothing;
