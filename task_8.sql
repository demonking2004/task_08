-- drop procedure if already exists
DROP PROCEDURE IF EXISTS get_empmst_by_dept;
DROP PROCEDURE IF EXISTS give_bonus;
DROP FUNCTION IF EXISTS get_empmst_count;
DROP FUNCTION IF EXISTS calculate_tax;
DROP FUNCTION IF EXISTS get_age;
DROP FUNCTION IF EXISTS get_city;
DROP PROCEDURE IF EXISTS salary_grade;
DROP PROCEDURE IF EXISTS insert_empmst;
DROP FUNCTION IF EXISTS get_deptname;
DROP PROCEDURE IF EXISTS give_annual_hike;
DROP PROCEDURE IF EXISTS show_new_empmsts;
DROP PROCEDURE IF EXISTS count_empmsts_by_city;
DROP PROCEDURE IF EXISTS print_messages;
DROP PROCEDURE IF EXISTS transfer_empmst;
DROP FUNCTION IF EXISTS empmst_exists;
DROP PROCEDURE IF EXISTS top_empmst_in_dept;
DROP FUNCTION IF EXISTS get_location_by_emp;
DROP PROCEDURE IF EXISTS raise_all_salaries;

-- USE your database
USE internship;


-- 1. Stored Procedure: Get empmsts from a department
DELIMITER //
CREATE PROCEDURE get_empmst_by_dept(IN p_deptno INT)
BEGIN
    SELECT empname, salary, city
    FROM empmst
    WHERE deptno = p_deptno;
END;
//

-- 2. Stored Procedure: Give bonus based on condition
CREATE PROCEDURE give_bonus(IN p_empno INT, IN p_bonus DECIMAL(8,2))
BEGIN
    DECLARE current_salary DECIMAL(8,2);
    SELECT salary INTO current_salary FROM empmst WHERE empno = p_empno;
    IF current_salary < 60000 THEN
        UPDATE empmst SET salary = salary + p_bonus WHERE empno = p_empno;
    ELSE
        SELECT 'No Bonus: Salary above threshold' AS status;
    END IF;
END;
//

-- 3. Function: Total empmst count
CREATE FUNCTION get_empmst_count()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM empmst;
    RETURN total;
END;
//

-- 4. Function: Calculate tax
CREATE FUNCTION calculate_tax(sal DECIMAL(8,2))
RETURNS DECIMAL(8,2)
DETERMINISTIC
BEGIN
    RETURN sal * 0.10;
END;
//

-- 5. Function: Calculate age
CREATE FUNCTION get_age(dob DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, dob, CURDATE());
END;
//

-- 6. Procedure: Salary grade
CREATE PROCEDURE salary_grade(IN p_empno INT)
BEGIN
    DECLARE sal DECIMAL(8,2);
    SELECT salary INTO sal FROM empmst WHERE empno = p_empno;
    IF sal < 50000 THEN
        SELECT 'Grade C' AS grade;
    ELSEIF sal BETWEEN 50000 AND 70000 THEN
        SELECT 'Grade B' AS grade;
    ELSE
        SELECT 'Grade A' AS grade;
    END IF;
END;
//

-- 7. Insert empmst with validation
CREATE PROCEDURE insert_empmst(
    IN p_empno INT,
    IN p_empname VARCHAR(15),
    IN p_deptno INT,
    IN p_salary DECIMAL(8,2),
    IN p_dob DATE,
    IN p_city VARCHAR(10)
)
BEGIN
    IF p_salary < 30000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary too low!';
    ELSE
        INSERT INTO empmst (empno, empname, deptno, salary, dob, city)
        VALUES (p_empno, p_empname, p_deptno, p_salary, p_dob, p_city);
    END IF;
END;
//

