/*
====================================
	LAB 01: POSTGRESQL BASIC
====================================
Script Purpose:
	- Solve HomeWork

=====================================
*/

-- Create Database
CREATE DATABASE mydb;



-- 1. Create table myemployees

CREATE TABLE myemployees (
	employee_id INTEGER NOT NULL
	, first_name VARCHAR(15)
	, last_name VARCHAR(15)
	, title VARCHAR(50)
	, age INTEGER CHECK(age >= 0) 
	, salary FLOAT CHECK (salary < 100000)
);

-- Create KEY
ALTER TABLE myemployees
ADD CONSTRAINT employee_key PRIMARY KEY (employee_id);

-- Change Type for title
ALTER TABLE myemployees
ALTER COLUMN title SET DATA TYPE VARCHAR(50),
ALTER COLUMN title SET NOT NULL,
ALTER COLUMN title SET DEFAULT '';

-- 2. INSERT DATA INTO TABLE

TRUNCATE TABLE myemployees;
INSERT INTO myemployees (employee_id, first_name, last_name, title, age, salary)
VALUES
  (1, 'Jonie', 'Weber', 'Secretary', 28, 19500)
, (2, 'Potsy', 'Weber', 'Programmer', 32, 45300)
, (3, 'Dirk', 'Smith', 'Programmer II', 45, 75020)
, (4, 'Mike', 'Nicols', 'Programmer', 25, 35000)
, (5, 'Jim', 'Smith', 'Secretary', 24, 17000)
, (6, 'Dean', 'Yeager', 'Programmer II', 39, 73000)
, (7, 'Mark', 'Middleton', DEFAULT, 21, 10000); 



-- 3. HIỂN THỊ TẤT CẢ DỮ LIỆU TRONG BẢNG myemployees;
SELECT * FROM myemployees;

-- 4. HIỂN THỊ NHỮNG NHÂN VIÊN LƯƠNG < 30000
SELECT *
FROM myemployees
WHERE salary < 30000;

-- 5. FIRST NAME, LAST_NAME WHERE AGE > 30
SELECT
	first_name
	, last_name
FROM myemployees
WHERE
	age > 30;

-- 6. FIRST NAME, LAST NAME, SALARY WHERE TITLE 'Programmer'
SELECT
	first_name
	, last_name
	, salary
FROM myemployees
WHERE
	title = 'Programmer';

-- 7. LAST NAME LIKE 'ebe'
SELECT
	*
FROM myemployees
WHERE
	last_name LIKE '%ebe%';

-- 8. FIRST NAME IS 'Potsy'
SELECT
	*
FROM myemployees
WHERE
	first_name = 'Potsy';

-- 9. LAST NAME LIKE '%ith'
SELECT
	*
FROM myemployees
WHERE
	last_name LIKE '%ith';

-- 10. Jonie Weber ->  Jonie Williams.
UPDATE myemployees 
SET last_name = 'Williams'
WHERE last_name = 'Weber' AND first_name = 'Jonie';


-- 11. BIRTH DAY 'Dirk Smith' + 1
UPDATE myemployees 
SET age = age + 1 
WHERE first_name = 'Dirk' 
	AND last_name = 'Smith';

-- 12.  ‘Secretary’ -> ‘Administrative Assistant’

UPDATE myemployees 
SET title = 'Administrative Assistant' 
WHERE title = 'Secretary';

-- 13. lương nhỏ hơn 30000 được tăng thêm 3500
UPDATE myemployees
SET Salary = Salary + 3500
WHERE Salary < 30000;

-- 14. lương trên 33500 được tăng thêm 4500
UPDATE myemployees
SET Salary = Salary + 4500
WHERE Salary > 33500;

-- 15. title “Programmer II” -> “Programmer III” , title “Programmer” -> “Programmer II”.
SELECT * FROM myemployees;

UPDATE myemployees
SET title = 'Programmer III'
WHERE title = 'Programmer II';

UPDATE myemployees
SET title = 'Programmer II'
WHERE title = 'Programmer';

-- 16. Jonie Williams vừa xin nghỉ việc, xóa thông tin của cô ấy ra khỏi bảng
DELETE FROM myemployees
WHERE first_name = 'Jonie' AND last_name = 'Williams'

-- 17. Hiện tại đang thực hiện việc cắt giảm ngân sách, xoá những nhân viên có mức lương trên 70000
DELETE FROM myemployees
WHERE salary > 70000;

-- 18. Tạo 1 database tên music với owner là tên của bạn, encoding ‘UTF8’

-- Tạo user duynghia
CREATE USER duynghia WITH PASSWORD 'password';

-- Tao database
CREATE DATABASE music
WITH OWNER = duynghia
ENCODING = 'UTF8';

-- 19. Tạo các bảng với khóa chính và khóa ngoại theo mô hình thực thể bên dưới
-- Create table
CREATE TABLE track (
	id INTEGER NOT NULL
	, title VARCHAR(200)
	, len INTEGER
	, rating INTEGER
	, count INTEGER
	, album_id INTEGER
	, artist_id INTEGER
);

CREATE TABLE album (
	id INT NOT NULL 
	, title VARCHAR(200)
);

CREATE TABLE artist (
	id INTEGER NOT NULL
	, name VARCHAR(50)
);

-- Add primary key
ALTER TABLE track
ADD CONSTRAINT track_key PRIMARY KEY (id);

ALTER TABLE album
ADD CONSTRAINT album_key PRIMARY KEY (id);

ALTER TABLE artist
ADD CONSTRAINT artist_key PRIMARY KEY (id);

-- Add foreign key

ALTER TABLE track
ADD CONSTRAINT album_foreign_key FOREIGN KEY (album_id)
REFERENCES album (id);

ALTER TABLE track
ADD CONSTRAINT artist_foreign_key FOREIGN KEY (artist_id)
REFERENCES artist (id);

-- 20. Nhập dữ liệu cho database music từ các file: ‘artist.csv’, ‘album.csv’, 'track.csv’
-- Vì database misic ta tạo trong tài khoản user là duynghia. Mà lệnh copy thông thường chỉ có thể dùng trên supper user là postgres.
-- Vì vậy ta sử dụng psql trên terminal kết nối vào user duynghia và copy vào đó

-- Kết nối psql: psql -U duynghia -d music -h localhost -W (Nhập mật khẩu vào)

\copy artist (id, name) FROM 'D:\download\artist.csv' DELIMITER ',' CSV HEADER;

\copy  album(id, title) FROM 'D:\download\album.csv' DELIMITER ',' CSV HEADER;

\COPY track(id, title, len, rating, count, album_id, artist_id) FROM 'D:\download\track.csv' DELIMITER ',' CSV HEADER;







