-- create DATABASE hoge;
grant all privileges on database hoge to postgres;

\c hoge;

-- 削除 (TABLE)
DROP TABLE IF EXISTS FUGA;

-- 共通
CREATE TABLE FUGA (
    ID SERIAL,
    NAME VARCHAR(30)
);