-- 8. Get department name by empno
CREATE FUNCTION get_deptname(p_empno INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE dname VARCHAR(20);
    SELECT d.deptname INTO dname
    FROM empmst e JOIN deptmst d ON e.deptno = d.deptno
    WHERE e.empno = p_empno;
    RETURN dname;
END;
//

-- 9. Procedure: Annual hike
CREATE PROCEDURE give_annual_hike(IN p_empno INT)
BEGIN
    DECLARE sal DECIMAL(8,2);
    SELECT salary INTO sal FROM empmst WHERE empno = p_empno;
    IF sal < 50000 THEN
        UPDATE empmst SET salary = salary * 1.10 WHERE empno = p_empno;
    ELSEIF sal BETWEEN 50000 AND 70000 THEN
        UPDATE empmst SET salary = salary * 1.07 WHERE empno = p_empno;
    ELSE
        UPDATE empmst SET salary = salary * 1.05 WHERE empno = p_empno;
    END IF;
END;
//

-- 10. Function: Get city
CREATE FUNCTION get_city(p_empno INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE city_name VARCHAR(10);
    SELECT city INTO city_name FROM empmst WHERE empno = p_empno;
    RETURN city_name;
END;
//

-- 11. Procedure: empmsts hired after year
CREATE PROCEDURE show_new_empmsts(IN p_year INT)
BEGIN
    SELECT empname, dob FROM empmst WHERE YEAR(dob) > p_year;
END;
//

-- 12. Procedure: Count empmsts in city
CREATE PROCEDURE count_empmsts_by_city(IN p_city VARCHAR(10))
BEGIN
    SELECT COUNT(*) AS total_empmsts FROM empmst WHERE city = p_city;
END;
//

-- 13. Procedure: Print N messages
CREATE PROCEDURE print_messages(IN n INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= n DO
        SELECT CONCAT('Message #', i) AS msg;
        SET i = i + 1;
    END WHILE;
END;
//

-- 14. Procedure: Transfer empmst
CREATE PROCEDURE transfer_empmst(IN p_empno INT, IN new_deptno INT)
BEGIN
    IF EXISTS (SELECT 1 FROM deptmst WHERE deptno = new_deptno) THEN
        UPDATE empmst SET deptno = new_deptno WHERE empno = p_empno;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid department number';
    END IF;
END;
//

-- 15. Function: empmst exists (1/0)
CREATE FUNCTION empmst_exists(p_empno INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE result INT;
    SELECT COUNT(*) INTO result FROM empmst WHERE empno = p_empno;
    RETURN result > 0;
END;
//

-- 16. Procedure: Top empmst in dept
CREATE PROCEDURE top_empmst_in_dept(IN p_deptno INT)
BEGIN
    SELECT empname, salary
    FROM empmst
    WHERE deptno = p_deptno
    ORDER BY salary DESC
    LIMIT 1;
END;
//

-- 17. Function: Get location from empno
CREATE FUNCTION get_location_by_emp(p_empno INT)
RETURNS VARCHAR(15)
DETERMINISTIC
BEGIN
    DECLARE loc VARCHAR(15);
    SELECT d.location INTO loc
    FROM deptmst d JOIN empmst e ON e.deptno = d.deptno
    WHERE e.empno = p_empno;
    RETURN loc;
END;
//

-- 18. Raise salaries for dept
CREATE PROCEDURE raise_all_salaries(IN p_deptno INT, IN percent DECIMAL(5,2))
BEGIN
    UPDATE empmst
    SET salary = salary + (salary * percent / 100)
    WHERE deptno = p_deptno;
END;
//
DELIMITER ;


-- Calls
CALL give_annual_hike(1001);
CALL show_new_empmsts(1992);
CALL count_empmsts_by_city('Delhi');
CALL print_messages(3);
CALL transfer_empmst(1002, 30);
SELECT get_city(1003);
SELECT empmst_exists(9999);
CALL top_empmst_in_dept(20);
SELECT get_location_by_emp(1004);
CALL raise_all_salaries(10, 8);
