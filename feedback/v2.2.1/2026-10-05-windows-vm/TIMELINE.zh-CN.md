# 本次测试与讨论时间线

日期为 2026-10-05。下表统一使用 UTC+08:00；原始 JSON/JSONL 中以 `Z` 结尾的时间为 UTC，比表中早 8 小时。时间表示记录出现时刻，不等于每项操作持续时间。

| 时间 | 操作或讨论 | 实际结果与证据 |
|---|---|---|
| 09:01 | 用户要求安装 2.2.1、接入两个 Agent、添加 CODESYS 快捷方式并各建温控示例 | 全部生成文件要求集中在 `D:\CodesysApiMCP-V2\V2.2.1`；见[对话起始](CONVERSATION.zh-CN.md) |
| 09:03–09:07 | 下载核对、读取安装说明、安装并合并客户端配置 | 包身份核对、保留其他服务配置；见[下载记录](evidence/package/download-verification.json)、[配置核对](evidence/configuration-verification.json) |
| 09:08 | Codex 真实 Agent 状态调用 | 工具可调用，CODESYS 当时尚未连接；不能视为工程通过；见[状态调用](evidence/codex/status-events.sanitized.jsonl) |
| 09:08–09:10 | 探测本机 CODESYS，纠正保存配置中的失效路径，选择 SP19 Patch 5；准备脚本快捷方式并启动 | 真实安装为 3.5.19.50；脚本注册文件已生成，但可见菜单未验收；见[安装实例](evidence/codesys-installations.json)、[启动记录](evidence/codesys-launch.json)、[快捷方式准备](evidence/shortcut-installation.json) |
| 09:11–09:12 | 等待连接脚本进入工作状态 | 实际连接成功，起初没有打开工程；界面自动化另有截图/输入失败，未用于替代工程操作；见[连接状态](evidence/manager-connection-state.json)、[输出标记](evidence/observed-output-markers.json) |
| 09:14 | 发出 Codex 工程测试提示，通过正式工具新建项目 | 使用 SP19 Patch 5 对应模板；创建时未编译；见[原始提示](evidence/codex/original-engineering-prompt.txt)、[工程调用全过程](evidence/codex/engineering-events.sanitized.jsonl) |
| 09:14–09:21 | 查找官方库、读取初始对象，提交六项变更并编译 | 使用官方 `Util.PID_FIXCYCLE`；六项返回已应用，编译 1 次、保存 0 次；缺设备并出现诊断读取失败，原请求结果不确定；见[原始提交](evidence/codex/submitted-batch-UNVERIFIED.json)、[原请求最终记录](evidence/codex/final-original-request.json) |
| 09:17 | WorkBuddy 接入和真实 Agent 尝试 | 服务连接及 8 个工具可见，但命令行 Agent 提示登录，未调用工程工具；见[服务记录](evidence/workbuddy/mcp-connection.txt)、[Agent 事件](evidence/workbuddy/status-events.sanitized.jsonl) |
| 09:21–09:25 | 留存未验收源代码并检查模板设备依赖 | 模板要求设备 3.5.19.60，本机仅见 3.5.19.50；磁盘工程不是已保存的最终温控工程；见[设备观察](evidence/device-dependency-observation.json)、[修订核对](evidence/review/revision-verification.json) |
| 09:25 后 | 用户追问为什么未用对应模板、是否属于执行遗漏、是否调用官方 PID | 后续明确：实际使用了对应模板，但遗漏设备依赖与基础编译检查；官方功能块在封装内部调用，说明不清。原结论及纠正均保留在[对话全文](CONVERSATION.zh-CN.md) |
| 09:35–09:37 | 尝试通过公开工具补做只读核对 | 请求始终排队、派发为 0，取消该只读请求成功；没有重放或取消原编辑；见[只读返回](evidence/review/codesys_object_read-2026-10-05T01-35-37-467Z.json)、[继续观察](evidence/review/codesys_request-2026-10-05T01-36-13-860Z.json)、[取消结果](evidence/review/codesys_request-2026-10-05T01-37-12-105Z.json) |
| 09:39–09:40 | 修订结果说明与代码注释 | 非注释代码与原提交一致，未宣称重新编译通过；见[修订说明](evidence/revision-explanation.txt)、[一致性核对](evidence/review/revision-verification.json) |
| 09:42–09:45 | 响应重新生成要求，做前置检查 | CODESYS 已退出、原请求仍未明确结束，观察收到连接关闭；未发起新的工程修改；见[状态](evidence/review/regenerate-status.json)、[阻断记录](evidence/regeneration-blockers.txt) |
| 09:59–10:14 附近 | 用户报告清空 Manager 数据目录，讨论试用记录、公钥及试用绕过风险 | 实际状态查询仍显示默认 30 天；代码检查发现缺失记录可重建试用的路径。未实际删除授权记录做绕过实验；见[对话](CONVERSATION.zh-CN.md)、[授权输出标记](evidence/observed-output-markers.json)、[代码定位](evidence/implementation-observations.md) |
| 随后至 11:02 | 讨论安装包可读性，用户决定暂不处理核心防读取 | 历史讨论保留，但不作为本轮修复项；最终用户明确四项要求和统一说明顺序 |
| 11:02:15 | 用户给出最终反馈要求及 Manager 截图 | 本公开对话记录截止于此，之后的报告整理和上传另由提交记录说明；见[截图](images/manager-navigation.png) |

## 应保留的纠正

1. “有对应模板”不等于目标电脑具备全部设备和库；问题不能仅归纳为编译器版本不对。
2. 原工程提示中的官方功能块名字写错，执行时查证并改为固定周期功能块。提交存在官方调用，但没有完整工程验收。
3. 初始报告对只读核对受限的归因不准确；这是执行安排问题，不应归咎用户。
4. 查询导致重复消息增加不是新的独立编译次数；后续只读排队不能写成读取成功。
5. WorkBuddy 工具发现不等于完成 Agent 调用，命令行登录错误也不能直接说明桌面登录状态。
6. 删除 Manager 数据不是已验证恢复方案；取消试用是用户最后决定，之前的签名试用建议不再实施。

完整用户可见文字见[对话全文](CONVERSATION.zh-CN.md)，104 次外层工具调用的时间及名称见[操作索引](OPERATIONS.jsonl)。工具索引只用于定位，不冒充完整底层会话日志；工程客户端的原始调用与返回另有脱敏记录。
