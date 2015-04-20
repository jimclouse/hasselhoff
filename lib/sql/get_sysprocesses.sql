SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
select  s.spid
        ,rtrim(ltrim(s.status)) as status
        ,rtrim(ltrim(s.cmd)) as cmd
        ,s.blocked
        ,s.last_batch as lastBatch
        ,rtrim(ltrim(d.name)) as databaseName
        ,rtrim(ltrim(s.hostname)) as hostname
        ,s.program_name as programName
        ,s.cpu
        ,s.physical_io as physicalIo
        ,s.memusage as memUsage
from    sysprocesses s 
    left join   sysdatabases d
        on          s.dbid = d.dbid
order by spid;