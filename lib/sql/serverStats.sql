SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT @@SERVERNAME AS SERVERNAME;
SELECT @@VERSION AS VERSION;
SELECT sqlserver_start_time FROM sys.dm_os_sys_info;
