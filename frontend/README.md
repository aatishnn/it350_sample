# Sample Frontend for IT 350

This is a simple Vue project utilizing standard Vue libraries like vue-router for client-side routing. If you are unfamiliar with Vue, following links should help:

- [Vue Tutorial](https://vuejs.org/v2/guide/)
- [Vue Router for client-side navigation](https://router.vuejs.org/guide/#javascript)
- [Axios for making HTTP requests](https://blog.logrocket.com/how-to-make-http-requests-like-a-pro-with-axios/)

## Setup a demo database

Create a new database and run the contents of `frontend/database.sql` on it. If you get errors like:

```

ERROR: role "authenticator" already exists


```

comment out the following lines (86-88) in that file by adding -- in front of them like:

```sql
-- CREATE ROLE authenticator NOINHERIT;
-- CREATE ROLE admins;
-- CREATE ROLE anonymous;
```

## Setup PostgREST for this database

Create new PostgREST configuration maybe named `demo.conf` with the following settings:

```
db-uri = "postgres://<username>:<password>@127.0.0.1/<name_of_demo_database>"
db-schema = "public"
db-anon-role = "anonymous"
server-port=8000
jwt-secret = "reallyreallyreallyreallyverysafe123"
app.settings.jwt_secret = "reallyreallyreallyreallyverysafe123"
```

Use the same `username` and `password` that you used when you did a PostgREST setup for your project's database.

## Run PostgREST with this configuration file

```bash
postgrest ./demo.conf
```

## Frontend setup

Install Node and Yarn using the following links:

- [Install NodeJS and npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm#using-a-node-installer-to-install-nodejs-and-npm)
- Install yarn using `npm install --global yarn`

Clone this repo, go inside `frontend/` and run:

```
yarn install
```

Run the Vue.JS development server using:

```
yarn serve
```

You should have a demo frontend running on http://<server_ip>:8080.
