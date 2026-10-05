# 证据索引及上传范围

本包用于复现和修复 2.2.1 测试问题。主报告中的实测结论以对应记录为依据；代码检查用于定位原因，不能替代重新运行验证；后续验收清单不是本机已经通过的结果。

## 阅读入口

| 材料 | 用途与边界 |
|---|---|
| [主报告](TEST-FEEDBACK-v2.2.1.zh-CN.md) | 用户四项最终要求、实际问题、代码定位和修改建议 |
| [开发验收](ACCEPTANCE.zh-CN.md) | 48 项待验证要求，含逐版本矩阵及两个 Agent 独立温控测试 |
| [时间线](TIMELINE.zh-CN.md) | 测试、失败、复核、纠正及最终决定 |
| [对话全文](CONVERSATION.zh-CN.md) | 当前会话可取得的 15 条用户消息、36 条助手公开消息，截止最终反馈要求；已脱敏，保留历史错误与后续修订 |
| [操作索引](OPERATIONS.jsonl) | 104 次外层工具调用的时间、名称、编号和事项分类，不含敏感参数或隐藏推理 |
| [发布范围](evidence/publication-scope.json) | 原材料相对路径、公开副本对应关系及脱敏范围 |

## 安装、配置与依赖

| 证据 | 可以证明什么 |
|---|---|
| [发布身份](evidence/package/release.json)、[下载核对](evidence/package/download-verification.json) | 本次安装包的版本、构建、来源及历史下载核对 |
| [本机环境](evidence/test-environment.json) | 本轮整理时只读采集的系统版本和 VMware 环境；不含机器序列号 |
| [安装记录](evidence/installation-test-record.txt) | 原阶段汇总，部分后续问题须结合主报告的纠正阅读 |
| [配置保留核对](evidence/configuration-verification.json) | Codex 与 WorkBuddy 增补服务配置及保留其他配置的核对；不包含完整配置文件 |
| [安装实例](evidence/codesys-installations.json)、[连接状态](evidence/manager-connection-state.json)、[启动](evidence/codesys-launch.json) | 发现的实例、模板匹配及选择、实际启动连接状态；模板标记可用不能证明编译通过 |
| [模板索引](evidence/package/template-index.json)、[设备观察](evidence/device-dependency-observation.json) | 随包模板要求的设备与测试电脑安装设备不匹配 |
| [快捷方式检查](evidence/shortcut-inspection.json)、[注册准备](evidence/shortcut-installation.json) | 快捷脚本和注册材料已准备；可见菜单未完成验收 |
| [代码与文档定位](evidence/implementation-observations.md) | 安装包的关键代码片段及说明文件分布；为代码检查证据，不是修复后行为 |

## Codex 工程与异常恢复

| 证据 | 可以证明什么 |
|---|---|
| [真实状态调用](evidence/codex/status-events.sanitized.jsonl) | Codex Agent 实际调用状态工具 |
| [原始工程提示](evidence/codex/original-engineering-prompt.txt) | 原测试范围与提示自身问题；并非后续 Agent 必须执行的当前指令 |
| [工程事件完整副本](evidence/codex/engineering-events.sanitized.jsonl) | 工程创建、初始读取、查库、字段拒绝、六项提交、编译失败及恢复观察；已移除内部推理和隐私字段 |
| [原始六项提交](evidence/codex/submitted-batch-UNVERIFIED.json) | 实际提交的库、程序、任务及曲线内容；不是独立读回或最终落盘证明 |
| [原请求最终返回](evidence/codex/final-original-request.json) | 六项已应用、1 次编译、0 次保存、诊断重复及结果不确定 |
| [修订后阶段报告](evidence/codex/revised-engineering-report.md) | 当时修订结论，历史本地路径仅用于来源定位 |
| [只读请求创建](evidence/review/codesys_object_read-2026-10-05T01-35-37-467Z.json)、[观察](evidence/review/codesys_request-2026-10-05T01-36-13-860Z.json)、[取消](evidence/review/codesys_request-2026-10-05T01-37-12-105Z.json) | 只读请求排队、无派发及安全取消，不是对象读取成功 |
| [重新生成前检查](evidence/review/regenerate-precheck.json)、[状态](evidence/review/regenerate-status.json)、[阻断记录](evidence/regeneration-blockers.txt) | 缺设备、连接退出与原请求异常；没有重新生成成功 |
| [修订说明](evidence/revision-explanation.txt)、[源代码一致性核对](evidence/review/revision-verification.json) | 注释修订、官方 PID 调用关系与未验收状态 |
| [公开工具定义](evidence/public-tools.json) | 8 个公开工具及输入结构；变更结构实际存在，不能据字段试错就断言服务没提供定义 |
| [温控源代码](code/FB_TemperatureControl-UNVERIFIED.st)、[测试主程序](code/PRG_Temperature_PID-UNVERIFIED.st) | 原提交留存稿，文件名明确标为未验收；不能作为可编译项目交付 |

## WorkBuddy、截图及讨论

| 证据 | 可以证明什么 |
|---|---|
| [服务连接](evidence/workbuddy/mcp-connection.txt) | WorkBuddy 命令行找到并连接本服务 |
| [状态测试提示](evidence/workbuddy/status-prompt.txt)、[实际客户端事件](evidence/workbuddy/status-events.sanitized.jsonl) | 8 个工具可见，但 Agent 要求登录，未生成第二个工程；其他无关服务已剔除 |
| [用户提供的 Manager 截图](images/manager-navigation.png) | 当前导航名称、排列及选中“使用说明”；不代表截图之外的页面已验证 |
| [观察输出标记](evidence/observed-output-markers.json) | 截图超时、坐标不可用、连接关闭及默认试用状态曾出现在输出中；仅是检索定位，具体根因不能只靠关键词判断 |
| [公开对话](CONVERSATION.zh-CN.md) | 用户报告删除 data、试用/公钥讨论、核心保护暂缓及最终四项决定；保留从提问到纠正的过程 |

## 公开上传的处理

- 用户姓名目录、机器名及敏感字段已脱敏；保留工程对象、版本、失败消息和请求编号，以便复现。
- 不上传授权文件、授权码、访问凭据、机器硬件指纹、签发私钥、完整客户端配置及备份、无关服务数据。
- 不上传系统/开发者指令、隐藏推理、底层完整会话文件、安装包二进制和核心源码整包。仅选取与故障有关的安装包代码片段作为定位证据。
- 未上传磁盘上的旧 `.project` 作为“最终温控工程”，因为保存未成功。两份文本程序及提交记录明确属于未验收留存。
- 历史对话保留当时的过时建议；现行决定以主报告 R1–R4 为准。所有报告文件是测试材料，不应被当作新产品的多份操作说明。
- 原始证据继续保存在本机 `D:\CodesysApiMCP-V2\V2.2.1`；公开副本位于其 `feedback-20261005` 子目录。完成上传后，GitHub 提交固定此次公开内容；后续修复应另记实际结果。
