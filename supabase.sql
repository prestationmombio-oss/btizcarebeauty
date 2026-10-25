-- Ktiz Care Beauty : à coller dans Supabase > SQL Editor > Run
create table if not exists profiles(id uuid primary key references auth.users on delete cascade,name text,phone text unique,role text not null default 'client',created_at timestamptz default now());
create table if not exists products(id uuid primary key default gen_random_uuid(),name text not null,category text not null,description text,image_url text,variants jsonb not null default '[]',active boolean default true,sort int default 0,created_at timestamptz default now());
create table if not exists orders(id uuid primary key default gen_random_uuid(),ref text,user_id uuid references auth.users,name text,phone text,address text,note text,items jsonb,total integer,status text default 'Nouvelle',created_at timestamptz default now());

create or replace function is_admin() returns boolean language sql security definer set search_path=public as $$ select exists(select 1 from profiles where id=auth.uid() and role='admin') $$;
create or replace function handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into profiles(id,name,phone) values(new.id,new.raw_user_meta_data->>'name',new.raw_user_meta_data->>'phone'); return new; end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function handle_new_user();

alter table profiles enable row level security;alter table products enable row level security;alter table orders enable row level security;
create policy "profil: le sien ou admin" on profiles for select using(id=auth.uid() or is_admin());
create policy "produits: lecture publique" on products for select using(active or is_admin());
create policy "produits: admin écrit" on products for all using(is_admin()) with check(is_admin());
create policy "commandes: tout le monde peut commander" on orders for insert with check(user_id is null or user_id=auth.uid());
create policy "commandes: voir les siennes ou admin" on orders for select using(user_id=auth.uid() or is_admin());
create policy "commandes: admin modifie" on orders for update using(is_admin());
create policy "commandes: admin supprime" on orders for delete using(is_admin());

insert into storage.buckets(id,name,public) values('produits','produits',true) on conflict do nothing;
create policy "images: lecture publique" on storage.objects for select using(bucket_id='produits');
create policy "images: admin envoie" on storage.objects for insert with check(bucket_id='produits' and is_admin());
create policy "images: admin modifie" on storage.objects for update using(bucket_id='produits' and is_admin());
create policy "images: admin supprime" on storage.objects for delete using(bucket_id='produits' and is_admin());

insert into products(name,category,description,image_url,variants,sort) values
('Gel douche gommant curcuma','Gel douche','Atténue les taches, unifie le teint, adapté aux peaux sensibles.','img/curcuma.jpg','[{"l":"","p":8000}]',1),
('Gel douche cocktail','Gel douche','Acide de fruits, vitamines A, E et C. Gomme et éclaircit en douceur.','img/cocktail.jpg','[{"l":"","p":8000}]',2),
('Gel douche hibiscus','Gel douche','Exfolie doucement, nettoie, illumine et unifie la peau.','img/hibiscus.jpg','[{"l":"","p":8000}]',3),
('Savon noir','Savon','Beurre de cacao, acide lactique et acide kojique. Purifie et unifie.','img/savon-noir.jpg','[{"l":"","p":5000}]',4),
('Savon visage','Savon','Soin nettoyant pour le visage.',null,'[{"l":"Petit","p":2500},{"l":"Grand","p":3500}]',5),
('Crème corps Lumina','Crème corps','Crème corps éclaircissante anti-taches brunes.','img/creme-corps.jpg','[{"l":"Petit","p":8000},{"l":"Moyen","p":10000},{"l":"Grand","p":15000}]',6),
('Chantilly apaisante hydratante','Crème corps','Base hydratante 100% naturelle, sans éclaircissant.','img/chantilly.jpg','[{"l":"","p":7000}]',7),
('Crème correctrice visage','Crème corps','Très éclaircissante, anti-tache et anti-imperfections.','img/correctrice.jpg','[{"l":"","p":5000}]',8),
('Effaceur ébène','Crème corps','Soin ciblé pour unifier le teint.',null,'[{"l":"","p":2500}]',9),
('Lotion traitante','Autres','Antioxydante ultra-riche, booste l’éclat. Usage quotidien.','img/lotion.jpg','[{"l":"Petit","p":3500},{"l":"25 ml","p":5000}]',10),
('Sérum vitamine C','Autres','Éclat et uniformité du teint.',null,'[{"l":"","p":5000}]',11);

-- ÉTAPE FINALE : créez votre compte sur le site, puis lancez :
-- update profiles set role='admin' where phone='0708996760';
-- MISE À JOUR (communes + frais de livraison) : à lancer UNE fois dans Supabase > SQL Editor
create table if not exists communes(id uuid primary key default gen_random_uuid(),name text not null unique,fee integer not null default 0,active boolean default true);
alter table orders add column if not exists commune text;
alter table orders add column if not exists delivery_fee integer default 0;
alter table communes enable row level security;
create policy "communes: lecture publique" on communes for select using(active or is_admin());
create policy "communes: admin écrit" on communes for all using(is_admin()) with check(is_admin());
insert into communes(name,fee) values('Abobo',1500),('Adjamé',1500),('Anyama',2500),('Attécoubé',1500),('Bingerville',2500),('Cocody',1500),('Koumassi',1500),('Marcory',1500),('Plateau',1500),('Port-Bouët',2000),('Songon',3000),('Treichville',1500),('Yopougon',1500) on conflict do nothing;
