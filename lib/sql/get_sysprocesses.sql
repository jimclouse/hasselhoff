select spid, blocked, last_batch, hostname, program_name 
from sysprocesses 
order by spid;