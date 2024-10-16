CREATE TABLE REGIONS 
(
  REGION_GUID VARCHAR2(32) NOT NULL 
, REGION_NAME VARCHAR2(25) NOT NULL 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT REGIONS_PK PRIMARY KEY 
  (
    REGION_GUID 
  )
  ENABLE 
);

CREATE TABLE EMPLOYEES 
(
  EMPLOYEE_GUID VARCHAR2(32) NOT NULL 
, FIRST_NAME VARCHAR2(20) 
, LAST_NAME VARCHAR2(25) NOT NULL 
, EMAIL VARCHAR2(25) NOT NULL 
, PHONE_NUMBER VARCHAR2(20) 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT EMPLOYEES_PK PRIMARY KEY 
  (
    EMPLOYEE_GUID 
  )
  ENABLE 
);

CREATE TABLE JOBS 
(
  JOB_GUID VARCHAR2(32) NOT NULL 
, JOB_TITLE VARCHAR2(35) NOT NULL 
, MIN_SALARY NUMBER(6) 
, MAX_SALARY NUMBER(6) 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT JOBS_PK PRIMARY KEY 
  (
    JOB_GUID 
  )
  ENABLE 
);

CREATE TABLE COUNTRIES 
(
  COUNTRY_GUID VARCHAR2(32) NOT NULL 
, COUNTRY_NAME VARCHAR2(40) NOT NULL 
, REGION_GUID VARCHAR2(32) NOT NULL 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT COUNTRIES_PK PRIMARY KEY 
  (
    COUNTRY_GUID 
  )
  ENABLE 
);

ALTER TABLE COUNTRIES
ADD CONSTRAINT COUNTRIES_FK1 FOREIGN KEY
(
  REGION_GUID 
)
REFERENCES REGIONS
(
  REGION_GUID 
)
ENABLE;

CREATE TABLE LOCATIONS 
(
  LOCATION_GUID VARCHAR2(32) NOT NULL 
, STREET_ADDRESS VARCHAR2(40) NOT NULL 
, POSTAL_CODE VARCHAR2(12) 
, CITY VARCHAR2(30) NOT NULL 
, STATE_PROVINCE VARCHAR2(25) 
, COUNTRY_GUID VARCHAR2(32) NOT NULL 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT LOCATIONS_PK PRIMARY KEY 
  (
    LOCATION_GUID 
  )
  ENABLE 
);

ALTER TABLE LOCATIONS
ADD CONSTRAINT LOCATIONS_FK1 FOREIGN KEY
(
  COUNTRY_GUID 
)
REFERENCES COUNTRIES
(
  COUNTRY_GUID 
)
ENABLE;

CREATE TABLE DEPARTMENTS 
(
  DEPARTMENT_GUID VARCHAR2(32) NOT NULL 
, DEPARTMENT_NAME VARCHAR2(30) NOT NULL 
, LOCATION_GUID VARCHAR2(32) NOT NULL 
, MANAGER_GUID VARCHAR2(32) 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT DEPARTMENTS_PK PRIMARY KEY 
  (
    DEPARTMENT_GUID 
  )
  ENABLE 
);

ALTER TABLE DEPARTMENTS
ADD CONSTRAINT DEPARTMENTS_FK1 FOREIGN KEY
(
  LOCATION_GUID 
)
REFERENCES LOCATIONS
(
  LOCATION_GUID 
)
ENABLE;

ALTER TABLE DEPARTMENTS
ADD CONSTRAINT DEPARTMENTS_FK2 FOREIGN KEY
(
  MANAGER_GUID 
)
REFERENCES EMPLOYEES
(
  EMPLOYEE_GUID 
)
ENABLE;

CREATE TABLE EMPLOYMENT 
(
  EMPLOYMENT_GUID VARCHAR2(32) NOT NULL 
, EMPLOYEE_GUID VARCHAR2(32) NOT NULL 
, JOB_GUID VARCHAR2(32) NOT NULL 
, DEPARTMENT_GUID VARCHAR2(32) NOT NULL 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT EMPLOYMENT_PK PRIMARY KEY 
  (
    EMPLOYMENT_GUID 
  )
  ENABLE 
);

ALTER TABLE EMPLOYMENT
ADD CONSTRAINT EMPLOYMENT_FK1 FOREIGN KEY
(
  EMPLOYEE_GUID 
)
REFERENCES EMPLOYEES
(
  EMPLOYEE_GUID 
)
ENABLE;

