USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

 declare @pages bigint          -- Working variable for size calc.
        ,@dbsize bigint
        ,@logsize bigint
        ,@reservedpages  bigint
        ,@usedpages  bigint

select @dbsize = sum(convert(bigint,case when status & 64 = 0 then size else 0 end))
       ,@logsize = sum(convert(bigint,case when status & 64 <> 0 then size else 0 end))
from dbo.sysfiles;

select  @reservedpages = sum(a.total_pages)
        ,@usedpages = sum(a.used_pages)
        ,@pages = sum(
            CASE
                -- XML-Index and FT-Index and semantic index internal tables are not considered "data", but is part of "index_size"
                When it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) Then 0
                When a.type <> 1 and p.index_id < 2 Then a.used_pages
                When p.index_id < 2 Then a.data_pages
                Else 0
            END
        )
from    sys.partitions p join sys.allocation_units a on p.partition_id = a.container_id
    left join sys.internal_tables it on p.object_id = it.object_id;

 select cast((cast(@dbsize as dec (15,2)) +  cast(@logsize as dec (15,2))) * 8192/1048576./1024. as dec(15,2)) as databaseSizeGb
        ,case when @dbsize >= @reservedpages then cast((cast(@dbsize as dec (15,2)) - cast(@reservedpages as dec (15,2))) * 8192/1048576./1024. as dec(15,2)) else 0 end as unallocatedSpaceGb
        ,cast(round(@reservedpages * 8192/1024./1024./1024.,2) as dec(15,2)) as reservedGb
        ,cast(round(@logsize * 8192/1048576./1024.,2) as dec(15,2)) as logSizeGb
        ,cast(round(@pages * 8192 /1024./1024./1024.,2) as dec(15,2)) as dataGb
        ,cast(round( (@usedpages - @pages) * 8192/1024./1024./1024.,2) as dec(15,2)) as indexSizeGb
        ,cast(round((@reservedpages - @usedpages) * 8192/1024./1024./1024.,2) as dec(15,2)) as unusedGb


select  fileId
        ,name as fileName
        ,cast(round(cast(size as bigint) * 8/1024./1024.,2) as dec(15,2)) as fileSizeGb
        ,case when status = 1048578 then 'Data' when status = 1048642 then 'Log' end as fileType
from    sysfiles;

