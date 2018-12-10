#### 安装 GeoIP
```bash
wget http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
tar -zxvf GeoLite2-City.tar.gz
cp GeoLite2-City.mmdb /data/logstash/       #注:"/data/logstash"是Logstash的安装目录
```
#### Logstash-filter-geoip
```bash
if [message] !~ "^127\.|^192\.168\.|^172\.1[6-9]\.|^172\.2[0-9]\.|^172\.3[01]\.|^10\." {        #排除私网地址
    geoip {
        source => "message"     #设置解析IP地址的字段
        target => "geoip"       #将geoip数据保存到一个字段内
        database => "/usr/share/GeoIP/GeoLite2-City.mmdb"       #IP地址数据库
    }
}
```
#### Output
```txt
"geoip" => {
                      "ip" => "112.90.16.4",
           "country_code2" => "CN",
           "country_code3" => "CHN",
            "country_name" => "China",
          "continent_code" => "AS",
             "region_name" => "30",
               "city_name" => "Guangzhou",
                "latitude" => 23.11670000000001,
               "longitude" => 113.25,
                "timezone" => "Asia/Chongqing",
        "real_region_name" => "Guangdong",
                "location" => [
            [0] 113.25,
            [1] 23.11670000000001
        ]
    }
```
#### 指定GeoIP输出的字段
```bash
#GeoIP库数据较多，若不需要这么多内容则可通过fields选项指定自己所需。下例为全部可选内容
geoip {
　　fields => ["city_name", "continent_code", "country_code2", "country_code3", "country_name",
               "dma_code", "ip", "latitude", "longitude", "postal_code", "region_name", "timezone"]
}
```
