USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

with cte_indexCols as (
    select  object_id as id, index_id as indid, name,
            (   select case keyno when 0 then NULL else colid end as [data()]
                from sys.sysindexkeys as k
                where k.id = i.object_id
                    and     k.indid = i.index_id
                order by keyno, colid
                for xml path('')
            ) as cols,
            (   select case keyno when 0 then colid else NULL end as [data()]
                from sys.sysindexkeys as k
                where k.id = i.object_id
                    and k.indid = i.index_id
                order by colid
                for xml path('')
            ) as inc
    from sys.indexes as i
)
select  object_schema_name(c1.id) AS schemaName
        ,object_name(c1.id) As tableName
        ,c1.name as indexName
        ,c2.name as duplicateIndexName
		,spaceUsage.indexSizeMb
		,spaceUsageDuplicate.indexSizeMb as duplicateIndexSizeMb
from    cte_indexCols as c1
    join    cte_indexCols as c2
        on      c1.id = c2.id
            and     c1.indid < c2.indid
            and     c1.cols = c2.cols
            and     c1.inc = c2.inc
OUTER APPLY(
select
    ROUND(8 * SUM(allocation_units.used_pages) / 1024.0, 2) AS [indexSizeMb]
from
    sys.partitions as partitions
    left join sys.allocation_units as allocation_units on allocation_units.container_id = partitions.partition_id
where
    partitions.OBJECT_ID = c1.id
    and partitions.index_id = c1.indid
) as spaceUsage
OUTER APPLY(
select
    ROUND(8 * SUM(allocation_units.used_pages) / 1024.0, 2) AS [indexSizeMb]
from
    sys.partitions as partitions
    left join sys.allocation_units as allocation_units on allocation_units.container_id = partitions.partition_id
where
    partitions.OBJECT_ID = c2.id
    and partitions.index_id = c2.indid
) as spaceUsageDuplicate
order by spaceUsage.[indexSizeMb] desc