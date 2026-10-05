# 温控 PID 测试工程验收报告

日期：2026-10-05（Asia/Singapore）；已按用户质疑修订责任说明与官方 PID 调用定位。

**结论：未通过，任务未完整完成。** 独立工程已按 Patch 5 精确模板创建；工具报告六项编辑已应用，但编译出现设备及依赖库错误，之后完整诊断读取失败。原请求持续处于“结果不确定”，修改后的工程没有成功保存，最终代码、任务、库和 Trace 读回尚未完成。

原工程测试由官方 Codex CLI 中的实际 Agent 经已配置的 codesys-v22 公开 MCP 执行，不是当前桌面对话热加载验证，也不表示在线曲线已经运行。原工程操作未使用 Computer Use、GUI、Python、内部脚本或直接 Broker；未手工生成或导入工程文件。本轮由当前对话通过标准 MCP 客户端读取同一服务状态、尝试对象读取并取消尚未执行的读取；没有再次启动 Agent，没有编辑或保存 CODESYS 工程。

## 本次修订：责任及依据

**检查遗漏和先前解释不准确由我负责，不能归因于 MCP 没有说明要求。** 安装说明 Environment-Setup.md 第 23 行明确要求设备描述、编译器和库在目标环境可用，并要求分别核对三者。执行前我确认了开发软件版本、模板选择和 Util 库，却没有核实模板所需设备是否在本机可用，也没有在写入业务代码前验证初始工程能否编译。

新建调用确实使用了当前已连接的 SP19 Patch 5，并选择 minimal-sp19-patch5。其要求的 Control Win V3 3.5.19.60 在本机设备目录中未找到；本机对应普通版和 x64 版设备目录均只有 3.5.19.50。编译实际报“系统没有安装设备”。这是本轮确认的环境阻断，不是选错开发软件版本，也不是漏用集中模板功能。

我先前将此笼统说成“模板版本错误、应修正模板”，结论过强。开发软件与设备版本数字不同本身不是错误；该模板已经登记其设备要求，是否采用其他设备组合必须另行验证。准确结论是：**本机不满足所选模板的设备依赖，而我漏掉了文档要求的检查。**

产品仍有独立的检查与诊断问题：模板可用检查只核对开发软件版本、启动配置、模板文件及摘要，没有在该检查中验证本机设备依赖；后续诊断读取异常使原请求停留在“结果不确定”。前者不能替代操作人员的环境核对，后者也不能通过改 PID 算法解决。

原执行提示还误写了 PID_FIXEDCYCLE；实际执行已查官方文档并改用正确名称 PID_FIXCYCLE，没有向 CODESYS 提交错误名称。历史提示和原始调用记录保留原样，不回写伪造历史。

依据：[环境说明](D:/CodesysApiMCP-V2/V2.2.1/installed/resources/manager/Environment-Setup.md:23)、[模板清单](D:/CodesysApiMCP-V2/V2.2.1/installed/resources/templates/index.json)、[模板检查实现](D:/CodesysApiMCP-V2/V2.2.1/installed/dist/platform/project-templates.js)。

## 官方 PID 功能块在哪里

原提交的算法使用官方 Util 3.5.19.0 中的固定周期 PID 功能块 PID_FIXCYCLE。它不是名称为 PID 的另一功能块；官方文档为快速固定周期任务推荐这一版本，CYCLE 参数单位为秒，本次为 0.01 秒。

调用关系：10ms 任务 → PRG_Temperature_PID → fbTemperature（温控封装）→ fbPID（官方 Util.PID_FIXCYCLE）。用户在测试主程序中看到的是温控封装调用，官方算法调用位于封装内部。

- 实例声明和完整调用：[FB_TemperatureControl.st](D:/CodesysApiMCP-V2/V2.2.1/projects/codex/unverified-source/FB_TemperatureControl.st)。声明为 `fbPID : Util.PID_FIXCYCLE;`，实现包含 `fbPID(...)`，同时传入目标、反馈、PID 参数、0–100 输出范围与 `CYCLE := rCycle_s`，其中 rCycle_s 为 0.01。
- 测试主程序：[PRG_Temperature_PID.st](D:/CodesysApiMCP-V2/V2.2.1/projects/codex/unverified-source/PRG_Temperature_PID.st)。调用 fbTemperature 并读取其输出百分比。
- 原始提交证据：[codex-submitted-batch-UNVERIFIED.json](D:/CodesysApiMCP-V2/V2.2.1/evidence/codex-submitted-batch-UNVERIFIED.json)。其中同时包含添加 Util 库的请求、实例声明及实际调用代码。

