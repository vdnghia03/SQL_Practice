/*
==============================
	TH LAB 2
- MSSV: 22280060
- Ho va Ten: Vo Duy Nghia
==============================
Purpose:
	Learn create role,.....
	Learn create schema

	Learning about JOIN, Aggregation, .....


==============================

*/

--1.Tạo ROLE ‘hradmin’
--2. Tạo database ‘hr’ với owner  là ‘hradmin’
--3. Trong db ‘hr’, tạo một schema ‘hrschema’ AUTHORIZATION hradmin
-- Ba ý trên được làm hoàn toàn trong dòng lệnh command line psql

CREATE ROLE hradmin WITH LOGIN PASSWORD '1234';

create database hr with owner hradmin;

\c hr
alter role hradmin with createdb;
create schema hrschema authorization hradmin;
create schema hrschema authorization hradmin;
set role to hradmin;
show search_path;
set search_path = hrschema;




--4. Trong schema ‘hrschema’, tạo các bảng theo mô hình thực thể dưới đây
set search_path = hrschema;
show search_path;
select current_role;
-- Show search_path để chắc chắc rằng ta đang sử dụng schema hrschema, nên chạy lệnh set search_path = hrschema trước
-- select current_role để đảm bảo ta đang dùng role hradmin

-- Tạo bảng 'regions'

CREATE TABLE regions (
    region_id INTEGER,
    region_name VARCHAR(100) NOT NULL
);

-- Tạo bảng 'countries'
CREATE TABLE countries (
    country_id CHAR(2),
    country_name VARCHAR(100) NOT NULL,
    region_id INTEGER
);

-- Tạo bảng 'locations'
CREATE TABLE locations (
    location_id INTEGER,
    street_address VARCHAR(255),
    postal_code VARCHAR(20),
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    country_id CHAR(2)
);

-- Tạo bảng 'departments'
CREATE TABLE departments (
    department_id INTEGER,
    department_name VARCHAR(100) NOT NULL,
    location_id INTEGER
);

-- Tạo bảng 'jobs'
CREATE TABLE jobs (
    job_id INTEGER,
    job_title VARCHAR(100) NOT NULL,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2)
);

-- Tạo bảng 'employees'
CREATE TABLE employees (
    employee_id INTEGER,
    first_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    hire_date DATE NOT NULL,
    job_id INTEGER,
    salary DECIMAL(10,2) NOT NULL,
    manager_id INTEGER,
    department_id INTEGER
);

-- Tạo bảng 'job_history'
CREATE TABLE job_history (
    employee_id INTEGER,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    job_id INTEGER,
    department_id INTEGER
);

-- Thêm khóa chính
ALTER TABLE regions ADD CONSTRAINT pk_regions PRIMARY KEY (region_id);
ALTER TABLE countries ADD CONSTRAINT pk_countries PRIMARY KEY (country_id);
ALTER TABLE locations ADD CONSTRAINT pk_locations PRIMARY KEY (location_id);
ALTER TABLE departments ADD CONSTRAINT pk_departments PRIMARY KEY (department_id);
ALTER TABLE jobs ADD CONSTRAINT pk_jobs PRIMARY KEY (job_id);
ALTER TABLE employees ADD CONSTRAINT pk_employees PRIMARY KEY (employee_id);
ALTER TABLE job_history ADD CONSTRAINT pk_job_history PRIMARY KEY (employee_id, start_date);

-- Thêm khóa ngoại
ALTER TABLE countries ADD CONSTRAINT fk_countries_region FOREIGN KEY (region_id) REFERENCES regions(region_id) ON DELETE SET NULL;
ALTER TABLE locations ADD CONSTRAINT fk_locations_country FOREIGN KEY (country_id) REFERENCES countries(country_id) ON DELETE SET NULL;
ALTER TABLE departments ADD CONSTRAINT fk_departments_location FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE SET NULL;
ALTER TABLE employees ADD CONSTRAINT fk_employees_job FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE SET NULL;
ALTER TABLE employees ADD CONSTRAINT fk_employees_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL;
ALTER TABLE employees ADD CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id) ON DELETE SET NULL;
ALTER TABLE job_history ADD CONSTRAINT fk_job_history_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE;
ALTER TABLE job_history ADD CONSTRAINT fk_job_history_job FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE SET NULL;
ALTER TABLE job_history ADD CONSTRAINT fk_job_history_department FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL;


