/*
||  Name:          apply_plsql_lab7.sql
||  Date:          11 Nov 2016
||  Purpose:       Complete 325 Chapter 8 lab.
*/

SET SERVEROUTPUT ON SIZE UNLIMITED
SHOW ERRORS

-- Call previous library scripts (create video store)
@$LIB/cleanup_oracle.sql
@$LIB/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL apply_plsql_lab7.txt

-- You can fix the table by first validating it’s state with this query:
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name = 'DBA';

-- The next UPDATE statement should be inserted to ensure your iterative test cases all start at the same point, or common data state.
UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

-- A small anonymous block PL/SQL program lets you fix this mistake:
DECLARE
  /* Create a local counter variable. */
  lv_counter  NUMBER := 2;
 
  /* Create a collection of two-character strings. */
  TYPE numbers IS TABLE OF NUMBER;
 
  /* Create a variable of the roman_numbers collection. */
  lv_numbers  NUMBERS := numbers(1,2,3,4);
 
BEGIN
  /* Update the system_user names to make them unique. */
  FOR i IN 1..lv_numbers.COUNT LOOP
    /* Update the system_user table.*/
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;
 
    /* Increment the counter. */
    lv_counter := lv_counter + 1;
  END LOOP;
END;
/

-- It should update four rows, and you can verify the update with the following query:
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name LIKE 'DBA%';

-- You need this at the beginning to create the initial procedure during iterative testing.
BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/

-- SPOOL OFF;

-- ----------------------------------------------------------------------
-- STEP 1: Create an insert_contact procedure that writes an all or nothing procedure.
-- DROP PROCEDURE insert_contact;
CREATE OR REPLACE PROCEDURE insert_contact
( PV_FIRST_NAME 		VARCHAR2
, PV_MIDDLE_NAME 		VARCHAR2
, PV_LAST_NAME 			VARCHAR2
, PV_CONTACT_TYPE 		VARCHAR2
, PV_ACCOUNT_NUMBER 	VARCHAR2
, PV_MEMBER_TYPE 		VARCHAR2
, PV_CREDIT_CARD_NUMBER VARCHAR2
, PV_CREDIT_CARD_TYPE 	VARCHAR2
, PV_STATE_PROVINCE 	VARCHAR2
, PV_CITY 				VARCHAR2
, PV_POSTAL_CODE 		VARCHAR2
, PV_ADDRESS_TYPE 		VARCHAR2
, PV_COUNTRY_CODE 		VARCHAR2
, PV_AREA_CODE 			VARCHAR2
, PV_TELEPHONE_NUMBER 	VARCHAR2
, PV_TELEPHONE_TYPE 	VARCHAR2
, PV_USER_NAME 			VARCHAR2 
) IS


  -- Local variables
  lv_address_type        VARCHAR2(30);
  lv_contact_type        VARCHAR2(30);
  lv_credit_card_type    VARCHAR2(30);
  lv_member_type         VARCHAR2(30);
  lv_telephone_type      VARCHAR2(30);
  
  lv_created_by			 VARCHAR2(30);
  lv_creation_date		 DATE := SYSDATE;
  
CURSOR c( cv_table_name 	VARCHAR2 ,
		  cv_column_name  	VARCHAR2 ,
		  cv_lookup_type    VARCHAR2 ) IS
      SELECT common_lookup_id
		FROM common_lookup
        WHERE common_lookup_table = cv_table_name
        AND common_lookup_column = cv_column_name
        AND common_lookup_type = cv_lookup_type;

BEGIN

-- FOR LOOPS
FOR i IN c('MEMBER', 'MEMBER_TYPE', pv_member_type) LOOP
		lv_member_type := i.common_lookup_id;
		END LOOP;
        
FOR i IN c('CONTACT', 'CONTACT_TYPE', pv_contact_type) LOOP
		lv_contact_type := i.common_lookup_id;
		END LOOP;
        
