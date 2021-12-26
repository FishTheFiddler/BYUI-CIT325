/*
||  Name:           apply_plsql_lab8.sql
||  Student:        Wes Peterson
||  Date:           11/6/2021
||  Purpose:        Complete 325 Chapter 9 lab.
||  Dependencies:   Run the Oracle Database 12c PL/SQL Programming setup programs.
*/

SET NULL ''
SET ECHO ON
SET FEEDBACK ON
SET PAGESIZE 49999
SET SERVEROUTPUT ON SIZE UNLIMITED

-- Call previous library scripts (create video store)
@$LIB/cleanup_oracle.sql
@$LIB/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- @/home/student/Data/cit325/lab7/apply_plsql_lab7.sql


-- Open log file.
SPOOL apply_plsql_lab8.txt

/*******************************************************************************
Inserts for Member Table 
*******************************************************************************/
	INSERT INTO system_user
	    VALUES ( 6
                ,'BONDSB'
                ,1
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'DBA')
                ,'Bonds'
                ,'Barry'
                ,'L'
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
                ,SYSDATE
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
                ,SYSDATE );

	INSERT INTO system_user
        VALUES ( 7
                ,'CURRYW'
                ,1
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'DBA')
                ,'Curry'
                ,'Wardell'
                ,'S'
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
                ,SYSDATE
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
                ,SYSDATE );

	
	INSERT INTO system_user
        VALUES ( -1
                ,'ANONYMOUS'
                ,1
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'DBA')
                ,''
                ,''
                ,''
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
                ,SYSDATE
                ,(SELECT c.common_lookup_id
                    FROM common_lookup c
                    WHERE c.common_lookup_type = 'SYSTEM_ADMIN')
                ,SYSDATE);

/*************************************************************************
STEP 0: Before running the script..make sure this stuff works
**************************************************************************/
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



DROP SEQUENCE member_s1;
DROP SEQUENCE contact_s1;
DROP SEQUENCE address_s1;
DROP SEQUENCE telephone_s1; 

 CREATE SEQUENCE member_s1
 START WITH     1
 INCREMENT BY   1;
 
 CREATE SEQUENCE contact_s1
 START WITH     1
 INCREMENT BY   1;
 
 CREATE SEQUENCE address_s1
 START WITH     1
 INCREMENT BY   1;
 
 CREATE SEQUENCE telephone_s1
 START WITH     1
 INCREMENT BY   1;
 

/*************************************************************************
STEP 1: Create a contact_package package SPECIFICATION.
**************************************************************************/

CREATE OR REPLACE PACKAGE contact_package IS
	PROCEDURE insert_contact
            ( pv_first_name         VARCHAR2 
            , pv_middle_name        VARCHAR2 
            , pv_last_name          VARCHAR2 
            , pv_contact_type       VARCHAR2 
            , pv_account_number     VARCHAR2 
            , pv_member_type        VARCHAR2 
            , pv_credit_card_number VARCHAR2 
            , pv_credit_card_type   VARCHAR2
            , pv_city               VARCHAR2 
            , pv_state_province     VARCHAR2 
            , pv_postal_code        VARCHAR2 
            , pv_address_type       VARCHAR2 
            , pv_country_code       VARCHAR2 
            , pv_area_code          VARCHAR2
            , pv_telephone_number   VARCHAR2
            , pv_telephone_type     VARCHAR2
            , pv_user_name          VARCHAR2 );

	PROCEDURE insert_contact
            ( pv_first_name         VARCHAR2 
            , pv_middle_name        VARCHAR2 
            , pv_last_name          VARCHAR2 
            , pv_contact_type       VARCHAR2 
            , pv_account_number     VARCHAR2 
            , pv_member_type        VARCHAR2 
            , pv_credit_card_number VARCHAR2 
            , pv_credit_card_type   VARCHAR2
            , pv_city               VARCHAR2 
            , pv_state_province     VARCHAR2 
            , pv_postal_code        VARCHAR2 
            , pv_address_type       VARCHAR2 
            , pv_country_code       VARCHAR2 
            , pv_area_code          VARCHAR2
            , pv_telephone_number   VARCHAR2
            , pv_telephone_type     VARCHAR2
            , pv_user_id            NUMBER := NULL ); 
    END contact_package;
    /

