USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- get direct object
select 	o.object_id as objectId
		,s.name as schemaName
		,o.name as tableName
		,cast(e.value as nvarchar(max)) as description
from	sys.objects o
	join        sys.schemas s
        on          o.schema_id = s.schema_id
	left join 	sys.extended_properties e
		on 			o.object_id = e.major_id
			and 		e.name = 'MS_Description'
			and 		e.minor_id = 0
where  	o.type = 'U'
	and o.object_id = {{objectId}};


-- get columns
select 	o.object_id as objectId
		,c.column_id as columnId
		,s.name as schemaName
		,o.name as tableName
		,c.name as columnName
		,cast(e.value as nvarchar(max)) as description
from	sys.objects o
	join        sys.schemas s
        on          o.schema_id = s.schema_id
    join	sys.columns c
		on		o.object_id = c.object_id
	left join sys.extended_properties e
		on 		o.object_id = e.major_id
			and 	e.name = 'MS_Description'
			and		e.minor_id = c.column_id
where 	o.type = 'U'
	and 	o.object_id = {{objectId}};