ALTER TABLE EMPLOYMENT
ADD CONSTRAINT EMPLOYMENT_FK2 FOREIGN KEY
(
  DEPARTMENT_GUID 
)
REFERENCES DEPARTMENTS
(
  DEPARTMENT_GUID 
)
ENABLE;

ALTER TABLE EMPLOYMENT
ADD CONSTRAINT EMPLOYMENT_FK3 FOREIGN KEY
(
  JOB_GUID 
)
REFERENCES JOBS
(
  JOB_GUID 
)
ENABLE;


CREATE TABLE EMPLOYMENT_PAY 
(
  EMPLOYMENT_PAY_GUID VARCHAR2(32) NOT NULL 
, EMPLOYMENT_GUID VARCHAR2(32) NOT NULL 
, EFFECTIVE_DATE DATE NOT NULL 
, SALARY NUMBER(8,2) 
, COMMISSION_PCT NUMBER 
, CREATED_ID VARCHAR2(30) 
, CREATED_DATE DATE 
, UPDATED_ID VARCHAR2(30) 
, UPDATED_DATE DATE 
, CONSTRAINT EMPLOYMENT_PAY_PK PRIMARY KEY 
  (
    EMPLOYMENT_PAY_GUID 
  )
  ENABLE 
);


ALTER TABLE EMPLOYMENT_PAY
ADD CONSTRAINT EMPLOYMENT_PAY_UK1 UNIQUE 
(
  EMPLOYMENT_GUID ,EFFECTIVE_DATE
)
ENABLE;

ALTER TABLE EMPLOYMENT_PAY
ADD CONSTRAINT EMPLOYMENT_PAY_FK1 FOREIGN KEY
(
  EMPLOYMENT_GUID 
)
REFERENCES EMPLOYMENT
(
  EMPLOYMENT_GUID 
)
ENABLE;



--first 8 triggers--
DECLARE
    v_sql VARCHAR2(1000);

    CURSOR table_cursor IS
    SELECT table_name 
    FROM user_tables;

BEGIN
    FOR t IN table_cursor LOOP
        v_sql := 'CREATE OR REPLACE TRIGGER TRG_' || t.table_name || 
                 '_FP BEFORE INSERT OR UPDATE ON ' || t.table_name ||
                 ' FOR EACH ROW ' ||
                 ' BEGIN ' ||
                 '   IF INSERTING THEN ' ||
                 '       :NEW.created_id := user; ' ||
                 '       :NEW.created_date := systimestamp; ' ||
                 '   END IF; ' ||
                 '   :NEW.updated_id := user; ' ||
                 '   :NEW.updated_date := systimestamp; ' ||
                 ' END;';

        EXECUTE IMMEDIATE v_sql;
    END LOOP;
END;
/



-- next 8 triggers--
CREATE OR REPLACE PROCEDURE secure_rows AS
    v_current_time TIMESTAMP;
BEGIN
    v_current_time := SYSTIMESTAMP;

    IF TO_NUMBER(TO_CHAR(v_current_time, 'HH24')) NOT BETWEEN 7 AND 18 THEN
        RAISE_APPLICATION_ERROR(-20001,'Access must be between 7am and 6pm.');
    END IF;
END secure_rows;
/

DECLARE
    v_sql VARCHAR2(1000);

    CURSOR table_cursor IS
    SELECT table_name 
    FROM user_tables;

BEGIN
    FOR t IN table_cursor LOOP
        v_sql := 'CREATE OR REPLACE TRIGGER TRG_' || t.table_name || 
                 '_SECURE_ROWS BEFORE INSERT OR UPDATE OR DELETE ON ' || t.table_name ||
                 ' BEGIN' ||
                 '  secure_rows;' ||
                 ' END;';

        EXECUTE IMMEDIATE v_sql;
    END LOOP;
END;
/



--views--
CREATE VIEW V_EMPLOYEE AS
SELECT
    E.EMPLOYEE_GUID,
    E.FIRST_NAME,
    E.EMAIL,
    E.PHONE_NUMBER,
    MIN(EP.EFFECTIVE_DATE) AS HIRE_DATE
FROM
    EMPLOYEES E
