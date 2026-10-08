# CODESYS API MCP 安装包下载

本仓库发布 Windows 安装包；开发源码保存在独立私有仓库。

## V2.2.2（当前版本）

2026-10-08 快捷入口同类故障修复版完整包：包含此前四项小优化，以及旧配置兼容、字段校验、缺失文件和可核验元数据恢复、重复项合并、失败恢复及明确的“备份并重建配置”操作。软件版本仍为 2.2.2。91 项辅助程序、7 项原有安全回归、26 项隐藏 Manager 流程、8 项封包运行检查和隔离安装/卸载通过；不代表其他电脑或真实 IDE 重新实测。准备后，命令在 CODESYS 下次正常启动时加载，再从“工具 → 自定义”添加。

- [下载完整安装包（约 154 MB，无需登录）](https://github.com/qq123659129/CodesysApiMCP-Installer/releases/download/v2.2.2/CodesysApiMCP-2.2.2-Windows-x64-Full-Recovery-20261008.zip)
- [版本说明和全部附件](https://github.com/qq123659129/CodesysApiMCP-Installer/releases/tag/v2.2.2)
- [独立使用说明](https://github.com/qq123659129/CodesysApiMCP-Installer/releases/download/v2.2.2/CodesysApiMCP-2.2.2-Manual-Recovery-20261008.html)
- [统一 Skill](https://github.com/qq123659129/CodesysApiMCP-Installer/releases/download/v2.2.2/CodesysApiMCP-2.2.2-Skill.zip)
- [SHA-256 校验清单](https://github.com/qq123659129/CodesysApiMCP-Installer/releases/download/v2.2.2/SHA256SUMS-Recovery-20261008.txt)

完整包 SHA-256：`2bbab6d453064b83a5b166ae96a990ed87c2b8c41b0d1f2a05af4f355309d451`

完整解压后运行 `Setup.exe`，选择空安装目录。包内提供运行环境、.NET Framework 4.8 离线前置组件、同版说明书与 Skill。安装后从桌面启动 Manager，在“CODESYS 设置”保存版本及实例，在“Agent 接入”生成客户端配置和入门说明；客户端重新加载 MCP 后，先读入门说明并调用 `codesys_status` 确认连接。

2.2.2 支持 Agent 通过 `codesys_project_connect` 连接并打开指定现有工程：采用 Manager 保存的版本与实例；已有相同工程且连接身份一致时复用；其他工程、Watcher 占用、版本不符或忙状态会明确阻断。已手动打开工程时，使用当前 Manager 提供的 Watcher 脚本路径运行脚本，再确认 PID 与工程。切换工程遵循说明书中的显式打开流程。

Manager 提供 Agent 入门说明预览、复制与导出，涵盖当前工具用法、错误处理和 Skill 启用方法。桌面有 Manager 与使用说明入口；托盘颜色和 PID 信息辅助识别连接。包内集成 SP18 Patch 6、SP19 Patch 5、SP19 Patch 6、SP20 Patch 6 四份初始模板。创建其他模板时，需同时匹配编译器与设备描述版本。

本版完成四版本限定连接边界、已有工程手动 Watcher 连接、客户端工程场景、真实 Codex 温控工程编译保存与 Trace 自动配置、本地软件仿真监控，以及完整包独立审计。验收范围详见发布说明；没有物理 PLC 或新干净虚拟机验收。配置文件写入成功不代表客户端当前会话已经加载。

CODESYS 软件、AI 客户端和产品授权须另行具备。公开包不含用户许可证、凭据、私钥、开发依赖或测试工程。

历史安装包已下架，当前公开下载版本为 2.2.2。
