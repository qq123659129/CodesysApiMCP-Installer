# CODESYS API MCP 安装包下载

本仓库仅用于发布 Windows 安装包。产品开发源码保存在独立私有仓库，不在此仓库发布。

## V2.0.4

- 系统：Windows x64。
- [下载安装程序](https://github.com/qq123659129/CodesysApiMCP-Installer/releases/download/v2.0.4/Codesys-API-MCP-2.0.4-Windows-x64.exe)
- SHA-256：`FC46D619FE904FBA1A304F7869D6B60BFA22C983AFCA1F4AC9F5E9874B2B9DC8`

安装包包含 Manager、MCP 运行组件、私有运行环境及同版技能，并提供 Codex、Claude Code、TRAE 国内版、WorkBuddy 的接入提示词。CODESYS 软件、AI 客户端和本机产品授权须另行具备。

本版在 Windows x64、CODESYS SP19 Patch 6 的本机隔离环境完成安装、自检和公共 MCP 九工具握手。Patch 5、跨电脑以及 TRAE/WorkBuddy 的真实客户端连接仍待测试。

安装后从桌面或开始菜单启动 Manager，在“连接与配置”选择对应客户端。配置完成后，在客户端重载 MCP，用只读能力检索确认连接。配置写入成功不代表客户端已经连接。

安装程序包含产品必需的可执行运行脚本；不包含 TypeScript/C# 开发源码、测试夹具、开发依赖、用户许可证或凭据。