JOIN
    EMPLOYMENT EMP ON E.EMPLOYEE_GUID = EMP.EMPLOYEE_GUID
JOIN
    EMPLOYMENT_PAY EP ON EMP.EMPLOYMENT_GUID = EP.EMPLOYMENT_GUID 
group by 
E.EMPLOYEE_GUID, E.FIRST_NAME, E.EMAIL, E.PHONE_NUMBER;


CREATE VIEW V_EMPLOYMENT AS
SELECT
    E.EMPLOYEE_GUID,
    E.FIRST_NAME,
    E.EMAIL,
    E.PHONE_NUMBER,
    EP.EMPLOYMENT_GUID,
    EP.SALARY,
    EP.COMMISSION_PCT,
    min(EMP.created_date) as start_date,
    max(EP.effective_date) as end_date
FROM
    EMPLOYEES E
JOIN
    EMPLOYMENT EMP ON E.EMPLOYEE_GUID = EMP.EMPLOYEE_GUID
JOIN
    EMPLOYMENT_PAY EP ON EMP.EMPLOYMENT_GUID = EP.EMPLOYMENT_GUID
GROUP BY
    E.EMPLOYEE_GUID,
    E.FIRST_NAME,
    E.EMAIL,
    E.PHONE_NUMBER,
    EP.EMPLOYMENT_GUID,
    EP.SALARY,
    EP.COMMISSION_PCT;





CREATE VIEW V_EMPLOYMENT_SALARY_RANK AS
SELECT
    D.DEPARTMENT_GUID,
    SUM(EP.SALARY) AS Total_Salary,
    RANK() OVER (PARTITION BY D.DEPARTMENT_GUID ORDER BY SUM(EP.SALARY) DESC) AS Salary_Rank
FROM
    DEPARTMENTS D
JOIN
    EMPLOYMENT E ON D.DEPARTMENT_GUID = E.DEPARTMENT_GUID
JOIN
    EMPLOYMENT_PAY EP ON E.EMPLOYMENT_GUID = EP.EMPLOYMENT_GUID
GROUP BY
    D.DEPARTMENT_GUID;
    
    
    
    
--triggers
CREATE OR REPLACE TRIGGER TRG_EMPLOYMENT_PAY_CHK
BEFORE INSERT OR UPDATE ON EMPLOYMENT_PAY
FOR EACH ROW
DECLARE
    v_min_salary JOBS.MIN_SALARY%TYPE;
    v_max_salary JOBS.MAX_SALARY%TYPE;
BEGIN
    SELECT MIN_SALARY, MAX_SALARY
    INTO v_min_salary, v_max_salary
    FROM JOBS
    WHERE JOB_GUID = (SELECT JOB_GUID FROM EMPLOYMENT WHERE EMPLOYMENT_GUID = :NEW.EMPLOYMENT_GUID);
    IF ((:NEW.SALARY < v_min_salary AND v_min_salary IS NOT NULL) OR 
    (:NEW.SALARY > v_max_salary AND v_max_salary IS NOT NULL)) THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary must be within the valid range for the job.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_LOCATIONS_CHK
BEFORE INSERT OR UPDATE ON LOCATIONS
FOR EACH ROW
DECLARE
    v_country_name VARCHAR2(100);
BEGIN
    SELECT COUNTRY_NAME INTO v_country_name
    FROM COUNTRIES
    WHERE COUNTRY_GUID = :NEW.COUNTRY_GUID;

    IF v_country_name = 'United States' THEN
        IF NOT REGEXP_LIKE(:NEW.Postal_Code, '^[0-9]{5}(-[0-9]{4})?$') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Incorrect Postal Code for the United States.');
        END IF;
    ELSIF v_country_name = 'Canada' THEN
        IF NOT REGEXP_LIKE(:NEW.Postal_Code, '^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ][ -]?[0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Incorrect Postal Code for Canada.');
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER TRG_JOBS_CHK
BEFORE INSERT OR UPDATE ON JOBS
FOR EACH ROW
BEGIN
    IF :NEW.Min_Salary IS NOT NULL AND :NEW.Max_Salary IS NOT NULL AND :NEW.Min_Salary > :NEW.Max_Salary THEN
        RAISE_APPLICATION_ERROR(-20001, 'Min_Salary must be less than Max_Salary.');
    END IF;
END;
/



