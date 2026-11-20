# Focus Lens · Deadlock 复盘工具

聚焦你的队友。导入一场 Deadlock 录像，在战术地图上回看走位、团战和经济变化。录像在浏览器本地解析，无需安装软件。

**[打开 Focus Lens 网页版][web]** · 电脑端 Chrome / Edge · **[Windows 桌面版下载][releases]**

![Focus Lens 复盘界面：上方显示双方阵容和装备，左侧是战术地图，右侧是团战列表](.github/media/review.png)

*截图使用匿名工程，玩家昵称已替换。*

## 使用方法

1. 在 Deadlock 的对局历史里下载录像，找到本地 `.dem` 文件。已有 Focus Lens 桌面版导出的 `.dlreview` 工程也可以直接打开。
2. 打开[网页版][web]，点击「导入 .dem / .dlreview」，选择文件并等待解析。
3. 拖动时间轴、点击关键事件，或从「交火与团战」选择片段，跳到想复盘的时刻。

## 可以看什么

- **走位与资源**：缩放战术地图，观察双方移动路线和地图资源，也可以用画板标记站位。
- **团战与经济**：查看参战玩家的伤害、承伤和治疗，按经济差变化排序，优先复盘影响大的片段。
- **阵容与状态**：查看双方英雄、装备，以及录像中可读到的技能等级、冷却和充能。

在「笔记」中添加书签，点击右上角「导出工程」即可保存对局和笔记。下次可导入 `.dlreview` 继续复盘；分享时可在「质量」标签页选择「匿名工程」。

## 用 Windows 桌面版下载 Demo

网页版只打开本地文件。想按对局 ID 找录像，请到 [GitHub Releases][releases] 下载 Windows x64 的 `setup.exe`，或下载免安装 ZIP 并**完整解压**后运行 `Deadlock Review.exe`。GitHub 自动生成的 Source code 是网页版源码，不是桌面应用。

1. 在桌面版点「下载录像」，输入数字对局 ID，选「社区 API」→「下载并解析」。此方式无需 Steam 登录，先向社区服务查询地址，再从 Valve 录像服务器取文件。
2. 若社区没有收录地址，可切换「Steam 直连（实验）」。先退出正在运行的 Steam 游戏，用有 Deadlock 权限的账号在 Steam 手机端扫码确认，等到「已连接 Deadlock GC」再下载。应用不接收密码；断开或退出后需重新授权。
3. 下载完成后桌面版会在本机解压并打开对局。原始 `.dem` 在本机应用数据的 `matches/downloads` 中；也可以点「导出工程」，把 `.dlreview` 导入网页版继续复盘。

这两种方式都无法恢复 Valve 已删除的录像。刚结束的对局可以稍后重试；若已有本地录像，直接导入即可。Focus Lens 的网页服务器不代理下载，也不接收录像或 Steam 凭据。

## 游戏更新后，地图、图标或解析数据不对怎么办？

**玩家：** 在「质量」和对局标题核对解析器版本、游戏 Build。若只有新版本录像出现图标缺失、位置错位或解析失败，请在 [Issues][issues] 写明游戏 Build、出错功能、复现时刻和现象，无需公开录像或登录资料。保留原始 `.dem`，先导出含笔记的 `.dlreview` 备份。解析器修复上线后刷新网页，再导入原始 `.dem`；旧工程保存的是原解析结果，重新打开不会补算缺失字段，旧笔记也不会自动迁移。

**维护者：** 先用更新前、后各一场录像区分素材过期与协议变化：

| 现象 | 优先检查 | 修复后怎么验 |
| --- | --- | --- |
| 新英雄、装备或技能缺图，资源类型错误 | `assets/heroes.json`、`assets/abilities/`、`assets/items/`、`assets/tactical/`。按游戏内部 ID 更新映射和图片，一并更新来源、SHA256 和素材说明。 | 对比同一回放时刻的阵容、装备和图标；未知 ID 应能回退显示。 |
| 地形、商店、路线与走位对不上 | `assets/cursed-apple-*`、`assets/map-source.json`、`assets/tactical/map-features.json` 与 `core/map.mjs` 的坐标范围。底图和坐标应来自同一版本。 | 用双方基地、商店和路线分别校准；同时检查旧 Build，避免给历史录像套错底图。 |
| `.dem` 解析失败，或 CD、事件、经济等字段异常 | 对照对应游戏 Build 和上游 [demofile-net](https://github.com/saul/demofile-net)，检查 `vendor/demofile-net` 的 Deadlock 协议、实体和解码器，再看 `parser/browser/ReplayParser.cs` 的字段读取、`core/analysis.mjs` 的统计。保留本项目已有的解码修正。 | 对新旧录像核对玩家数、帧/事件数、解码错误和几个已知时刻；解析结果语义变化时更新 `parserVersion`，并在发行说明标明适用 Build 与是否需要重导。 |

纯素材变更：`npm ci` → `npm test` → `npm run build`。如修改了 C# 或协议，先安装 .NET 10 SDK 与 `wasm-tools`，在 `npm ci` 后运行 `npm run build:parser`，再测试和构建；将**重新生成的 `public/parser/`** 与修改一起提交。Pages 直接使用这份运行时，不会因为改了 C# 自动重编。部署前在桌面 Chrome / Edge 中实际导入新旧录像，并检查导出再导入工程能否正常回放。

## 反馈与许可

欢迎在 [GitHub Issues][issues] 反馈，或加入 QQ 群 **1062198581** 交流。作者：**Skn1Siyu**。

项目代码采用 [MIT 许可](LICENSE)，第三方组件和游戏素材见[第三方说明](THIRD_PARTY_NOTICES.md)。

[web]: https://skn1siyu.github.io/foucus-lens/
[issues]: https://github.com/Skn1Siyu/foucus-lens/issues
[releases]: https://github.com/Skn1Siyu/foucus-lens/releases
