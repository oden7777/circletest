-- create database contract;
grant all privileges on database contract to postgres;

\c contract;

-- 参考 (https://confl.arms.dmm.com/pages/viewpage.action?pageId=61689977#id-「購入API」と「契約に伴うお金の流れを記録管理するAPI」-売買契約)

-- 削除 (TABLE)
DROP TABLE IF EXISTS CLIENT_ACCESSES;
DROP TABLE IF EXISTS TRANSACTION_LOGS;
DROP TABLE IF EXISTS ITEMS;
DROP TABLE IF EXISTS CONTRACT_ITEMS;
DROP TABLE IF EXISTS CONTRACTS;
DROP TABLE IF EXISTS BILLING;
DROP TABLE IF EXISTS SETTLEMENT;
DROP TABLE IF EXISTS BILLING_MAP;
DROP TABLE IF EXISTS SCHEDULES;
DROP TABLE IF EXISTS RECEIPT_LOGS;
DROP TABLE IF EXISTS RECEIPT_STATES;
DROP TABLE IF EXISTS OPERATION_LOGS;

-- 削除 (SEQUENCE)
DROP SEQUENCE IF EXISTS SEQ_TENANT_ID;
DROP SEQUENCE IF EXISTS SEQ_ITEM_ID;
DROP SEQUENCE IF EXISTS SEQ_CONTRACT_ITEM_ID;
DROP SEQUENCE IF EXISTS SEQ_CONTRACT_ID;
DROP SEQUENCE IF EXISTS SEQ_SCHEDULE_ID;
DROP SEQUENCE IF EXISTS SEQ_RECEIPT_LOGS_ID;
DROP SEQUENCE IF EXISTS SEQ_RECEIPT_STATES_ID;
DROP SEQUENCE IF EXISTS SEQ_TRANSACTION_SEQUENCE;
DROP SEQUENCE IF EXISTS SEQ_BILLING_ID;
DROP SEQUENCE IF EXISTS SEQ_SETTLEMENT_ID;

-- 共通
CREATE TABLE OPERATION_LOGS (
    CREATED_BY VARCHAR(20),
    CREATED_AT TIMESTAMP WITH TIME ZONE,
    UPDATED_BY VARCHAR(20),
    UPDATED_AT TIMESTAMP WITH TIME ZONE
);

-- クライアント情報
CREATE TABLE CLIENT_ACCESSES (
    TRANSACTION_ID VARCHAR(25),
    CLIENT_IP VARCHAR(15),
    CLIENT_USER_AGENT VARCHAR(256),
    CLIENT_COUNTRY_CODE CHAR(3),
    CLIENT_DEVICE_MODEL_NAME VARCHAR(32),
    CLIENT_DEVICE_OS_NAME VARCHAR(32),
    CLIENT_DEVICE_OS_VERSION VARCHAR(32),
    CLIENT_DEVICE_BROWSER_CATEGORY VARCHAR(32),
    CLIENT_DEVICE_BROWSER_VERSION VARCHAR(32),
    CLIENT_ORIGIN VARCHAR(16)
);

-- 取引履歴
CREATE SEQUENCE SEQ_TRANSACTION_SEQUENCE CYCLE;
CREATE TABLE TRANSACTION_LOGS (
    TRANSACTION_ID VARCHAR(25),
    TRANSACTION_DATE TIMESTAMP WITH TIME ZONE,
    TRANSACTION_SEQUENCE SMALLINT,
    CONTRACT_ID CHAR(25),
    CONTRACT_ITEM_ID CHAR(25),
    CONTRACT_BILLING_ID CHAR(25),
    TENANT_ID VARCHAR(20),
    CATEGORY VARCHAR(32),
    SUB_CATEGORY VARCHAR(32),
    ITEM_ID CHAR(25),
    TRANSACTION_TYPE VARCHAR(10),
    SELLING_PRICE DECIMAL,
    CONSUMPTION_TAX DECIMAL,
    ITEM_QUANTITY INT,
    TRANSACTION_DETAIL VARCHAR(256),
    VERIFICATION_KEY VARCHAR(25),
    VERIFICATION_TIME TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY(TRANSACTION_DATE, TRANSACTION_SEQUENCE)
) INHERITS (OPERATION_LOGS);

-- アイテム名
CREATE SEQUENCE SEQ_TENANT_ID CYCLE;
CREATE SEQUENCE SEQ_ITEM_ID CYCLE;
CREATE TABLE ITEMS (
    TENANT_ID VARCHAR(20),
    ITEM_ID CHAR(25),
    ITEM_NAME VARCHAR(256),
    ITEM_TYPE VARCHAR(20),
    PRIMARY KEY(TENANT_ID, ITEM_ID)
) INHERITS (OPERATION_LOGS);

-- 契約明細
CREATE SEQUENCE SEQ_CONTRACT_ITEM_ID CYCLE;
CREATE TABLE CONTRACT_ITEMS (
    CONTRACT_ITEM_ID  CHAR(25) PRIMARY KEY,
    CONTRACT_ID VARCHAR(25),
    CONTRACT_ITEM_NO INT,
    UID VARCHAR(20),
    TENANT_ID VARCHAR(20),
    CATEGORY VARCHAR(32),
    SUB_CATEGORY VARCHAR(32),
    ITEM_ID CHAR(25),
    LIST_PRICE DECIMAL,
    SELLING_PRICE DECIMAL,
    CONSUMPTION_TAX DECIMAL,
    ITEM_AMOUNT INTEGER,
    DETAILED_RULE VARCHAR(64)
) INHERITS (OPERATION_LOGS);

-- 契約
CREATE SEQUENCE SEQ_CONTRACT_ID CYCLE;
CREATE TABLE CONTRACTS (
    CONTRACT_ID CHAR(25) PRIMARY KEY,
    UID VARCHAR(20),
    CONTRACT_TYPE varchar(2),
    CONTRACT_STATUS varchar(2),
    CREDIT_FACILITIES_STATUS varchar(2),
    DELETED smallint
) INHERITS (OPERATION_LOGS);

----------------------------------------------------------
-- 月額スケジュール
----------------------------------------------------------
CREATE SEQUENCE SEQ_SCHEDULE_ID CYCLE;
CREATE TABLE SCHEDULES (
    SCHEDULE_ID CHAR(25) PRIMARY KEY,
    CONTRACT_ID VARCHAR(25) NOT NULL,
    TENANT_ID VARCHAR(20) NOT NULL,
    PAYMENT_METHOD VARCHAR(20) NOT NULL,
    PAYMENT_PRICE DECIMAL,
    CLOSING_DATETIME TIMESTAMP WITH TIME ZONE NOT NULL,
    SCHEDULED_DATETIME TIMESTAMP WITH TIME ZONE NOT NULL,
    BILLING_METHOD VARCHAR(20) NOT NULL,
    BILLING_DATETIME TIMESTAMP WITH TIME ZONE,
    STATUS SMALLINT,
    ADDITIONAL_INFORMATION TEXT
) INHERITS (OPERATION_LOGS);
COMMENT ON TABLE SCHEDULES IS '月額スケジュール';
COMMENT ON COLUMN SCHEDULES.SCHEDULE_ID IS 'スケジュールID';
COMMENT ON COLUMN SCHEDULES.CONTRACT_ID IS '契約ID';
COMMENT ON COLUMN SCHEDULES.TENANT_ID IS 'テナントID';
COMMENT ON COLUMN SCHEDULES.PAYMENT_METHOD IS '決済種別';
COMMENT ON COLUMN SCHEDULES.PAYMENT_PRICE IS '決済金額';
COMMENT ON COLUMN SCHEDULES.CLOSING_DATETIME IS '締め日';
COMMENT ON COLUMN SCHEDULES.SCHEDULED_DATETIME IS '請求予定日';
COMMENT ON COLUMN SCHEDULES.BILLING_METHOD IS '請求種別';
COMMENT ON COLUMN SCHEDULES.BILLING_DATETIME IS '請求実行日時';
COMMENT ON COLUMN SCHEDULES.STATUS IS '実行結果'; -- TODO 0,1なのか？保留はある？
COMMENT ON COLUMN SCHEDULES.ADDITIONAL_INFORMATION IS '付随情報';

----------------------------------------------------------
-- 領収書発行状態
----------------------------------------------------------
CREATE SEQUENCE SEQ_RECEIPT_STATES_ID CYCLE;
CREATE TABLE RECEIPT_STATES (
   ID SERIAL PRIMARY KEY,
   BILLING_ID VARCHAR(30) NOT NULL,
   PAYMENT_ID VARCHAR(30) NOT NULL,
   COUNTER INTEGER DEFAULT 0 NOT NULL,
   UNIQUE(BILLING_ID, PAYMENT_ID)
) INHERITS (OPERATION_LOGS);
COMMENT ON TABLE RECEIPT_STATES IS '領収書発行状態';
COMMENT ON COLUMN RECEIPT_STATES.ID IS 'ID';
COMMENT ON COLUMN RECEIPT_STATES.BILLING_ID IS '請求ID';
COMMENT ON COLUMN RECEIPT_STATES.PAYMENT_ID IS '決済ID';
COMMENT ON COLUMN RECEIPT_STATES.COUNTER IS '領収書発行履歴カウンタ';

----------------------------------------------------------
-- 領収書発行履歴
----------------------------------------------------------
-- FIXME: 先に親のテーブルを作成し、テーブル毎の外部キー関係を記載する必要がある。（Related to 請求 and 決済台帳）
CREATE SEQUENCE SEQ_RECEIPT_LOGS_ID CYCLE;
CREATE TABLE RECEIPT_LOGS (
    ID SERIAL PRIMARY KEY,
    ISSUE_DATETIME TIMESTAMP WITH TIME ZONE NOT NULL,
    PAYMENT_DATETIME TIMESTAMP WITH TIME ZONE NOT NULL,
    BILLING_ID VARCHAR(30) NOT NULL,
    PAYMENT_ID VARCHAR(30) NOT NULL,
    PROVISO VARCHAR(500),
    PAYMENT_METHOD INTEGER NOT NULL,
    OPERATOR VARCHAR(30),
    JOB INTEGER NOT NULL,
    RECEIPT_STATES_ID BIGINT,
    DELETED boolean DEFAULT false NOT NULL
) INHERITS (OPERATION_LOGS);
COMMENT ON TABLE RECEIPT_LOGS IS '領収書発行履歴';
COMMENT ON COLUMN RECEIPT_LOGS.ID IS 'ID';
COMMENT ON COLUMN RECEIPT_LOGS.ISSUE_DATETIME IS '発行日時';
COMMENT ON COLUMN RECEIPT_LOGS.PAYMENT_DATETIME IS '決済日時';
COMMENT ON COLUMN RECEIPT_LOGS.BILLING_ID IS '請求ID';
COMMENT ON COLUMN RECEIPT_LOGS.PAYMENT_ID IS '決済ID';
COMMENT ON COLUMN RECEIPT_LOGS.PROVISO IS '但し書き';
COMMENT ON COLUMN RECEIPT_LOGS.PAYMENT_METHOD IS '決済種別（01:cc | 02:dmmpoint)';
COMMENT ON COLUMN RECEIPT_LOGS.OPERATOR IS '操作したユーザ名'; -- TODO: UPDATED_BY を利用するか否か？
COMMENT ON COLUMN RECEIPT_LOGS.JOB IS '操作種別';
COMMENT ON COLUMN RECEIPT_LOGS.RECEIPT_STATES_ID IS 'RECEIPT_STATES.ID';

-- 外部キー設定
ALTER TABLE RECEIPT_LOGS ADD CONSTRAINT FK_RECEIPT_LOGS_RECEIPT_STATES_ID FOREIGN KEY (RECEIPT_STATES_ID)
REFERENCES RECEIPT_STATES(ID)
MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- 請求
CREATE SEQUENCE SEQ_BILLING_ID CYCLE;
CREATE TABLE BILLING (
    ID SERIAL PRIMARY KEY,
    BILLING_ID CHAR(25),
    UID VARCHAR(20),
    BILLING_TYPE varchar(2),
    BILLING_STATUS varchar(2),
    BILLING_DATE TIMESTAMP WITH TIME ZONE,
    BILLING_QUANTITY DECIMAL,
    SETTLEMENT_QUANTITY DECIMAL,
    BILLING_TAX DECIMAL,
    SELLING_QUANTITY DECIMAL,
    CONSUMPTION_TAX DECIMAL,
    DELETED smallint
) INHERITS (OPERATION_LOGS);
COMMENT ON TABLE BILLING IS '請求';
COMMENT ON COLUMN BILLING.BILLING_ID IS '請求ID';
COMMENT ON COLUMN BILLING.UID IS 'ユーザ識別子';
COMMENT ON COLUMN BILLING.BILLING_TYPE IS '請求種別';
COMMENT ON COLUMN BILLING.BILLING_STATUS IS '請求状態';
COMMENT ON COLUMN BILLING.BILLING_DATE IS '請求日時';
COMMENT ON COLUMN BILLING.BILLING_QUANTITY IS '請求金額';
COMMENT ON COLUMN BILLING.SETTLEMENT_QUANTITY IS '決済額(税込)';
COMMENT ON COLUMN BILLING.BILLING_TAX IS '売上内消費税額';
COMMENT ON COLUMN BILLING.SELLING_QUANTITY IS '売上計上額(税込)';
COMMENT ON COLUMN BILLING.CONSUMPTION_TAX IS '決済内消費税額';
COMMENT ON COLUMN BILLING.DELETED IS '論理削除フラグ';

-- 決済台帳
CREATE SEQUENCE SEQ_SETTLEMENT_ID CYCLE;
CREATE TABLE SETTLEMENT (
    ID SERIAL PRIMARY KEY,
    SETTLEMENT_ID CHAR(25),
    SETTLEMENT_TYPE VARCHAR(2),
    BILLING_ID CHAR(25),
    TRANSACTION_ID CHAR(25),
    SETTLEMENT_DATE TIMESTAMP WITH TIME ZONE,
    SETTLEMENT_QUANTITY DECIMAL,
    SETTLEMENT_STATUS VARCHAR(2),
    DETAIL VARCHAR(64),
    DELETED smallint
) INHERITS (OPERATION_LOGS);
COMMENT ON TABLE SETTLEMENT IS '決済台帳';
COMMENT ON COLUMN SETTLEMENT.SETTLEMENT_ID IS '決済ID';
COMMENT ON COLUMN SETTLEMENT.SETTLEMENT_TYPE IS '決済種別';
COMMENT ON COLUMN SETTLEMENT.BILLING_ID IS '請求ID';
COMMENT ON COLUMN SETTLEMENT.TRANSACTION_ID IS 'トランザクションID';
COMMENT ON COLUMN SETTLEMENT.SETTLEMENT_DATE IS '決済日';
COMMENT ON COLUMN SETTLEMENT.SETTLEMENT_QUANTITY IS '決済金額';
COMMENT ON COLUMN SETTLEMENT.SETTLEMENT_STATUS IS '決済状態';
COMMENT ON COLUMN SETTLEMENT.DETAIL IS '詳細情報';
COMMENT ON COLUMN SETTLEMENT.DELETED IS '論理削除フラグ';

-- 請求マップ
CREATE TABLE BILLING_MAP (
    ID SERIAL PRIMARY KEY,
    BILLING_ID CHAR(25),
    CONTRACT_ID CHAR(25),
    TRANSACTION_ID CHAR(25),
    BILLING_DATE TIMESTAMP WITH TIME ZONE,
    DELETED smallint
) INHERITS (OPERATION_LOGS);
COMMENT ON TABLE BILLING_MAP IS '請求マップ';
COMMENT ON COLUMN BILLING_MAP.BILLING_ID IS '請求ID';
COMMENT ON COLUMN BILLING_MAP.CONTRACT_ID IS '契約ID';
COMMENT ON COLUMN BILLING_MAP.TRANSACTION_ID IS 'トランザクションID';
COMMENT ON COLUMN BILLING_MAP.BILLING_DATE IS '請求日';
COMMENT ON COLUMN BILLING_MAP.DELETED IS '論理削除フラグ';
