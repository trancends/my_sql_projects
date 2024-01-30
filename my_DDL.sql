-- Catatan keuangan
CREATE DATABASE catatan_keuangan_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE transaction_type AS ENUM('CREDIT','DEBIT');

CREATE TABLE expenses (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    date DATE NOT NULL,
    amount DOUBLE PRECISION NOT NULL,
    transaction_type transaction_type NOT NULL,
    balance DOUBLE PRECISION NOT NULL,
    description TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP 
);



--- ENIGMA LAUNDRY ---
CREATE SEQUENCE customer_seq START WITH 1;
CREATE SEQUENCE product_seq START WITH 1;
CREATE SEQUENCE employee_seq START WITH 1;
CREATE SEQUENCE bill_seq START WITH 1;
CREATE SEQUENCE bill_detail_seq START WITH 1;

CREATE TABLE customer ( 
  id VARCHAR(100) NOT NULL DEFAULT ('C_' || nextval('customer_seq')),
  name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(15) NOT  NULL,
  address VARCHAR(255) NOT NULL,
  CONSTRAINT "customer_pkey" PRIMARY KEY ("id")
);

CREATE TABLE employee ( 
  id VARCHAR(100) NOT NULL DEFAULT ('E_' || nextval('employee_seq')),
  name VARCHAR(100) NOT NULL,
  phone_number VARCHAR(15) NOT  NULL,
  address VARCHAR(255) NOT NULL,
  CONSTRAINT "employee_pkey" PRIMARY KEY ("id")
);

CREATE TABLE product ( 
  id VARCHAR(100) NOT NULL DEFAULT ('P_' || nextval('product_seq')),
  name VARCHAR(100) NOT NULL,
  price INTEGER NOT NULL,
  CONSTRAINT "product_pkey" PRIMARY KEY ("id")
);

CREATE TABLE bill ( 
  id VARCHAR(100) NOT NULL DEFAULT ('B_' || nextval('bill_seq')),
  bill_date DATE NOT NULL,
  entry_date DATE NOT NULL,
  finish_date DATE NOT NULL,
  employee_id VARCHAR(100) NOT NULL,
  customer_id VARCHAR(100) NOT NULL,
  CONSTRAINT "bill_pkey" PRIMARY KEY ("id")
);

CREATE TABLE bill_detail ( 
  id VARCHAR(100) NOT NULL DEFAULT ('BD_' || nextval('bill_detail_seq')),
  bill_id VARCHAR(100) NOT NULL,
  product_id VARCHAR(100) NOT NULL,
  quantity INTEGER NOT NULL,
  CONSTRAINT "bill_detail_pkey" PRIMARY KEY ("id")
);

ALTER TABLE bill ADD CONSTRAINT "bill_employee_id_fkey" FOREIGN KEY ("employee_id") REFERENCES employee ("id");
ALTER TABLE bill ADD CONSTRAINT "bill_customer_id_fkey" FOREIGN KEY ("customer_id") REFERENCES customer ("id");

ALTER TABLE bill_detail ADD CONSTRAINT "bill_detail_bill_id_fkey" FOREIGN KEY ("bill_id") REFERENCES bill ("id");
ALTER TABLE bill_detail ADD CONSTRAINT "bill_detail_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES product ("id");

SELECT
	t.id AS bill_id,
	to_char(t.bill_date, 'DD/MM/YYYY') AS bill_date,
	to_char(t.entry_date, 'DD/MM/YYYY') AS entry_date,
	to_char(t.finish_date, 'DD/MM/YYYY') AS finish_date,
	e.id AS employee_id,
	e.name AS employee_name,
	e.phone_number AS employee_phone_number,
	e.address AS employee_address,
	c.id AS customer_id,
	c.name AS customer_name,
	c.phone_number AS customer_phone_number,
	c.address AS customer_address,
	array_agg(
		jsonb_build_object(
			'id', bd.id,
			'product_id', bd.product_id,
			'product_name', p.name,
			'product_price', p.price,
			'product_unit', p.unit,
			'quantity', bd.quantity
		)
	) AS bill_details
