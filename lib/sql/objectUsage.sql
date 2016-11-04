USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select  s.name + '.' + o.name as objectName
        ,case when o.type = 'FN' then 'Function (Scalar)'
            when o.type = 'TF' then 'Function (Table-Valued)' 
            when o.type = 'V' then 'View'
            when o.type = 'TR' then 'Trigger'
            else o.type_desc
            end as objectType
        ,u.lastKnownCacheTime as lastExecutionTime
from sys.objects o
    join    sys.schemas s
            on      o.schema_id = s.schema_id
    left join   SQL_PERFORMANCE..objectUsage u
        on      o.object_id = u.objectId
            and     u.databaseId = db_id()
where   o.type in ('V', 'FN', 'TF', 'TR')
order by o.type, u.lastKnownCacheTime desc, s.name, o.name;
