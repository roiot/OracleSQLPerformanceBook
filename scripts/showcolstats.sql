--
-- show all column stats for columns in the specified table
-- requires the function KEV_RAW_TO_STRING
-- very usefull for looking at column recorded HIGH/LOW
--
-- parameter 1 = owner
-- parameter 2 = table_name
--
-- usage is: @SHOWCOLSTATS <owner> <table_name>
--

/*
CREATE OR replace FUNCTION kev_raw_to_string (rawval RAW, TYPE VARCHAR2) RETURN VARCHAR2
IS
  cn  NUMBER;
  cv  VARCHAR2(32);
  cd  DATE;
  cnv NVARCHAR2(32);
  cr  ROWID;
  cc  CHAR(32);
BEGIN
    IF ( TYPE = 'NUMBER' ) THEN
      dbms_stats.Convert_raw_value(rawval, cn);
      RETURN '"'||cn||'"';
    ELSIF ( TYPE = 'VARCHAR2' ) THEN
      dbms_stats.Convert_raw_value(rawval, cv);
      RETURN '"'||cv||'"';
    ELSIF ( TYPE = 'DATE' ) THEN
      dbms_stats.Convert_raw_value(rawval, cd);
      RETURN '"'||to_char(cd,'dd-mon-rrrr.hh24:mi:ss')||'"';
    ELSIF ( TYPE = 'NVARCHAR2' ) THEN
      dbms_stats.Convert_raw_value(rawval, cnv);
      RETURN '"'||cnv||'"';
    ELSIF ( TYPE = 'ROWID' ) THEN
      dbms_stats.Convert_raw_value(rawval, cr);
      RETURN '"'||cnv||'"';
    ELSIF ( TYPE = 'CHAR' ) THEN
      dbms_stats.Convert_raw_value(rawval, cc);
      RETURN '"'||cc||'"';
    ELSE
      RETURN '"UNSUPPORTED DATA_TYPE"';
    END IF;
exception when others then
   return '---  conversion error  ---';
END;
/
*/
col low_value format a30
col high_value format a30
col last_analyzed format a22
--select table_name,column_name, num_distinct, num_nulls, num_buckets, sample_size,last_analyzed
select
  OWNER
, TABLE_NAME
, COLUMN_NAME
, NUM_DISTINCT
, NUM_NULLS
, NUM_BUCKETS
, SAMPLE_SIZE
, AVG_COL_LEN
, DENSITY
, TO_CHAR(LAST_ANALYZED,'dd-mon-rrrr.hh24:mi:ss') last_analyzed
, GLOBAL_STATS
, USER_STATS
, km21378.kev_raw_to_string (LOW_VALUE,(select data_type from dba_tab_columns b where b.owner = a.owner and b.table_name = a.table_name and b.column_name = a.column_name)) LOW_VALUE
, km21378.kev_raw_to_string (HIGH_VALUE,(select data_type from dba_tab_columns b where b.owner = a.owner and b.table_name = a.table_name and b.column_name = a.column_name)) HIGH_VALUE
from dba_tab_col_statistics a
where (owner,table_name) in
(
 (upper('&&1'),upper('&&2'))
)
--and (column_name = 'ROW_TERM_DATE$' or num_buckets > 1)
order by TABLE_NAME,COLUMN_NAME
/


