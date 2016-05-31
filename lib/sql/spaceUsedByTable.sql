USE {{database}};
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

select  t.name
        ,4000 as rows
        ,100 as reserved
        ,70 as data
        ,30 as indexes
        ,5 as unused
from sys.tables t
where type = 'u';