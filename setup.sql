CREATE TABLE users (
    id SERIAL,
    email VARCHAR NOT NULL,
    password_hash VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    PRIMARY KEY (id),
    UNIQUE (email)
);

CREATE TABLE tags (
    name VARCHAR(100) NOT NULL,
    id SERIAL,
    PRIMARY KEY (id),
    UNIQUE (name)
);

CREATE TABLE is_tagged_with (
    tag_id INT NOT NULL,
    article_id INT NOT NULL,
    PRIMARY KEY (tag_id, article_id),
    FOREIGN KEY (tag_id) REFERENCES tags(id)
    FOREIGN KEY (article_id) REFERENCES article(id)
);

CREATE TABLE article (
    id SERIAL NOT NULL,
    title VARCHAR(100) NOT NULL,
    content VARCHAR NOT NULL,
    author_id SERIAL,
    PRIMARY KEY (id),
    FOREIGN KEY (author_id) REFERENCES users(id)
);