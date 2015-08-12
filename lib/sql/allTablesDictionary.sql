USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select	t.object_id as objectId
        ,s.name + '.' + t.name as tableName
		,cast(e.value as nvarchar(max)) as description
from	sys.tables t
    join        sys.schemas s
        on          t.schema_id = s.schema_id
	left join		sys.extended_properties e
		on			t.object_id = e.major_id
			and			e.name = 'MS_Description'
			and			e.minor_id = 0
where t.type = 'U'
order by 	s.name, t.name;