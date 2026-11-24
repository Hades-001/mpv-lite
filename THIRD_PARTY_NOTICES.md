# 第三方组件与许可

本项目是配置文件与脚本的整合，不改变第三方组件的许可。以下组件按原许可分发：

## uosc 5.13.0

- 项目：<https://github.com/tomasklaen/uosc>
- 许可：GNU Lesser General Public License v2.1（LGPL-2.1）
- 许可证全文：`LICENSES/uosc-LGPL-2.1.txt`
- 位置：`portable_config/scripts/uosc/`、`portable_config/fonts/uosc_icons.otf`、`portable_config/fonts/uosc_textures.ttf`
- 说明：未修改 uosc 的 Lua 代码；仅随包提供 `script-opts/uosc.conf` 配置。`scripts/uosc/bin/` 中保留了上游的 Windows 版 `ziggy-windows.exe`（用于文件名排序），已删除 macOS/Linux 版本以减小体积。

## thumbfast / thumb_engine

- 上游协议与原始代码：<https://github.com/po5/thumbfast>
- 本配置使用：`hooke007/mpv_PlayKit` 的 `thumb_engine`（thumbfast 的增强分支）
  - 项目：<https://github.com/hooke007/mpv_PlayKit>
  - 讨论：<https://github.com/hooke007/mpv_PlayKit/discussions/668>
- 许可：原始 thumbfast 为 Mozilla Public License 2.0（MPL-2.0）；`thumb_engine` 的修改部分见 PlayKit 仓库说明
- 许可证全文：`LICENSES/thumbfast-MPL-2.0.txt`
- 位置：`portable_config/scripts/thumbfast/`
- 修改：
  - 目录/脚本名从 `thumb_engine` 改为 `thumbfast`，以匹配 uosc 的缩略图协议
  - `main.lua` 的 `info()` 额外广播一条 `thumbfast-info` 消息
  - 配置文件名改为 `script-opts/thumbfast.conf`
  - 删除与批量模式无关的界面入口（脚本代码保留）

## PlayKit 配置参考

- 项目：<https://github.com/hooke007/mpv_PlayKit>
- 许可说明：<https://github.com/hooke007/mpv_PlayKit/blob/main/LICENSE.MD>（仓库标注为 Other，部分文件 UNLICENSED）
- 本项目参考了其 lite 分支的配置结构、菜单组织、profiles 条件写法与着色器清单；未复制其 `vs/`、`input_plus.lua`、`uosc_addones/` 等文件。`thumb_engine` 的复制作单独说明见上。

## 着色器

各 `.glsl` 文件头部保留了原始版权与许可声明，主要包括：

| 着色器 | 作者 / 来源 | 许可 |
|---|---|---|
| `QCOM/QCOM_SGEDS_ms_RT.glsl` | Snapdragon Studios (Snapdragon GSR) | 见文件头（Snapdragon GSR LICENSE） |
| `Anime4K/*` | bloc97 / Anime4K | MIT |
| `Ani/Ani4Kv2_ArtCNN_C4F32_i2_dx.glsl` | Sirosky / ArtCNN（Joao Chrisostomo） | CC BY-NC 4.0 + MIT（见文件头） |
| `FSRCNNX/FSRCNNX_x2_16_0_4_1.glsl` | igv | LGPL-3.0-or-later |
| `EDI/nnedi3_nns64_win8x4.glsl` | 社区移植（原 nnedi3） | LGPL-3.0-or-later |
| `Adaptive_sharpen/Adaptive_sharpen_lite_RT.glsl` | bacondither | BSD 2-Clause（见文件头） |
| `SSim/SSimDownscaler_RT.glsl` | igv / MPDN Extensions 等 | 见文件头链接 |

其中 **Ani4Kv2 为 CC BY-NC 4.0（禁止商业使用）**，请勿将本包整体用于商业分发。其余着色器请遵循各自文件头。

## 字体

### 霞鹜文楷 Mono Lite（LXGW WenKai Mono Lite）

- 项目：<https://github.com/lxgw/LxgwWenKai>
- 版本：v1.530（`LXGWWenKaiMonoLite-Regular.ttf`，Lite 子集）
- 许可：SIL Open Font License 1.1（OFL-1.1），含 Reserved Font Name 附加说明
- 许可证全文：`LICENSES/LXGW-WenKai-OFL.txt`
- 位置：`portable_config/fonts/LXGWWenKaiMonoLite-Regular.ttf`
- 用途：mpv `sub-font` 默认字幕字体

### uosc 字体

- `uosc_icons.otf`、`uosc_textures.ttf` 随 uosc 分发，遵循 uosc 的许可与字体自身声明。

OSD 与 uosc 中文界面使用 Windows 自带的 Microsoft YaHei UI，不随包分发。

---

如果你重新分发本配置包，请保留本文件、`LICENSES/` 目录以及各脚本/着色器文件头中的版权声明。
