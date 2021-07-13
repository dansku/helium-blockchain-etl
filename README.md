# helius etl non-docker (wip)

* install https://github.com/helium/blockchain-etl
* postgres 12 + postgis
	* `sudo apt install postgis postgresql-12-postgis-3 postgis postgresql-12-postgis-3`
* create db table and users
	* `sudo -u postgres psql`
	* `CREATE USER etl WITH PASSWORD 'etl';`
	* `CREATE DATABASE etl;`
* change psql to use password
	* edit `vim /etc/postgresql/12/main/pg_hba.conf` to:
```
# "local" is for Unix domain socket connections only
local   all             all                                     peer

#to 
local   all             all                                     md5
```

### optional
* increase ulimit
	* `vim /etc/security/limits.conf` and change:
	
	```
	soft nofile 400000
	hard nofile 400000
	```

## Move psql data directory (in case of using external disk)
`/var/lib/postgresql/12/main`

or `SHOW data_director;`

* stop database: `sudo systemctl stop postgresql`

## Load DB Dump
`pg_restore -d etl -U etl -W -Fd folder/`



---

# helium etl server on docker (WIP)

## requirements
* server with docker
* ~500gb+ hard drive available for the database


## postgresql database setup

#### create the folder where the database files will reside
```
$ mkdir /root/pgdata
```

#### start the postgresql
make sure to change the informations such as user and password
```
docker run -d \
    --name pgsql \
    -e POSTGRES_USER=etl \
    -e POSTGRES_PASSWORD=etl123 \
    -e POSTGRES_DB=etl \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    --net=host \
    -v /root/pgdata:/var/lib/postgresql/data \
    postgis/postgis
```

## blockchain-etl setup
#### clone repository and build the docker image
```
git clone https://github.com/helium/blockchain-etl.git
cd blockchain-etl
docker build -t helium/etl .
```

#### run migrations
```
# run migrations
docker run --net=host -e DATABASE_URL=postgresql://etl:etl123@127.0.0.1:5432/etl helium/etl migrations reset
```

#### run the etl docker container
```
docker run -d --init \
  --name etl \
  --net=host \
  --restart=always \
  --mount type=bind,source=$HOME/etldata,target=/var/data \
	-e DATABASE_URL=postgresql://etl:etl123@127.0.0.1:5432/etl \
  helium/etl
```

#### check logs
```
tail -f /root/etldata/log/console.log
```

## blockchain-etl update

* Stop the docker container for the etl: `docker stop etl`
* Go to the `blockchain-etl` git repo folder and update the code with:  `git pull`
* Remove the old container: `docker rm etl`
* Rebuild the container: `docker build -t helium/etl .`
* Run migrations: ` docker run --net=host -e DATABASE_URL=postgresql://etl:etl123@127.0.0.1:5432/etl helium/etl migrations run`
* Restart the docker container:
```
docker run -d --init \
  --name etl \
  --net=host \
  --restart=always \
  --mount type=bind,source=$HOME/etldata,target=/var/data \
	-e DATABASE_URL=postgresql://etl:etl123@127.0.0.1:5432/etl \
  helium/etl
```


