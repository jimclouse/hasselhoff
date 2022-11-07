# Data Hasselhoff
While David watches over the beaches of Malibu, Data Hasselhoff watches over your databases


## What Is Hasselhoff?
Hasselhoff is meant to be a web console for detailed SQL Server tuning. Leveraging SQL Server distributed management views (DMVs), it will provide you with information such as under-used indexes, index fragmentation, and more!


## Installation
npm install

You'll also need to create a local environment variables file (etc/environment) that looks like the below template

```
export NODE_ENV=development
export PORT=9000

export CONNECTIONS="CONN1,CONN2"
export CONN1="{\"name\":\"CONN1\",\"config\":{\"server\":\"server\",\"port\":\"port\",\"user\":\"user\",\"password\":\"password\"}}"
export CONN2="{\"name\":\"CONN2\",\"config\":{\"server\":\"server\",\"port\":\"port\",\"user\":\"user\",\"password\":\"password\"}}"
```

## TODO
* one