以上证明原提交文本包含官方库调用，不证明修改已经保存或运行。磁盘上的 .project 文件仍不能作为已交付温控程序；本轮仅补充代码留存稿的定位注释，未修改算法或冒充工程读回。

## 本轮只读复核结果

2026-10-05 09:35（Asia/Singapore），公开 MCP 状态返回：原 SP19 Patch 5 实例仍连接，当前为 TemperaturePID_Codex.project，工程有未保存修改，原编辑请求仍为“结果不确定”。随后批量请求读取库、两个程序对象、任务和曲线配置，两次观察均停留在排队，实际工程调用次数为 0。

已核对本版服务实现：存在结果不确定的已派发请求时，队列停止派发；只读工程请求也进入该队列。为避免留下一条稍后自动执行的请求，本轮已通过公开接口取消本轮尚未执行的读取，返回 CANCELLED，修改、编译、保存均为 0。没有取消或重放原编辑请求，也没有清除请求记录、修改服务代码或重启 CODESYS。

本轮证据位于 [revision-20261005](D:/CodesysApiMCP-V2/V2.2.1/evidence/revision-20261005)，原件备份位于 [review-20261005](D:/CodesysApiMCP-V2/V2.2.1/backups/review-20261005)。工程仍未验收通过；这次完成的是结果复核和说明修订。

## 已核实的信息

| 项目 | 实际证据 |
|---|---|
| IDE | CODESYS V3.5 SP19 Patch 5，版本 3.5.19.50；初始无打开工程 |
| 工程路径 | D:\CodesysApiMCP-V2\V2.2.1\projects\codex\TemperaturePID_Codex.project |
| 新建结果 | 工具确认创建成功、目标模板副本已生成；模板 minimal-sp19-patch5 |
| 模板登记要求 | 编译器 3.5.19.50；设备 CODESYS Control Win V3 3.5.19.60。这是模板要求，不代表设备在当前 IDE 中可用 |
| 新工程上下文 | projectEpoch 从 1 变为 2；应用路径 Device/Plc Logic/Application |
| 初始完整读回 | Library Manager、空 PLC_PRG、Task Configuration、MainTask；均返回完整内容及新 readRef |
| 初始任务 | MainTask，t#20ms，优先级 1，仅调用 PLC_PRG |
| 本机官方库 | 精确查询确认 Util / 3.5.19.0 / System；安装元数据默认命名空间为空，提交时明确指定 Util |
| 官方功能块 | 准确名称 PID_FIXCYCLE；不是 PID_FIXEDCYCLE。CYCLE 单位为秒，提交值 0.01 |
| 有效能力 | 代码、编译、保存可用；任务、库修改、离线 Trace 为限定支持；在线运行能力延期 |