-- This was to test whether or not the specification compiled correctly. It did
DESC contact_package;



/*************************************************************************
STEP 2: Create a contact_package package BODY.  This will utilize my lab 
		from last week.
**************************************************************************/
CREATE OR REPLACE PACKAGE BODY contact_package IS 
	PROCEDURE insert_contact
            ( pv_first_name         VARCHAR2 
            , pv_middle_name        VARCHAR2 
            , pv_last_name          VARCHAR2 
            , pv_contact_type       VARCHAR2 
            , pv_account_number     VARCHAR2 
            , pv_member_type        VARCHAR2 
            , pv_credit_card_number VARCHAR2 
            , pv_credit_card_type   VARCHAR2
            , pv_city               VARCHAR2 
            , pv_state_province     VARCHAR2 
            , pv_postal_code        VARCHAR2 
            , pv_address_type       VARCHAR2 
            , pv_country_code       VARCHAR2 
            , pv_area_code          VARCHAR2
            , pv_telephone_number   VARCHAR2
            , pv_telephone_type     VARCHAR2
            , pv_user_name          VARCHAR2 ) IS

		  -- Local variables
		  lv_address_type        VARCHAR2(30);
		  lv_contact_type        VARCHAR2(30);
		  lv_credit_card_type    VARCHAR2(30);
		  lv_member_type         VARCHAR2(30);
		  lv_telephone_type      VARCHAR2(30);
     --     lv_member_id 			 VARCHAR2(30);
		  
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
 /*           
	CURSOR get_member( cv_account_number VARCHAR2) IS
		SELECT m.member_id
        FROM member m
        WHERE m.account_number = cv_account_number;
*/ 
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

	SELECT system_user_id
	INTO lv_created_by
	FROM system_user
	WHERE system_user_name = pv_user_name;

/*
    OPEN get_member(pv_account_number);
	FETCH get_member INTO lv_member_id;
	IF get_member%NOTFOUND THEN
*/

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
	  , lv_credit_card_type
	  , lv_created_by
	  , lv_creation_date
	  , lv_created_by
	  , lv_creation_date
	 );
--    END IF;

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
	END insert_contact;
	 
-- Second Procedure ***********************************************
    PROCEDURE insert_contact
            ( pv_first_name         VARCHAR2 
            , pv_middle_name        VARCHAR2 
            , pv_last_name          VARCHAR2 
            , pv_contact_type       VARCHAR2 
            , pv_account_number     VARCHAR2 
            , pv_member_type        VARCHAR2 
            , pv_credit_card_number VARCHAR2 
            , pv_credit_card_type   VARCHAR2
            , pv_city               VARCHAR2 
            , pv_state_province     VARCHAR2 
            , pv_postal_code        VARCHAR2 
            , pv_address_type       VARCHAR2 
            , pv_country_code       VARCHAR2 
            , pv_area_code          VARCHAR2
            , pv_telephone_number   VARCHAR2
            , pv_telephone_type     VARCHAR2
            , pv_user_id            NUMBER := NULL ) IS
            
            -- Local variables
		  lv_address_type        VARCHAR2(30);
		  lv_contact_type        VARCHAR2(30);
		  lv_credit_card_type    VARCHAR2(30);
		  lv_member_type         VARCHAR2(30);
		  lv_telephone_type      VARCHAR2(30);
          lv_member_id 			 VARCHAR2(30);
		  
		  lv_created_by          NUMBER := NVL(pv_user_id,-1);
		  lv_creation_date		 DATE := SYSDATE;

  
  
	CURSOR c( cv_table_name 	VARCHAR2 ,
			  cv_column_name  	VARCHAR2 ,
			  cv_lookup_type    VARCHAR2 ) IS
		  SELECT common_lookup_id
			FROM common_lookup
			WHERE common_lookup_table = cv_table_name
			AND common_lookup_column = cv_column_name
			AND common_lookup_type = cv_lookup_type;
	
    CURSOR get_member(cv_account_number VARCHAR2) IS
		SELECT m.member_id
        FROM member m
        WHERE m.account_number = cv_account_number;
        
        

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
    
    OPEN get_member(pv_account_number);
	FETCH get_member INTO lv_member_id;
    
	IF get_member%NOTFOUND THEN
    
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
		  , lv_credit_card_type
		  , lv_created_by
		  , lv_creation_date
		  , lv_created_by
		  , lv_creation_date
		 );
     END IF;
      
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
	END insert_contact;
