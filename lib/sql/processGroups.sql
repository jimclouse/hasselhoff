SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
select  rtrim(ltrim(s.hostname)) as hostName
        ,s.program_name as programName
        ,count(*) as connectionCount
        ,max(s.last_batch) as latestBatchDate
        ,min(s.last_batch) as firstBatchDate
        ,sum(s.cpu) as totalCpu
        ,sum(s.physical_io) as totalPhysicalIo
        ,sum(s.memusage) as totalMemUsage
        ,sum(s.open_tran) as totalOpenTransactions
from    sysprocesses s 
    left join   sysdatabases d
        on          s.dbid = d.dbid
where   s.spid > 30
group by rtrim(ltrim(s.hostname)), s.program_name
order by count(*) desc, rtrim(ltrim(s.hostname)), s.program_name