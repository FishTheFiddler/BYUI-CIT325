/********************************************************
*  Name:           base_t.sql
*  Author:         Wes Peterson
*  Date:           11 Dec 2021
*  Purpose:        Complete 325 Final lab.
********************************************************/
-- @/home/student/Data/cit325/lib/cleanup_oracle.sql
-- @/home/student/Data/cit325/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open log file.
SPOOL dwarf_t.txt

-- ... insert your solution here ...
/****************************************************************
* DWARF HEADER
*****************************************************************/
CREATE OR REPLACE
  TYPE dwarf_t UNDER base_t
        ( /*oid   NUMBER
        , oname VARCHAR2(30)*/
          name  VARCHAR2(30)
        , genus VARCHAR2(30)
        , CONSTRUCTOR FUNCTION dwarf_t
            ( /*oid   NUMBER
            , oname VARCHAR2*/
              name  VARCHAR2
            , genus VARCHAR2 DEFAULT 'Dwarves' ) RETURN SELF AS RESULT
        , OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2
        , MEMBER FUNCTION get_genus RETURN VARCHAR2
        , MEMBER PROCEDURE set_genus (genus VARCHAR2)
        , OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 )
        INSTANTIABLE NOT FINAL;
/

-- Describe type object
DESC dwarf_t

/****************************************************************
* Body Code
*****************************************************************/
CREATE OR REPLACE TYPE BODY dwarf_t IS
  /* Implement a default constructor. */  
  CONSTRUCTOR FUNCTION dwarf_t
        ( name       VARCHAR2
        , genus      VARCHAR2 DEFAULT 'Dwarves' ) RETURN SELF AS RESULT IS
  BEGIN
    self.oid := tolkien_s.CURRVAL-1000;
    self.oname := 'Dwarf';
    self.name := name;
    self.genus := genus;
    RETURN;
  END dwarf_t;
 
  /* Override the get_name function. */
  OVERRIDING MEMBER FUNCTION get_name RETURN VARCHAR2 IS
  BEGIN
    RETURN self.name;
  END get_name;

  /* Implement a get_genus function. */
  MEMBER FUNCTION get_genus RETURN VARCHAR2 IS
  BEGIN
    RETURN self.genus;
  END get_genus;

  /* Implement a set_genus procedure. */
  MEMBER PROCEDURE set_genus (genus VARCHAR2) IS
  BEGIN
    self.genus := genus;
  END set_genus;
  
  /* Implement an overriding to_string function with generalized invocation. */
  OVERRIDING MEMBER FUNCTION to_string RETURN VARCHAR2 IS
  BEGIN
    RETURN (self AS base_t).to_string||'['||self.name||']['||self.genus||']';
  END to_string;
END;
/

SHOW ERRORS

QUIT;

-- Close log file.
SPOOL OFF
