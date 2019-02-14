```txt
单模块配置
sonar.projectKey=com.cmos:crmpfcore         //必须sonar中的唯一
sonar.projectName=crmpfcore                 //项目名称
sonar.projectVersion=1.0                    //项目版本
sonar.sources=src                           //sonar扫描目录
sonar.sourceEncoding=UTF-8                  //编码
sonar.language=java                         //Sonar扫描的语言

多模块配置
sonar.projectKey=com.cmos:crmpfcore         //必须sonar中的唯一
sonar.projectName=crmpfcore                 //项目名称
sonar.projectVersion=1.0                    //项目版本
sonar.sources=src                           //sonar扫描目录
sonar.sourceEncoding=UTF-8                  //编码
sonar.language=java                         //Sonar扫描的语言
sonar.modules=Module1,Module2,Module3,…     //pom中全部模块名称
Module1.sonar.projectName=module 1          //sonar中每个模块名称
Module2.sonar.projectName=module 2
......
```