-- 5. INSERT dữ liệu vào các bảng trên từ hr_data.sql -- Chạy trên command line 
\i 'D:/Workspace/DATABASE ADMIN/hr_data.sql'

SELECT table_name FROM information_schema.tables WHERE table_schema = 'hrschema';


-- 6. Thực hiện các câu truy vấn sau:
set search_path = hrschema;
show search_path;
select current_role;
-- Phải đảm bảo chọn đúng role và schema.

-- a. Hiển thị 3 ký tự đầu tiên của first_name dưới dạng chữ hoa
SELECT
    UPPER(SUBSTRING(first_name FROM 1 FOR 3)) 
FROM employees;

-- b. Hiển thị first_name của tất cả nhân viên sau khi xóa tất cả khoảng trắng đầu và cuối.
SELECT 
	TRIM(first_name) 
FROM employees;

-- c. Hiển thị first_name, last_name và độ dài của name(first_name+last_name)
SELECT
	first_name
	, last_name
	, LENGTH(TRIM(first_name)) + LENGTH(TRIM(last_name)) as name_length
FROM employees;

-- d. Giả sử lương trong bảng employees là lương theo năm, hiển thị first_name, last_name, lương theo tháng của từng nhân viên (làm tròn 2 chữ số thập phân)
SELECT
	first_name
	, last_name
	, ROUND(salary / 12, 2) AS salary_per_month
FROM employees;
-- e. Hiển thị họ tên, mức lương của những nhân viên có mức lương từ $10,000 đến $15,000.

-- f. Hiển thị họ tên, department ID của những nhân viên thuộc phòng ban có ID 3 hoặc 10, kết quả sắp xếp theo department ID với thứ tự tăng dần.
SELECT 
	first_name
	, last_name
	, department_id
FROM employees
WHERE department_id IN (3, 10)
ORDER BY department_id ASC;

-- g. Hiển thị họ tên, department ID, salary của những nhân viên thuộc phòng ban có ID 3 hoặc 10, và mức lương không nằm trong khoảng từ $10,000 đến $15,000
SELECT 
	first_name
	, last_name
	, department_id
	, salary
FROM employees
WHERE department_id IN (3, 10)
AND salary NOT BETWEEN 10000 AND 15000;

-- h. Hiển thị tên của những nhân viên có chứa chữ cái ‘c' và ‘e' trong firstname
SELECT
	first_name 
FROM employees
WHERE first_name ILIKE '%c%' 
AND first_name ILIKE '%e%';

-- i. Hiển thị last_name của những nhân viên có số lượng ký tự của lastname bằng 6.
SELECT 
	last_name 
FROM employees
WHERE
	LENGTH(last_name) = 6;
	
-- j. Hiển thị last_name của nhân viên có ký tự ‘e' nằm ở vị trí thứ 3 trong lastname.
SELECT
	last_name 
FROM employees
WHERE 
	SUBSTRING(last_name FROM 3 FOR 1) = 'e';

-- k. Hiển thị name (first_name, last_name), salary và 15% salary cho tất cả nhân viên.
SELECT 
	first_name
	, last_name
	, salary
	, salary * 0.15 AS salary_15
FROM employees;

-- l. Tổng số tiền lương phải trả cho nhân viên là bao nhiêu?
SELECT 
	SUM(salary) AS total_salary_of_company
FROM employees;