END contact_package;
/
	SHOW ERRORS;
    

/*************************************************
You can confirm the inserts with the following queries. 
**************************************************************************/
-- SYSTEM USERS
COL system_user_id  FORMAT 9999  HEADING "System|User ID"
COL system_user_name FORMAT A12  HEADING "System|User Name"
COL first_name       FORMAT A10  HEADING "First|Name"
COL middle_initial   FORMAT A2   HEADING "MI"
COL last_name        FORMAT A10  HeADING "Last|Name"
SELECT system_user_id
,      system_user_name
,      first_name
,      middle_initial
,      last_name
FROM   system_user
WHERE  last_name IN ('Bonds','Curry')
OR     system_user_name = 'ANONYMOUS';



-- USER VALUES
BEGIN
contact_package.insert_contact
(PV_FIRST_NAME =>  'Charlie',
PV_MIDDLE_NAME =>  ' ',
PV_LAST_NAME =>  	'Brown',
PV_CONTACT_TYPE => 'CUSTOMER',
PV_ACCOUNT_NUMBER => 'SLC-000011',
PV_MEMBER_TYPE => 'GROUP',
PV_CREDIT_CARD_NUMBER => '8888-6666-8888-4444',
PV_CREDIT_CARD_TYPE => 'VISA_CARD',
PV_CITY =>  'Lehi', 
PV_STATE_PROVINCE => 'Utah',
PV_POSTAL_CODE => '	84043',
PV_ADDRESS_TYPE => 'HOME',
PV_COUNTRY_CODE => '001',
PV_AREA_CODE => '207',
PV_TELEPHONE_NUMBER => '877-4321',
PV_TELEPHONE_TYPE => 'HOME',
-- PV_USER_NAME => 'DBA 3',
PV_USER_ID => ''
);
END;
/
SHOW ERRORS

BEGIN
contact_package.insert_contact
(PV_FIRST_NAME =>  'Peppermint',
PV_MIDDLE_NAME =>  ' ',
PV_LAST_NAME =>  	'Patty',
PV_CONTACT_TYPE => 'CUSTOMER',
PV_ACCOUNT_NUMBER => 'SLC-000011',
PV_MEMBER_TYPE => 'GROUP',
PV_CREDIT_CARD_NUMBER => '8888-6666-8888-4444',
PV_CREDIT_CARD_TYPE => 'VISA_CARD',
PV_CITY =>  'Lehi', 
PV_STATE_PROVINCE => 'Utah',
PV_POSTAL_CODE => '	84043',
PV_ADDRESS_TYPE => 'HOME',
PV_COUNTRY_CODE => '001',
PV_AREA_CODE => '207',
PV_TELEPHONE_NUMBER => '877-4321',
PV_TELEPHONE_TYPE => 'HOME',
-- PV_USER_NAME => '',
PV_USER_ID => ''
);
END;
/

SHOW ERRORS
BEGIN
contact_package.insert_contact
(PV_FIRST_NAME =>  'Sally',
PV_MIDDLE_NAME =>  ' ',
PV_LAST_NAME =>  	'Brown',
PV_CONTACT_TYPE => 'CUSTOMER',
PV_ACCOUNT_NUMBER => 'SLC-000011',
PV_MEMBER_TYPE => 'GROUP',
PV_CREDIT_CARD_NUMBER => '8888-6666-8888-4444',
PV_CREDIT_CARD_TYPE => 'VISA_CARD',
PV_CITY =>  'Lehi', 
PV_STATE_PROVINCE => 'Utah',
PV_POSTAL_CODE => '	84043',
PV_ADDRESS_TYPE => 'HOME',
PV_COUNTRY_CODE => '001',
PV_AREA_CODE => '207',
PV_TELEPHONE_NUMBER => '877-4321',
PV_TELEPHONE_TYPE => 'HOME',
-- PV_USER_NAME => '',
PV_USER_ID => '6'
);
END;
/

SHOW ERRORS

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
WHERE  c.last_name IN ('Brown','Patty');

/*************************************************************************
STEP 3: 
**************************************************************************/

-- turning off spooling
SPOOL OFF