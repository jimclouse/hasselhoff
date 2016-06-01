USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select  objectId
        ,sprocName
        ,max(lastExecutionTime) as lastExecutionTime
        ,sum(executionCount) as executionCount
        ,sum(totalWorkerTime) as totalWorkerTime
        ,sum(totalElapsedTime) as totalElapsedTime
        ,sum(totalLogicalReads) as totalLogicalReads
        ,sum(totalPhysicalReads) as totalPhysicalReads
        ,sum(totalLogicalWrites) as totalLogicalWrites
    from (
    select  o.object_id as objectId
            ,s.name + '.' + o.name as sprocName
            ,pc.last_execution_time as lastExecutionTime
            ,pc.execution_count as executionCount
            ,pc.total_worker_time as totalWorkerTime
            ,pc.total_elapsed_time as totalElapsedTime
            ,pc.total_logical_reads as totalLogicalReads
            ,pc.total_physical_reads as totalPhysicalReads
            ,pc.total_logical_writes as totalLogicalWrites
    from    sys.objects o
        join    sys.schemas s
            on      o.schema_id = s.schema_id
       left join   sys.dm_exec_procedure_stats pc
        on      pc.object_id = o.object_id
          and     pc.database_id = DB_ID()
    where   o.type = 'P'

    union

    select  su.objectId as objectId
            ,s.name + '.' + o.name as sprocName
            ,su.lastExecutionTime as lastExecutionTime
            ,null as executionCount
            ,null as totalWorkerTime
            ,null as totalElapsedTime
            ,null as totalLogicalReads
            ,null as totalPhysicalReads
            ,null as totalLogicalWrites
    from    SQL_PERFORMANCE..storedProcedureUsage su
        join    sys.objects o
            on      su.objectId = o.object_id
        join    sys.schemas s
            on      o.schema_id = s.schema_id
    where su.databaseId = db_id()
) T
group by T.objectId, sprocName
order by lastExecutionTime asc;
