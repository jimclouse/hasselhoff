USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

create table #usage (name sysname, rows int, reserved varchar(64), data varchar(64), indexSize varchar(64), unused varchar(64))

exec sp_msforeachtable 'insert into #usage exec sp_spaceused ''?'' '

update #usage set reserved = LTRIM(RTRIM(REPLACE(reserved,'KB','')))
update #usage set data = LTRIM(RTRIM(REPLACE(data,'KB','')))
update #usage set indexSize = LTRIM(RTRIM(REPLACE(indexSize,'KB','')))
update #usage set unused = LTRIM(RTRIM(REPLACE(unused,'KB','')))

alter table #usage alter column reserved int
alter table #usage alter column data int
alter table #usage alter column indexSize int
alter table #usage alter column unused int

select  name
    ,rows
    ,reserved/1024.0 as reserved
    ,data/1024.0 as data
    ,indexSize/1024.0 as indexSize
    ,unused as unused
from #usage order by reserved desc;

drop table #usage