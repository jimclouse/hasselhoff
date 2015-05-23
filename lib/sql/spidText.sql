DECLARE @spid int = {{spid}};

SELECT  es.session_id as sessionId
        ,et.text as spidText
INTO #sysprocesses
FROM    sys.dm_exec_sessions es
    JOIN    sys.dm_exec_connections ec
        ON      es.session_id = ec.session_id
    CROSS APPLY     sys.dm_exec_sql_text(ec.most_recent_sql_handle) et
WHERE   es.session_id = @spid;

IF (SELECT COUNT(*) FROM #sysprocesses) = 0 
BEGIN
    SELECT @spid as sessionId, null as spidText;
END
ELSE
BEGIN
    SELECT * FROM #sysprocesses;
END;
