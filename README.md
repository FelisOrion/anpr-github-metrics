# Gitmetrics

Implementazione di un servizio che analizzi le issue github creando metriche:

![alt text](https://raw.githubusercontent.com/FelisOrion/anpr-github-metrics/master/doc/assets/screen1.png)
![alt text](https://raw.githubusercontent.com/FelisOrion/anpr-github-metrics/master/doc/assets/screen2.png)
![alt text](https://raw.githubusercontent.com/FelisOrion/anpr-github-metrics/master/doc/assets/screen3.png)
![alt text](https://raw.githubusercontent.com/FelisOrion/anpr-github-metrics/master/doc/assets/screen4.png)

Tempo di prima risposta (medio e sua distribuzione)
Tempo di chiusura di un ticket (medio e sua distribuzione)
Numero di ticket aperti/chiusi

Issue non commentate (da)
Issue aperte NON nelle labels
Issue chiuse senza commento


Il servizio generico inserendo link del repository

Per abilitare login con servezi Oauth di github, bisogna impostare dal account setting cliend id, dopo di che aggiungere tutte le chiavi in /config/dev.ex


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Yes Yes, there is not place like 127.0.0.1
