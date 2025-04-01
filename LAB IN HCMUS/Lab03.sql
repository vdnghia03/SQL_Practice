/*
==============================
	TH LAB 3
- MSSV: 22280060
- Ho va Ten: Vo Duy Nghia
==============================
Purpose:
	TH Lab 3 viết truy vấn, CTE, ......
==============================

*/

-- =====================================
-- TH CTE LAB 3
-- ====================================

-- Các bảng đã dùng dựa hoàn toàn trên file forum.db được chạy trong psql để tạo bảng, tạo khóa ngoại và insert dữ liêu.

-- Giờ ta chỉ cần set role, set search path cho đúng để sử dụng được các bảng trên.
set role to forum;
show search_path;
set search_path = forum;
show search_path;


-- Tạo 1 bảng tạm t_posts có cấu trúc và dữ liệu như bảng posts
DROP TABLE IF EXISTS t_posts;

CREATE TEMP TABLE t_posts AS 
SELECT * FROM posts;

select * from t_posts;

-- Tạo bảng delete_posts có cấu trúc như bảng posts (không có dữ liệu)
CREATE TABLE delete_posts AS
	SELECT * FROM posts LIMIT 0;

SELECT * FROM delete_posts;

-- Xóa những dòng dữ liệu trong bảng t_posts có category tên là Database, đồng thời các dòng bị xóa đó được insert vào bảng delete_posts. (CTE)
WITH deleted_rows AS (
    DELETE FROM t_posts 
    USING categories 
    WHERE t_posts.category = categories.id 
    	AND categories.title = 'Database'
    RETURNING t_posts.*
)
INSERT INTO delete_posts 
SELECT * FROM deleted_rows;

SELECT * FROM delete_posts;

-- Tạo bảng tạm t_posts2 có cấu trúc và dữ liệu như bảng posts
CREATE temp TABLE t_posts2 AS
	SELECT * FROM posts;

-- Tạo bảng inserted_posts có cấu trúc như bảng posts (không có dữ liệu)
CREATE TABLE inserted_posts AS
	SELECT * FROM posts LIMIT 0;

-- Di chuyển (move) tất cả dữ liệu trong bảng t_posts2 vào bảng inserted_posts. (CTE)
WITH move_rows AS (
    DELETE FROM t_posts2 RETURNING *
)
INSERT INTO inserted_posts
SELECT * FROM move_rows;

SELECT * FROM inserted_posts;



-- ======================================
--  TH Tiếp theo bài tập tuần 2
-- ======================================

-- Trước tiên set role và set search_path cho hợp lí
SET role hradmin;
SET search_path = hrschema;

-- a. Hiển thị danh sách các phòng ban (department_name, city) kèm theo số lượng nhân viên, mức lương thấp nhất, cao nhất, trung bình và tổng lương của phòng ban tương ứng, sắp xếp theo id.
SELECT 
    d.department_id
    , d.department_name
    , l.city
    , COUNT(e.employee_id) AS total_employees
    , MIN(e.salary) AS min_salary
    , MAX(e.salary) AS max_salary
    , ROUND(AVG(e.salary), 2) AS avg_salary
    , SUM(e.salary) AS total_salary
FROM departments d
JOIN locations l ON d.location_id = l.location_id
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name, l.city
ORDER BY d.department_id;

-- b. Hiển thị danh sách các phòng ban (department_name, city) chỉ thuộc khu vực Americas kèm theo số lượng nhân viên, tổng lương của phòng ban tương ứng, sắp xếp theo tổng lương từ cao đến thấp và chỉ hiển thị danh sách có tổng lương > 30000.

WITH filtered_departments AS (
    SELECT 
		d.department_id
		, d.department_name
		, l.city
    FROM departments d
    JOIN locations l 
		ON d.location_id = l.location_id
    JOIN countries c 
		ON l.country_id = c.country_id
    JOIN regions r 
		ON c.region_id = r.region_id
    WHERE r.region_name = 'Americas'
)
SELECT 
    fd.department_name,
    fd.city,
    COUNT(e.employee_id) AS total_employees,
    SUM(e.salary) AS total_salary
FROM filtered_departments fd
LEFT JOIN employees e ON fd.department_id = e.department_id
GROUP BY fd.department_name, fd.city
HAVING SUM(e.salary) > 30000
ORDER BY total_salary DESC;

-- c. Hiển thị danh sách các nhân viên được tuyển dụng vào tháng 6 nhưng loại trừ những nhân viên ở London.
SELECT
	e.employee_id
	, e.first_name
	, e.last_name
	, e.hire_date
FROM employees e
WHERE EXTRACT(MONTH FROM e.hire_date) = 6
AND e.department_id NOT IN (
	SELECT 
		d.department_id
	FROM departments d
	JOIN locations l
		ON d.location_id = l.location_id
	WHERE l.city = 'London'
);


-- d. Hiển thị danh sách các manager (id, first_name, salary, job_title) có mức lương thuộc vào top 5 mức lương cao nhất.
SELECT
	e.employee_id
	, e.first_name
	, e.salary
	, j.job_title
FROM employees e
JOIN jobs j
	ON e.job_id = j.job_id
WHERE e.employee_id IN (
	SELECT DISTINCT m.manager_id
	FROM employees m
	WHERE manager_id IS NOT NULL	
)
ORDER BY e.salary DESC
LIMIT 5
;

-- e. Hiển thị first_name, last_name, salary, manager_id của những nhân viên chịu sự quản lý của các manager làm việc ở 'United States of America' mà có mức lương lớn hơn mức lương trung bình của các thành viên trong nhóm tương ứng.
SELECT 
	e.first_name
	, e.last_name
	, e.salary
	, e.manager_id
FROM employees e
WHERE e.manager_id IN (
    -- Lấy danh sách manager_id làm việc ở USA
    SELECT DISTINCT e2.employee_id
    FROM employees e2
    JOIN departments d 
		ON e2.department_id = d.department_id
    JOIN locations l 
		ON d.location_id = l.location_id
    JOIN countries c 
		ON l.country_id = c.country_id
    WHERE c.country_name = 'United States of America'
)
AND e.salary > (
    -- Lấy mức lương trung bình của nhóm có cùng manager_id
    SELECT AVG(e3.salary) 
    FROM employees e3
    WHERE e3.manager_id = e.manager_id
);
