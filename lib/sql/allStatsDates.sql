USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT  s.name AS schemaName
        ,t.name AS tableName
        ,i.name AS indexName
        ,STATS_DATE(i.id,i.indid) AS lastUpdateDate
        ,i.rowcnt AS indexCount
        ,i.rowmodctr AS numberChanges
        ,CAST((CAST(i.rowmodctr AS DECIMAL(28,8))/CAST(i.rowcnt AS DECIMAL(28,2)) * 100.0) AS DECIMAL(28,2)) AS pctRowsChanged
FROM    sys.sysindexes i
  JOIN    sys.tables t
    ON      t.object_id = i.id
  JOIN    sys.schemas s
    ON      s.schema_id = t.schema_id
WHERE   i.id > 100
  AND     i.indid > 0
  AND     i.rowcnt >= 500
ORDER BY pctRowsChanged desc, lastUpdateDate, schemaName, tableName, indexName