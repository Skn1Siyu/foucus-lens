# Focus Lens Web 第三方说明

本项目代码采用 MIT，见 LICENSE。EchoSkn1 的项目署名与第三方版权分开保留；本项目不代表 Valve、Steam、demofile-net 或其他第三方的官方产品。

## 解析器与浏览器运行时

- demofile-net，Saul Rennison，MIT，来源 https://github.com/saul/demofile-net 。独立源码在 vendor/demofile-net，保留原 LICENSE 与 ACKNOWLEDGEMENTS（含 dotabuff/manta、LaihoE/demoparser 的许可）。来源为用户提供的 0.44.1 归档，含归档内 BitBuffer 补丁、Deadlock 适配及本项目后续修正，不声明与上游主分支一致。浏览器宿主代码位于 parser/browser；无须用户安装 .NET。
- Google.Protobuf 3.22.1：BSD-3-Clause；protobuf-net / protobuf-net.Core 3.2.16：Apache-2.0；Snappier 1.3.1：BSD-3-Clause。原始许可在 licenses/upstream，静态站点同步到 public/licenses/upstream；Apache-2.0 完整条文另见 licenses/upstream/Apache-2.0.txt，并包含在 npm-runtime-licenses.txt 的 ECharts LICENSE 中。
- .NET browser runtime 10.0.15：MIT 与其第三方说明。完整文件在 licenses/upstream/dotnet-*。运行时附带的第三方代码以其各自条款为准。
- NuGet / Grpc.Tools、.NET SDK 和 wasm-tools 是开发构建工具，不随网页分发。构建工具本身的许可保留在开发者安装包中。

## JavaScript 运行依赖

React / React DOM、PixiJS、fflate、sql.js 及多数传递依赖采用 MIT；ECharts 为 Apache-2.0，zrender / @webgpu/types / tiny-lru 为 BSD-3-Clause，earcut 为 ISC，tslib 为 0BSD。确切版本与各包原始许可、版权、NOTICE 由 npm run licenses 从 package-lock.json 及已安装包提取到 public/licenses/manifest.json 和 npm-runtime-licenses.txt，构建时自动刷新。

@pixi/colord 2.9.6 的 npm 发布包未附完整许可；其 package.json 声明 MIT / omgovich/colord / Vlad Shilov，补充保留该上游 LICENSE.md（licenses/upstream/colord-MIT.txt）。来源 https://github.com/omgovich/colord 。sql.js 自身为 MIT，SQLite 上游为公有领域。开发依赖不打包到站点，许可保留在各 npm 包中。

Web 版没有打包 Electron、better-sqlite3、Steam 登录或录像下载代码。CS-Demo-Downloader 仅为桌面阶段的研究参考，Web 版未复制其代码。

## 游戏素材（不适用项目 MIT 许可）

地图、英雄、技能、装备、建筑、野怪等图片以及 Focus Lens 应用图标来自 Valve 的 Deadlock 游戏素材。它们经社区 Deadlock API 获取，社区 API 提供下载不等于授予素材版权或再许可。发布者仍需确认适用的 Valve 授权与使用条件；本说明和来源标注不能代替权利人许可。未从 Deadlock Wiki 或 statlocker 页面复制图片、文字或代码。

- 地图：assets/map-source.json，参考 https://deadlock.wiki/Cursed_Apple 。
- 战术图标与英雄头像：assets/tactical/sources.json。
- 技能：assets/abilities/catalog.json；装备：assets/items/catalog.json。
- 聚焦透镜页头及应用图标：assets/branding/sources.json，原始装备 ID 2142980412，包含缩放派生版本。
- Buff 配色与去除中心圆点的派生 SVG：assets/tactical/buff-colors.json 与 sources.json，保留修改说明和原始/派生哈希。
- 英雄 ID / 名称等元数据来源 SteamDatabase/GameTracking-Deadlock 跟踪的 Valve 游戏文件；仅作实体标识，不代表对所有游戏版本兼容。

这些来源记录保留在公开源码中。Steam、Deadlock 及相关商标与素材的权利属于各自权利人。公开代码不改变素材的权利状态。

## 发布内容与隐私

网页没有上传、云下载、Steam 登录或遥测功能；录像与笔记由用户浏览器本地处理。用户主动公开的署名为“作者@Skn1Siyu QQ群：1062198581”。该署名不替代任何第三方许可，不要求使用者加群，也不限制 MIT 所授予的复制、修改、再分发等权利。

开发用录像、测试截图、对局工程、日志、SDK、数据库与凭据均不应提交或部署。reports/ 保留为本地验收资料并整体忽略。测试中的 Private Nick / private note 等为虚构夹具。许可证中的第三方作者名、公开邮箱和上游构建路径属于必要归属或上游内容，不应误删为本项目个人信息。