FOR i IN c('MEMBER', 'CREDIT_CARD_TYPE', pv_credit_card_type) LOOP
		lv_credit_card_type := i.common_lookup_id;
		END LOOP;
        
FOR i IN c('ADDRESS', 'ADDRESS_TYPE', pv_address_type) LOOP
		lv_address_type := i.common_lookup_id;
		END LOOP;
        
FOR i IN c('TELEPHONE', 'TELEPHONE_TYPE', pv_telephone_type) LOOP
		lv_telephone_type := i.common_lookup_id;
		END LOOP;


SAVEPOINT savepoint_wes;

INSERT INTO member
  ( member_id
  , member_type
  , account_number
  , credit_card_number
  , credit_card_type
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( member_s1.NEXTVAL
  , lv_member_type
  , pv_account_number
  , pv_credit_card_number
  , pv_credit_card_type
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date
 );
 
 INSERT INTO contact
  ( contact_id
  , member_id
  , contact_type
  , last_name
  , first_name
  , middle_name
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date )
  VALUES
  ( contact_s1.NEXTVAL
  , member_s1.CURRVAL
  , lv_contact_type
  , pv_last_name
  , pv_first_name
  , pv_middle_name
  , lv_created_by
  , lv_creation_date
  , lv_created_by
  , lv_creation_date
 );
 
 INSERT INTO address VALUES
 ( 
 address_s1.NEXTVAL
 , contact_s1.CURRVAL
 , lv_address_type
 , pv_city
 , pv_state_province
 , pv_postal_code
 , lv_created_by
 , lv_creation_date
 , lv_created_by
 , lv_creation_date
 );
 
 INSERT INTO telephone VALUES
 ( 
 telephone_s1.NEXTVAL
 , contact_s1.CURRVAL
 , address_s1.CURRVAL
 , lv_telephone_type
 , pv_country_code
 , pv_area_code
 , pv_telephone_number
 , lv_created_by
 , lv_creation_date
 , lv_created_by
 , lv_creation_date
 );
 
COMMIT;
 
EXCEPTION 
  WHEN OTHERS THEN
    ROLLBACK TO savepoint_wes;
    RETURN;
END insert_contact;
/ 
SHOW ERRORS;

BEGIN
  insert_contact ( PV_FIRST_NAME => 'Charles'
  , PV_MIDDLE_NAME => 'Francis'
  , PV_LAST_NAME => 'Xavier'
  , PV_CONTACT_TYPE => 'CUSTOMER'
  , PV_ACCOUNT_NUMBER => 'SLC-000008'
  , PV_MEMBER_TYPE => 'INDIVIDUAL'
  , PV_CREDIT_CARD_NUMBER => '7777-6666-5555-4444'
  , PV_CREDIT_CARD_TYPE => 'DISCOVER_CARD'
  , PV_STATE_PROVINCE => 'Maine'
  , PV_CITY => 'Milbridge'
  , PV_POSTAL_CODE => '04658'
  , PV_ADDRESS_TYPE => 'HOME'
  , PV_COUNTRY_CODE => '001'
  , PV_AREA_CODE => '207'
  , PV_TELEPHONE_NUMBER => '111-1234'
  , PV_TELEPHONE_TYPE => 'HOME'
  , PV_USER_NAME => 'DBA 2');
END;
/
SHOW ERRORS

-- After you call the insert_contact procedure, you should be able to run the following verification query:

  COL full_name      FORMAT A24
  COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
  COL address        FORMAT A22
  COL telephone      FORMAT A14
 
  SELECT c.first_name
  ||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
         END
  ||     c.last_name AS full_name
  ,      m.account_number
  ,      a.city || ', ' || a.state_province AS address
  ,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
  FROM   member m INNER JOIN contact c
  ON     m.member_id = c.member_id INNER JOIN address a
  ON     c.contact_id = a.contact_id INNER JOIN telephone t
  ON     c.contact_id = t.contact_id
  AND    a.address_id = t.address_id
  WHERE  c.last_name = 'Xavier';