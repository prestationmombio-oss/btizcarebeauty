# Ktiz Care Beauty — boutique PWA (Supabase + Vercel)

## Installation en 5 étapes
1. **Supabase** : créez un projet, ouvrez *SQL Editor*, collez `supabase.sql` puis *Run*.
2. **Authentication > Providers > Email** : désactivez **Confirm email** (les clients se connectent avec leur numéro de téléphone, converti en `numéro@ktiz.ci`).
3. **config.js** : renseignez `SUPABASE_URL` et `SUPABASE_KEY` (clé *anon public*, Project Settings > API).
4. **Déploiement** : poussez le dossier sur GitHub puis importez-le dans Vercel (site statique, aucune configuration).
5. **Compte admin** : créez votre compte sur le site, puis dans le SQL Editor :
   `update profiles set role='admin' where phone='0708996760';`
   Le bouton **Admin** apparaît : gestion des commandes (statuts) et des produits (prix, formats, photos).

## Fonctionnement
- Sans `SUPABASE_URL`, le site fonctionne en mode démo avec le catalogue intégré.
- Commande sans compte possible ; elle est enregistrée dans Supabase puis envoyée sur WhatsApp.
- - Gestionnaire (admin) : Commandes, Produits (photos), Réglages (communes + frais de livraison). Si la base existe déjà, lancez seulement `supabase-maj.sql`.
- Les formats « Petit / Moyen / Grand » (Lumina, lotion, savon visage) sont à renommer dans Admin > Produits (ex. `100g:8000, 250g:10000`).
- Les photos sans image (savon visage, effaceur ébène, sérum) se téléversent depuis l'admin.