接口依据：[Util 3.5.19.0 官方库文档](https://content.helpme-codesys.com/en/libs/Util/3.5.19.0/index.html)、[固定周期 PID 官方接口](https://content.helpme-codesys.com/en/libs/Util/3.5.19.0/Controller/PID_FIXCYCLE.html)、[PID 行为说明](https://content.helpme-codesys.com/en/libs/Util/3.5.19.0/Controller/PID.html)。库身份来自本机 MCP 查询；接口来自同版本官方文档，没有把库元数据查询误写为接口读回。

## 编辑及 Trace 验收状态

以下六项均由同一个实际编辑批次返回“已应用”（APPLIED），但没有取得最终独立完整读回，因此不能据此判定配置验收通过。

1. 在库管理器增加精确版本 Util 3.5.19.0，使用命名空间 Util。
2. 创建 FB_TemperatureControl：调用官方 Util.PID_FIXCYCLE；目标/反馈输入，输出 rOutput_pct；范围 0–100%，使能、复位、输入故障及溢出锁存，安全输出为 0。提交代码含关键中文说明；测试参数为比例 2、积分时间 20 秒、微分时间 0.5 秒。
3. 创建 PRG_Temperature_PID：包含 rTarget_C、rFeedback_C、rOutput_pct；一阶温度对象明确标注“仅测试模拟”，环境 20℃、时间常数 20 秒、步长 0.01 秒；没有声明实体 I/O 映射。
4. 将 MainTask 周期设置为 t#10ms，保留优先级 1。
5. 将任务调用列表替换为唯一 PRG_Temperature_PID，去掉原 PLC_PRG 调用；提交代码中温控实例和 PID 各仅调用一次。
6. 创建 Trace_Temperature_PID，完整提交采样和显示配置。

| Trace 项目 | 已提交配置 | 最终读回 |
|---|---|---|
| 采样任务 | 同应用 MainTask，时间单位 ms，每 1 个任务周期采样 | 未完成 |
| 三条采样变量 | PRG_Temperature_PID.rTarget_C；PRG_Temperature_PID.rFeedback_C；PRG_Temperature_PID.rOutput_pct；全部启用 | 未完成 |
| 温度图 | 目标、反馈同图，图及两条曲线可见，纵轴自动，说明“温度 / °C” | 未完成 |
| 输出图 | 输出百分比单图，图及曲线可见，纵轴固定 0–100，说明“输出 / %” | 未完成 |
| 曲线样式 | 三条均为直线连接，分别红、蓝、绿；两图显示网格及轴说明 | 未完成 |
| 启动与触发 | 不自动启动；记录条件为空；触发关闭 | 未完成 |
| 创建后再修改 | 无；未使用尚未读回的 Trace 默认值进行后续修改 | 不适用 |

## 编译、保存及阻断

实际编辑批次只请求一次编译，并要求编译成功后保存。工具计数：编译 1 次、保存 0 次、原生操作 34 次。未另行调用编译工具，未重放编辑批次。

编译已返回“系统没有安装设备。不能生成代码”（C0188），同时返回 3SLicense 和 CAA Device Diagnosis 加载失败、DED 和 IoConfig 类型缺失等错误。随后诊断读取因对象标识无效而失败。现有公开能力没有设备安装/替换能力；本次未更换设备、修改受保护系统库或猜测代码修复。

第一次不确定结果后，两次均只查询原请求。最后服务已空闲，但请求仍为 UNKNOWN，错误为 DIAGNOSTICS_UNREADABLE。返回诊断条目有重复累积：24 → 312 → 1848，去重为 22 条错误、2 条信息，未见警告条目。**这些是收到的诊断条目统计，不是稳定、完整的编译错误/警告总数；最终错误总数和警告总数均未能核实。**

上轮由我编写的执行提示将“不确定时只查询原请求”写得过严，进而没有尝试对象只读核对；这不是用户禁止读回，MCP 操作指南也没有要求把已发生效果当作已验收。本轮已补做只读请求，确认服务队列因原请求结果不确定而不再派发，随后撤销本轮排队读取。新建路径曾由 MCP 确认；磁盘上的模板副本不能当作包含最终温控修改的已保存工程。未关闭 IDE、未删除目标文件，保留已发生效果。

## 真实调用记录（技术附录）

| 工具 | 请求标识或参数 | 结果 |
|---|---|---|
| codesys_status | 空参数 | 读取连接、上下文、有效能力和编码规范；规范开关均关闭 |
| codesys_project_file | codex-temp-create-20261005-01；action=create | RUNNING 后用原请求查询一次，终态 PASS |
| codesys_project_query | codex-temp-structure-01 | 新工程结构完整返回 |
| codesys_library_query | codex-temp-util-installed-01；action=installed | 返回未筛选安装库首页；后改用 search 精确筛选，未把首页当完整清单 |
| codesys_object_read | codex-temp-read-baseline-01 | 四个初始对象完整读回，取得新 readRef |
| codesys_library_query | codex-temp-util-search-01；action=search，query=Util | 完整匹配清单含 Util 3.5.19.0 System |
| codesys_library_query | codex-temp-util-details-01 | pageBytes 不支持 details，字段校验拒绝，无派发 |
| codesys_library_query | codex-temp-util-details-02 | 移除不适用字段后，精确库身份查询成功 |
| codesys_project_apply | codex-temp-fields-01 至 codex-temp-fields-06 | 因当前客户端未展开变更项字段定义，通过公开工具诊断核对字段；全部在派发前拒绝，修改/编译/保存均为 0 |
| MCP 资源目录查询 | codesys-v22 的 resources/list、resources/templates/list | 均返回方法不存在；未用于操作 CODESYS |
| codesys_project_apply | codex-temp-build-01 | 六项编辑报告 APPLIED；一次编译；UNKNOWN / DIAGNOSTICS_UNREADABLE；保存 0 |
| codesys_request | codex-temp-build-01；action=status | 两次等待查询（一次 RUNNING，一次 UNKNOWN），再两次原请求恢复查询，仍 UNKNOWN；没有重放 |

最终原请求：`codex-temp-build-01`。
连接实例：`77ea9cb4949f4fdcaf87e08a0fb420b0`。
诊断读取异常：`对象GUID'ce58700a-63da-5e62-b344-974f3216c491'无效.`。

### 已返回的诊断（去重保留全部可读消息）

下表仅列原请求实际返回的全部不同消息，不能视作完整编译诊断已读取成功。

| 序号 | 级别 | 编号 | 对象 | 原始消息 |
|---|---|---|---|---|
| 1 | 信息 | — | — | ------ 开始编译应用程序 Device.Application ------- |
| 2 | 错误 | C0188 | — | 系统没有安装设备。不能生成代码。 |
| 3 | 信息 | — | — | 代码典型化... |
| 4 | 错误 | — | Device | 插入库3SLicense, 0.0.0.0 (3S - Smart Software Solutions GmbH) : 失败 |
| 5 | 错误 | — | Device | 插入库CAA Device Diagnosis, 3.5.0.0 (CAA Technical Workgroup) : 失败 |
| 6 | 错误 | C0077 | Device/Plc Logic/Application | 未知的类型: 'DED.CAADiagDeviceDefault' |
| 7 | 错误 | C0077 | Device/Plc Logic/Application | 未知的类型: 'DED.INode' |
| 8 | 错误 | C0077 | Device/Plc Logic/Application | 未知的类型: 'IoConfigTaskMap' |
| 9 | 错误 | C0032 | Device | 不能将类型 '未知的类型: 'ADR(DED.g_itfRootINodeInst)'' 转换为类型'POINTER TO BYTE' |
| 10 | 错误 | C0077 | Device/Plc Logic/Application | 未知的类型: 'DED.g_itfRootINodeInst' |
| 11 | 错误 | C0046 | Device | 没有定义标识符'DED'  |
| 12 | 错误 | C0077 | Device | 未知的类型: 'IoConfigParameter' |
| 13 | 错误 | C0229 | Device | 需要常数值替代'STRUCT(dwParameterId := DWORD#1879048211, dwValue := ADR(S6384a5fcDPS.p0), wType := WORD#16, wLen := WORD#648, dwFlags := DWORD#50)' |
| 14 | 错误 | C0046 | Device | 没有定义标识符'dwParameterId'  |
| 15 | 错误 | C0018 | Device | 'dwParameterId'是无效的赋值目标 |
| 16 | 错误 | C0046 | Device | 没有定义标识符'dwValue'  |
| 17 | 错误 | C0018 | Device | 'dwValue'是无效的赋值目标 |
| 18 | 错误 | C0046 | Device | 没有定义标识符'S6384a5fcDPS'  |
| 19 | 错误 | C0046 | Device | 没有定义标识符'wType'  |
| 20 | 错误 | C0018 | Device | 'wType'是无效的赋值目标 |
| 21 | 错误 | C0046 | Device | 没有定义标识符'wLen'  |
| 22 | 错误 | C0018 | Device | 'wLen'是无效的赋值目标 |
| 23 | 错误 | C0046 | Device | 没有定义标识符'dwFlags'  |
| 24 | 错误 | C0018 | Device | 'dwFlags'是无效的赋值目标 |

## 未完成与未测项

- 未取得库引用、10ms 任务与唯一调用、两个 POU 完整代码、Trace 三变量及可见图形关联的最终独立读回。
- 未取得稳定已完成且可读完整的编译诊断；未通过编译验收；温控修改未成功保存。
- 未下载 PLC、未启动在线运行、未采集曲线，未测试实际任务周期、模拟闭环响应、复位/故障运行行为或实体设备整定。
- 后续需先解决模板设备及依赖在该 IDE 中不可用的问题，并恢复原请求的明确结果；本报告不将代码文本、已应用标记或零计数单独算作通过。