-- m. Mức lương tối đa, tối thiểu, mức lương trung bình và số lượng nhân viên của công ty là bao nhiêu? (làm tròn sau dấu , 2 chữ số thập phân)
SELECT 
    ROUND(MAX(salary), 2) AS max_salary
    , ROUND(MIN(salary), 2) AS min_salary
    , ROUND(AVG(salary), 2) AS avg_salary
    , COUNT(*) AS count_number_employee
FROM employees;

-- n. Hiển thị các job_id và job_title khác nhau hiện có trong bảng employees, sắp xếp theo job_id?
SELECT DISTINCT 
	e.job_id
	, j.job_title
FROM employees AS e
JOIN jobs AS j 
	ON e.job_id = j.job_id
ORDER BY e.job_id;

-- o. Mức lương tối đa của nhân viên ở vị trí Programmer?
SELECT 
	MAX(salary) AS max_salary
FROM employees AS e
JOIN jobs AS j 
	ON e.job_id = j.job_id
WHERE j.job_title = 'Programmer';

-- p. Chênh lệch giữa mức lương tối đa và mức lương tối thiểu của tất cả nhân viên là bao nhiêu?
SELECT 
	MAX(salary) - MIN(salary) AS salary_diff
FROM employees;


-- q. Hiển thị id, first_name, last_name của tất cả manager
SELECT 
	employee_id
	, first_name
	, last_name
FROM employees
WHERE 
	employee_id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL);

-- r. Hiển thị manager ID và mức lương thấp nhất của nhân viên chịu sự quản lý của manager ID tương ứng.
SELECT 
	manager_id
	, MIN(salary) AS min_salary_employee
FROM employees
WHERE 
	manager_id IS NOT NULL
GROUP BY 
	manager_id;

-- s. Hiển thị department ID, tên department và tổng số lương phải trả tương ứng của từng phòng ban, chỉ hiển thị những phòng ban có tổng lương lớn hơn 30000 và sắp xếp theo department_id
SELECT 
	d.department_id
	, d.department_name
	, SUM(e.salary) AS total_salary
FROM employees AS e
JOIN departments d 
	ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
HAVING SUM(e.salary) > 30000
ORDER BY d.department_id;

-- t. Hiển thị name, job_title, salary của những nhân viên không phải làm ở vị trí Programmer hoặc Shipping Clerk, và không có mức lương là $4,500, $10,000, hoặc $15,000
SELECT 
	e.first_name || ' ' || e.last_name AS name_fl
	, j.job_title
	, e.salary
FROM employees AS e
JOIN jobs AS j 
	ON e.job_id = j.job_id
WHERE j.job_title NOT IN ('Programmer', 'Shipping Clerk')
AND e.salary NOT IN (4500, 10000, 15000);

-- u. Mức lương trung bình của các phòng ban có trên 5 nhân viên?
SELECT 
	department_id
	, AVG(salary) AS ave_deparment_salary
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5;

-- v. Hiển thị job title và mức lương trung bình tương ứng
SELECT 
	j.job_title
	, AVG(e.salary) AS avg_salary
FROM employees AS e
JOIN jobs AS  j 
	ON e.job_id = j.job_id
GROUP BY j.job_title;


-- w. Hiển thị  tên manager, tên phòng ban và thành phố tương ứng
SELECT DISTINCT 
	m.first_name || ' ' || m.last_name AS manager_name 
    , d.department_name
    , l.city
FROM employees AS e
JOIN employees AS m
	ON e.manager_id = m.employee_id
JOIN departments d 
	ON e.department_id = d.department_id
JOIN locations AS l 
	ON d.location_id = l.location_id;

-- x. Hiển thị job title, tên employee và sự khác biệt giữa lương của từng nhân viên với mức lương thấp nhất trong công ty và chỉ hiển thị 3 kết quả có mức lương chênh lệch nhiều nhất.
SELECT 
	j.job_title
    , e.first_name || ' ' || e.last_name AS full_name 
    , e.salary - (SELECT MIN(salary) FROM employees) AS salary_difference
FROM employees AS e
JOIN jobs AS j 
	ON e.job_id = j.job_id
ORDER BY salary_difference DESC
LIMIT 3;

