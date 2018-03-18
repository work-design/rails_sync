# TheSync


## 原理
1. 建立临时表，映射远程数据库节点中的对应表，在mysql中采用`FEDERATED`引擎；
2. 通过 inner_join 计算两张表不一样的字段；
3. 通过 left_join 找出左表多出的字段；
4. 通过 right_join 找出右表多出的字段； 