USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
-- supply a table name and get a list of column sparse-ness
-- helpful for determining if a column should be purged from a table
declare @tableName sysname = '{{tableName}}';
declare @schemaName sysname = '{{schemaName}}';
declare @fullTableName sysname = @schemaName + '.' + @tableName;

create table #columnSparsity (columnName sysname, columnType varchar(32), nulls int, nonNulls int);
declare @sql nvarchar(max);
declare @columnName sysname, @columnType varchar(32);
declare col_cursor cursor for

select  c.name
    ,case when ty.name in ('varchar', 'char', 'nvarchar', 'nchar') then
      ty.name + '(' + cast(c.max_length as varchar(12)) + ')'
    else
      ty.name
    end as type
from  sys.tables t
  join  sys.columns c
    on    t.object_id = c.object_id
  left join  sys.types ty
    on    c.user_type_id = ty.user_type_id
where t.object_id = object_id(@fullTableName)
  and   t.schema_id = schema_id(@schemaName)

open col_cursor
FETCH NEXT FROM col_cursor INTO @columnName, @columnType
declare @nulls int, @nonNulls int;

WHILE @@FETCH_STATUS = 0
begin

  set @sql = 'select @foo = COUNT(*) from ' + @schemaName + '.' + @tableName + ' where ' + @columnName + ' is null';
  exec sp_executesql @sql, N'@foo int output', @nulls OUTPUT
  set @sql = 'select @foo = COUNT(*) from ' + @schemaName + '.' + @tableName + ' where ' + @columnName + ' is not null';
  exec sp_executesql @sql, N'@foo int output', @nonNulls output

  -- select @nulls, @nonNulls
  insert into #columnSparsity (columnName, columnType, nulls, nonNulls)
  values (@columnName, @columnType, isnull(@nulls,0), isnull(@nonNulls,0))

  FETCH NEXT FROM col_cursor INTO @columnName, @columnType
END

CLOSE col_cursor
DEALLOCATE col_cursor

select * from (
  select  columnName
      ,columnType
          ,nulls
          ,nonNulls
          ,(nulls + nonNulls) as totalRows
          ,case when (nulls + nonNulls) > 0 then
            cast(nulls as decimal(18,2)) / (nulls + nonNulls)*100
            else 0
          end as pctEmpty
  from    #columnSparsity
) as T
order by pctEmpty desc;

drop table #columnSparsity