USE {{database}};

;with cte_sizes as (
    SELECT      table_id
                ,CONVERT(DECIMAL(12,2), SUM(data_size/1024.0/1024.0)) as indexSizeMb
    FROM        sys.fulltext_index_fragments
    GROUP BY    table_id
)
select  OBJECT_SCHEMA_NAME(i.object_id) + '.' + OBJECT_NAME(i.object_id) as tableName
        ,s.indexSizeMb
        ,c.name as catalogName
        ,c.is_default as isDefaultCatalog
        ,p.*
		, fg.name as filegroupName
from    sys.fulltext_indexes i
    join    sys.fulltext_catalogs c
        on      i.fulltext_catalog_id = c.fulltext_catalog_id
	join	sys.filegroups fg
		on		i.data_space_id = fg.data_space_id
    join    cte_sizes s
        on      i.object_id = s.table_id
    cross apply (
        select  DATEADD(ss, FULLTEXTCATALOGPROPERTY(fc.name,'PopulateCompletionAge'), '1/1/1990') AS lastPopulatedDate
                ,FULLTEXTCATALOGPROPERTY(fc.name,'indexSize') AS catalogSizeMb
                ,FULLTEXTCATALOGPROPERTY(fc.name,'UniqueKeyCount') AS uniqueKeyCount
                ,(SELECT CASE FULLTEXTCATALOGPROPERTY(fc.name,'PopulateStatus')
                    WHEN 0 THEN 'Idle'
                    WHEN 1 THEN 'Full Population In Progress'
                    WHEN 2 THEN 'Paused'
                    WHEN 3 THEN 'Throttled'
                    WHEN 4 THEN 'Recovering'
                    WHEN 5 THEN 'Shutdown'
                    WHEN 6 THEN 'Incremental Population In Progress'
                    WHEN 7 THEN 'Building Index'
                    WHEN 8 THEN 'Disk Full.  Paused'
                    WHEN 9 THEN 'Change Tracking' END) AS populationStatus
        from    sys.fulltext_catalogs fc
        where   fc.fulltext_catalog_id = c.fulltext_catalog_id
    ) as p
order by c.name, s.indexSizeMb desc;
