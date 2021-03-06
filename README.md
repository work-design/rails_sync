# RailsSync

* [English](./README.en.md)


## 适用场景
1. 应用之间同步数据；
2. 应用内数据同步；
2. 新老应用间的数据迁移；
2. 两个 `table` 字段名称可能不同；
3. 两个 `table` 基于唯一的id进行同步数据，id可能是主键，也可能不是；

## 注意
1. 如果同一个表，两边应用都对其同一个字段有内容修改，业务上会比较混乱，建议避免；
2. 由于是直接数据库层面同步数据，不容易在目标应用内直接触发业务逻辑，可在本应用内基于Audit触发业务逻辑；

## 特性
1. 绝对靠谱，不依赖binlog，基于主键（支持联合主键）对两个表的各个字段进行比较，找出字段值的变化，新增的记录，删除的记录；
2. 高性能，10万以内的计算毫秒级；
3. 兼容性强，可支持各个关系型数据库（依赖 linked DB, mysql FEDERATED引擎等）；
4. 安全，对数据的改变先记录而不应用改变，可基于记录人工决定是否应用该改变，或者revert相应的改动；
5. 实时性强，可以通过应用里的数据改变动作触发；
6. 可以同步多个来源的数据；

## 实现原理
1. 处理表；
 a. 对于不同节点，建立临时表，映射远程数据库节点中的对应表（只映射需要比较改变值的字段），在mysql中采用`FEDERATED`引擎；
2. 通过 inner_join 计算两张表不一样的字段；
3. 通过 left_join 找出左表多出的记录；
4. 通过 right_join 找出右表多出的记录；

## Remote Table 
* postgresql: [dblink](https://www.postgresql.org/docs/10/static/dblink.html)
* mysql: [FEDERATED](https://dev.mysql.com/doc/refman/5.7/en/federated-storage-engine.html)
* mariadb: [CONNECT](https://mariadb.com/kb/en/library/connect/)
