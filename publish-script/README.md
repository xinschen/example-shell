### 使用shell脚本批量发布jar包文件
#### 文件解读
```
1、config.sh  定义各类参数，包含程序目录
2、funcs.sh  定义各类所需函数
3、run_project_template.tpl  jar启动脚本模板，需注意PROJECT_HOME变量需同config.sh的ROOT_PATH的变量值一致
4、generate_run_script.sh   统一生成程序启动脚本
5、pulishALL.sh  jar包发布脚本
```

#### 配置步骤
* 1、修改config.sh定义各类变量
* 2、执行脚本 pulishALL.sh xxxx-xxx-xx   xxxx-xxx-xx.jar

#### Tips
* 1、相关文件建议放到内网的资源站点