FROM
	bill t
JOIN
	employee e ON t.employee_id = e.id
JOIN
	customer c ON t.customer_id = c.id
JOIN
	bill_detail bd ON t.id = bd.bill_id
JOIN
	product p ON bd.product_id = p.id
GROUP BY
	t.id, t.bill_date, t.entry_date, t.finish_date, e.id, e.name, e.phone_number, e.address, c.id, c.name, c.phone_number, c.address
ORDER BY
	t.id ASC;

SELECT t.id, to_char(t.bill_date, 'DD/MM/YYYY'), to_char(t.entry_date, 'DD/MM/YYYY'), to_char(t.finish_date, 'DD/MM/YYYY'),
      e.id, e.name, e.phone_number, e.address,
      c.id, c.name, c.phone_number, c.address,
      bd.id, bd.product_id, p.name, p.price, p.unit, bd.quantity
FROM bill t
JOIN employee e ON t.employee_id = e.id
JOIN customer c ON t.customer_id = c.id
JOIN bill_detail bd ON t.id = bd.bill_id
JOIN product p ON bd.product_id = p.id
ORDER BY t.id DESC;

--- INSTRUCTOR LED APP 
-- Active: 1703737077721@@127.0.0.1@5432@instructor_led_app_db@public
-- Active: 1703737077721@@127.0.0.1@5432@postgres@public
CREATE DATABASE instructor_led_app_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE TYPE status_type AS ENUM('PROCESS','FINISH');
CREATE TYPE role_type AS ENUM('ADMIN','PARTICIPANT','TRAINER');

CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL ,
    password VARCHAR(50) NOT NULL,
    role role_type NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE schedules (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    documentation text,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE TABLE questions (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    schedule_id uuid NOT NULL,
    description TEXT NOT NULL,
    status status_type DEFAULT 'PROCESS',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
 
);

CREATE TABLE attendances (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid NOT NULL,
    schedule_id uuid NOT NULL,
    created_at timestamp  DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp  DEFAULT CURRENT_TIMESTAMP,
    deleted_at timestamp
)

ALTER TABLE schedules ADD CONSTRAINT "schedules_user_id_fkey"  FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE questions ADD CONSTRAINT "questions_schedule_id_fkey" FOREIGN KEY (schedule_id) REFERENCES schedules(id);
ALTER TABLE questions ADD CONSTRAINT "questions_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE attendances ADD CONSTRAINT "attendances_user_id_fkey" FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE attendances ADD CONSTRAINT "attendances_schedule_id_fkey" FOREIGN KEY (schedule_id) REFERENCES schedules(id);

-- TODO APP
CREATE DATABASE todo_app_db;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE authors (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(50),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(100),
  role VARCHAR(50),
  created_at timestamp DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp
);

CREATE TABLE tasks (
  id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
  title VARCHAR(100),
  content TEXT,
  author_id uuid,
  created_at timestamp DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp
  CONSTRAINT task_author_id_fkey FOREIGN KEY (author_id)
    REFERENCES authors(id)
);


SELECT
	a.id,
	a.name,
	a.email,
    a.updated_at,
	a.created_at,
	array_agg(
		jsonb_build_object(
			'id', t.id,
			'title', t.title,
			'content', t.content,
			'author_ID', t.author_id,
			'created_at', t.created_at
		)
	) AS tasks
FROM
	authors a
JOIN
	tasks t  ON a.id = t.author_id
WHERE a.id = '40af5ee7-5a6f-4193-9d6f-66e9d2cf12fb'
GROUP BY
    a.id,a.name, a.email,a.created_at,a.updated_at ORDER BY "id" asc LIMIT 100;

SELECT
	a.id,
	a.name,
	a.email,
    a.updated_at,
	a.created_at,
	t.id  as t_id,
	t.title as t_title,
	t.content as t_content,
	t.author_id as t_author_id,
	t.created_at as t_created_at,
	t.updated_at as t_updated_at
FROM
	authors a
JOIN
	tasks t  ON a.id = t.author_id
ORDER BY a.email;
