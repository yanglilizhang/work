## [0.4.2] - 2020/2/28

* 细化响应错误类型，增加响应数据解析错误和任务执行错误(应用业务逻辑失败)

## [0.4.1] - 2019/11/18

* 设置默认发送超时30秒，默认连接超时为10秒

## [0.4.0] - 2019/11/1

* 大幅度修改work的核心生命周期函数的参数，`WorkData`作为生命周期核心的传递句柄
* 将`Options`和`Response`存入`WorkData`传递
* 在`WorkData`中增加`extra`字段
* 在`Response`中增加请求错误类型`errorType`和接收数据总量`receiveByteCount`

## [0.3.3] - 2019/10/21

* 修复数据解析失败任然返回请求成功的bug

## [0.3.2] - 2019/10/18

* 修复上传文件的bug

## [0.3.1] - 2019/10/10

* 增加`ResponseType.bytes`支持，以接收原始字节流的响应数据

## [0.3.0] - 2019/10/9

* 更新dio库到3.0.0版本

## [0.2.9] - 2019/9/18

* 移除`sendTimeout`默认值

## [0.2.8] - 2019/9/18

* 修复headers赋值方式导致的bug

## [0.2.7] - 2019/9/18

* 修复headers赋值顺序导致的参数覆盖bug
* `Options`增加`sendTimeout`属性

## [0.2.6] - 2019/9/18

* 调整实现细节以支持dio v2.2.1 的api变更，`Options.contentType`替换为String类型

## [0.2.5] - 2019/9/2

* 将work中的生命周期函数返回值变更为`FutureOr`以支持异步操作
* 将`onStartWork`和`onStopWork`生命周期变为私有函数，禁止重写
* 替换部分`Null`泛型为`void`

## [0.2.4] - 2019/6/14

* 修复get请求参数转换错误

## [0.2.3] - 2019/5/31

* 将底层请求参数类型改为`dynamic`类型以便支持更加多请求参数格式
  默认继续以`Map`为主要参数类型集合，如需使用其他数据结构，请实现`onPostFillParams`方法

## [0.2.2] - 2019/2/14

* 修复dio 2.0.4 接口变化导致的bug

## [0.2.1] - 2019/2/1

* 修复dio 2.0.0 接口变化导致的bug

## [0.2.0] - 2019/2/1

* 修复dio 2.0.0 接口变化导致的bug

## [0.1.9] - 2019/2/1

* 升级dio到2.0.0

## [0.1.8] - 2019/1/31

* 回滚meta库依赖到1.1.6

## [0.1.7] - 2019/1/30

* 升级dio到1.0.14，增加上传/发送进度监听支持

## [0.1.6] - 2018/11/12

* 延长请求超时时间

## [0.1.5] - 2018/11/7

* 修改log输出位置

## [0.1.4] - 2018/11/7

* 增加请求参数忽略null值的处理

## [0.1.3] - 2018/10/18

* 修复`SimpleWork`中`onExtractResult`，`onDefaultResult`丢失`data`参数的问题

## [0.1.2] - 2018/10/8

* 增加输出日志的tag

## [0.1.1] - 2018/9/28

* 增加上传请求对`File`类型的支持

## [0.1.0] - 2018/9/26

* 首次完成提交
