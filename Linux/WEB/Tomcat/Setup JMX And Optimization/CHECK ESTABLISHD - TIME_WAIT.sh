netstat -na | grep "ESTABLISHED" | grep {{%0%}}:{{%5%}} | wc -l

netstat -na | grep "TIME_WAIT" | grep {{%0%}}:{{%5%}} | wc -l
