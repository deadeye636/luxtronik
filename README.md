# luxtronik
This litte tool written in [b4j](https://www.b4x.com/b4j.html) runs as a service. 
It reads and controls heat pumps, based on Luxtronik 2.x
The values are written to an mysql database. Splittet into known and unkown calcs/parameters.

Use at your own risk! It was testet with an heat pump LWCV 82r1/3.
For writing parameters to the heatpump set luxParamSet to Y.

## Getting started
- Download an install jre 1.8 or greater
- Download an install mysql or mariadb
- Import the skeleton.sql and data.sql to the database server
- Edit the config.properties
- Start the luxtronik.jar with
java -jar luxtronik.jar

## Tables
| name             | Description |
| ---------------- | ----------- |
| calcs            | defintion for calculations (3004)            |
| calcvals         | last read values from the headpump           |
| calcvals_history | history for calculations with history flag Y |
| calcvals_unkown  | unkown calculations values.                  |
| errorlog         | history of errors                            |
| params           | definition for parameters (3003)             |
| paramset         | sets a parameter at a specific time          |
| paramvals        | last read parameters                         |
| paramvals_unkown | unkown parameter values                      |
| switchoff        | history of the switchoffs                    |
| valueformat      | value formats definition                     |
| valuemap         | value map                                    |

## Configuration
| Option           | Description                        | default                 |
| ---------------- | ---------------------------------- | ----------------------- |
| DriverClass      | DriverClass to the database        | org.mariadb.jdbc.Driver |
| JdbcUrl          | URL to the database.               | jdbc:mariadb://127.0.0.1:3306/luxtronik |
| Username         | database user                      ||
| Password         | database password                  ||
| luxHost          | ip/dns from luxtronik host         ||
| luxPort          | luxtronik port                     |8888 or 8889 |
| luxTimeout       | connection timeout                 | 3 |
| luxPassword      | WebSocks Password (not in use)     | 999999 |
| SyncInterval     | interval for reading the values    | 60 |
| ParamsInterval   | reload interval for the parameters | 600 |
| LogDir           | log directory                      ||
| LogFile          | filename                           ||
| LogFiles         | number of logfile                  | 5 |
| LogSize          | max. logfile size                  | 1024 |
| LogRotate        | enable or disable logrotate (Y/N)  | Y |
| LogConsole       | log messages to console            | N |
| LogLevel         | loglevel (INFO,WARN,ERROR)         | ERROR |

## Planned Features
- Support for a time based database
- MQTT
- Luxtronik WebSocks