USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select  o.object_id as objectId
        ,o.name as sprocName
        ,pc.last_execution_time as lastExecutionTime
        ,pc.execution_count as executionCount
        ,pc.total_worker_time as totalWorkerTime
        ,pc.total_elapsed_time as totalElapsedTime
        ,pc.total_logical_reads as totalLogicalReads
        ,pc.total_physical_reads as totalPhysicalReads
        ,pc.total_logical_writes as totalLogicalWrites
from    sys.objects o
   left join   sys.dm_exec_procedure_stats pc  
    on      pc.object_id = o.object_id
      and     pc.database_id = DB_ID()
where   o.type = 'P'
order by pc.last_execution_time asc;