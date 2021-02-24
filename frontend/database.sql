CREATE TABLE users (
    userId SERIAL,
    email VARCHAR(256) NOT NULL,
    password_hash VARCHAR NOT NULL,
    name VARCHAR(100) NOT NULL,
    PRIMARY KEY (userId),
    UNIQUE (email)
);

CREATE TABLE tags (
    tagId SERIAL,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (tagId),
    UNIQUE (name)
);

CREATE TABLE articles (
    articleId SERIAL,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    userId INT NOT NULL,
    isPublished BOOLEAN DEFAULT FALSE NOT NULL,
    createdAt TIMESTAMP NOT NULL,
    updatedAt TIMESTAMP NOT NULL,
    PRIMARY KEY (articleId),
    FOREIGN KEY (userId) REFERENCES users(userId)
);

CREATE TABLE is_tagged_with (
    articleId INT NOT NULL,
    tagId INT NOT NULL,
    PRIMARY KEY (articleId, tagId),
    FOREIGN KEY (articleId) REFERENCES articles(articleId),
    FOREIGN KEY (tagId) REFERENCES tags(tagId)
);

CREATE OR REPLACE VIEW public.homepage_articles AS 
 SELECT articles.articleid,
    articles.title,
    "left"(articles.content, 200) AS short_content
   FROM articles
  WHERE articles.ispublished IS TRUE
  ORDER BY articles.createdat DESC
 LIMIT 10;

GRANT SELECT ON TABLE public.homepage_articles TO anonymous;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE public.homepage_articles TO admins;

CREATE OR REPLACE FUNCTION trigger_set_update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updatedAt = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trigger_set_insert_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.createdAt = NOW();
  NEW.updatedAt = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_update_timestamp
BEFORE UPDATE ON articles
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_update_timestamp();


CREATE TRIGGER set_insert_timestamp
BEFORE INSERT ON articles
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_insert_timestamp();

CREATE OR REPLACE FUNCTION publish(id integer)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE articles SET isPublished = TRUE WHERE articleId = id;
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;


CREATE ROLE authenticator NOINHERIT;
CREATE ROLE admins;
CREATE ROLE anonymous;

GRANT anonymous, admins TO authenticator;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO anonymous;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO admins;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admins;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admins;


-- Setup JWT generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TYPE IF EXISTS jwt_token CASCADE;
CREATE TYPE jwt_token AS (
  token text
);

CREATE OR REPLACE FUNCTION url_encode(data bytea) RETURNS text LANGUAGE sql AS $$
    SELECT translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;

CREATE OR REPLACE FUNCTION algorithm_sign(signables text, secret text, algorithm text)
RETURNS text LANGUAGE sql AS $$
WITH
  alg AS (
    SELECT CASE
      WHEN algorithm = 'HS256' THEN 'sha256'
      WHEN algorithm = 'HS384' THEN 'sha384'
      WHEN algorithm = 'HS512' THEN 'sha512'
      ELSE '' END AS id)
SELECT url_encode(hmac(signables, secret, alg.id)) FROM alg;
$$;


CREATE OR REPLACE FUNCTION sign(payload json, secret text, algorithm text DEFAULT 'HS256')
RETURNS text LANGUAGE sql AS $$
WITH
  header AS (
    SELECT url_encode(convert_to('{"alg":"' || algorithm || '","typ":"JWT"}', 'utf8')) AS data
    ),
  payload AS (
    SELECT url_encode(convert_to(payload::text, 'utf8')) AS data
    ),
  signables AS (
    SELECT header.data || '.' || payload.data AS data FROM header, payload
    )
SELECT
    signables.data || '.' ||
    algorithm_sign(signables.data, secret, algorithm) FROM signables;
$$;
--

CREATE OR REPLACE FUNCTION
signup(email text, password text, name text) RETURNS VOID
AS $$
  INSERT INTO users (email, password_hash, name) VALUES
    (signup.email, signup.password, signup.name);
$$ LANGUAGE sql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION
login(email TEXT, password TEXT) RETURNS jwt_token
  LANGUAGE plpgsql SECURITY DEFINER
  AS $$
DECLARE
  _role NAME;
  result jwt_token;
BEGIN
  SELECT users.userid FROM users WHERE users.email=login.email AND password_hash=login.password INTO _role;
  IF _role IS NULL THEN
    RAISE invalid_password USING message = 'invalid user or password';
  END IF;

  SELECT sign(
      row_to_json(r), current_setting('app.settings.jwt_secret')
    ) AS token
    from (
      SELECT 'admins' AS role, login.email AS email, _role AS user_id,
         extract(epoch from now())::integer + 3600*60*60 as exp
    ) r
    INTO result;

  RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION
  login(text,text),
  signup(text, text, text)
  TO anonymous;