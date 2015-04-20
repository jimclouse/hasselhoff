USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select      t.object_id as objectId
            ,s.name + '.' + t.name as tableName
from        sys.tables t
    join        sys.schemas s
        on          t.schema_id = s.schema_id
where       t.type = 'U'
order by    s.name, t.name;