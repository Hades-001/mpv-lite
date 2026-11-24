# mpv Windows 便携配置（uosc + PlayKit lite 核心）

一套面向 **Windows 10/11** 的 mpv 便携配置：以 [hooke007/mpv_PlayKit](https://github.com/hooke007/mpv_PlayKit/tree/lite/portable_config) 的 lite 分支为参考，保留其核心使用体验，集成 [tomasklaen/uosc](https://github.com/tomasklaen/uosc) 面板，并**移除 VapourSynth（vs）相关补帧 / AI 滤镜**，改用 mpv 内置同步与精选 GLSL 着色器。

- uosc 版本：**5.13.0**（上游原版，未改 UI 代码）
- 目标 mpv：**0.40 或更高**（推荐 mpv-lazy 2026 / mpv.io 官方 Windows 构建）
- 渲染：`vo=gpu-next` + D3D11；音频：WASAPI
- 缩略图：PlayKit 的 `thumb_engine`（以 `thumbfast` 名称加载，uosc 原生识别），**不需要额外安装 ffmpeg**
- 无 VapourSynth、SVP、RIFE、TensorRT、CUDA 依赖
- 代码仓库：<https://github.com/Hades-001/mpv-lite>

---

## 1. 特性

### 与 PlayKit lite 一致的核心功能

- **uosc 面板**：时间线、缩略图预览、顶栏、控制条、播放列表 / 章节 / 轨道菜单
- **中文界面 + 中文右键菜单**（uosc 内置 `zh-hans` 翻译）
- **中文字幕默认使用霞鹜文楷 Mono Lite**（随包 `fonts/LXGWWenKaiMonoLite-Regular.ttf`）
- **着色器菜单**：QCOM、Anime4K、Ani4Kv2、FSRCNNX、NNEDI3、SSim 等下采样/锐化方案
- **自动配置**：
  - HDR 片源自动启用动态峰值检测、对比度恢复与 BT.2446a / ST2094-40 色调映射
  - 低码率（< 3000 kbps）自动去色带
  - 高帧率 / 高刷新率 / 倍速时自动关闭插值，改用音频时钟
  - 接近片尾、短视频、纯音频、封面图不写入播放进度
- **截图、统计信息、控制台、按键绑定列表**
- **音量 / 静音记忆**（退出时保存，下次启动恢复）
- **Windows 适配**：WASAPI、D3D11、Windows 桌面截图路径、`{drives}` 文件浏览器
- **字幕字体**：随包附带 **霞鹜文楷 Mono Lite**，并针对可读性调优；OSD/界面文字仍使用微软雅黑

### 相对参考项目的改动

| 项目 | PlayKit lite | 本配置 |
|---|---|---|
| VapourSynth | `vs/` 目录 + MEMC/RIFE/DRBA/UAI 等 vpy | **全部删除** |
| 补帧 | VS 滤镜（MVTools/RIFE/DRBA/SVP） | mpv 内置 `display-resample` + `interpolation`，零依赖 |
| AI 超分 | UAI / TensorRT / DirectML | 精选 GLSL（Anime4K / Ani4Kv2 / FSRCNNX） |
| 滤镜数量 | 100+ 着色器全量收录 | 精选 10 个，避免误叠加与磁盘膨胀 |
| uosc | 深度定制分支（menu.conf、checked 状态等） | 上游 5.13.0，菜单写在 `input.conf`，便于更新 |
| 缩略图 | `thumb_engine` | 同一引擎，重命名为 `thumbfast` 以走 uosc 标准协议 |
| 额外脚本 | input_plus、contextmenu_plus、stats_mediainfo 等 | 只保留 uosc、缩略图、音量记忆和一个小工具脚本 |

---

## 2. 安装

1. 下载 Windows 版 mpv（0.40+），解压到例如 `D:\mpv\`：
   - 官方构建：<https://mpv.io/installation/>
   - 或 mpv-lazy：<https://github.com/hooke007/mpv_PlayKit/releases>
2. 把本目录下的 **`portable_config`** 整个文件夹复制到 `mpv.exe` 同级：
   ```
   D:\mpv\
   ├─ mpv.exe
   └─ portable_config\
      ├─ mpv.conf
      ├─ input.conf
      ├─ profiles.conf
      ├─ script-opts\
      ├─ scripts\
      ├─ shaders\
      ├─ fonts\
      └─ _cache\
   ```
3. 双击 `mpv.exe` 或把视频拖到 `mpv.exe` 上。
4. 在画面上**右键**打开 uosc 中文菜单；顶部/底部控件会自动隐藏，移动鼠标呼出。

> 便携模式要求文件夹名必须是 `portable_config`，且与 `mpv.exe` 同级。放到 `%APPDATA%\mpv` 也能用，但就不是“便携”了。

### 首次检查

- 按 `` ` `` 打开控制台，确认没有红色报错；正常应看到 `playkit.lua 已加载` 和 uosc 版本信息。
- 按 `i` 打开统计信息，确认 `VO: gpu-next`、`hwdec: auto-copy (d3d11va)`。
- 鼠标移到时间线上，等待 1～2 秒应出现缩略图。

---

## 3. 目录结构

```
portable_config/
├─ mpv.conf                  # 主配置（Windows + D3D11）
├─ profiles.conf             # 自动/手动预设
├─ input.conf                # 快捷键 + uosc 中文菜单定义
├─ script-opts/
│  ├─ uosc.conf              # uosc 选项（中文、控件、autoload）
│  ├─ thumbfast.conf         # 缩略图引擎
│  └─ save_global_props.conf # 音量记忆
├─ scripts/
│  ├─ uosc/                  # uosc 5.13.0 上游脚本 + 中文翻译
│  ├─ thumbfast/             # thumb_engine（thumbfast 兼容接口）
│  ├─ playkit.lua            # 着色器预设 / 重置工具
│  └─ save_global_props.lua  # 音量记忆
├─ shaders/
│  ├─ QCOM/                  # 默认缩放锐化
│  ├─ Anime4K/               # 动画向
│  ├─ Ani/                   # Ani4Kv2
│  ├─ FSRCNNX/               # 真人向放大
│  ├─ EDI/                   # NNEDI3
│  ├─ Adaptive_sharpen/      # 轻量锐化
│  └─ SSim/                  # 下采样
├─ fonts/                    # uosc 图标/纹理字体 + 霞鹜文楷
└─ _cache/                   # 缓存目录（icc / shader / watch_later）
```

`fonts/` 里的字体由 mpv 自动从 `~~/fonts` 加载，无需安装到系统：

- 字幕：**霞鹜文楷 Mono Lite**（`LXGWWenKaiMonoLite-Regular.ttf`）
- uosc 图标 / 纹理：`uosc_icons.otf`、`uosc_textures.ttf`
- OSD 与 uosc 中文界面：Windows 自带的 **Microsoft YaHei UI**

字幕显示调优（兼顾可读性与观感）：

- `44px` 字号，`3px` 黑色描边，`0.5px` 轻微模糊，避免粗描边糊字
- `1.5px` 半透明阴影（`sub-back-color=#80000000`）增加层次，不出现黑框
- 底部 `sub-pos=96`，留出约 4% 边距；`sub-line-spacing=0.5` 改善多行间距
- `sub-scale-with-window=yes`、`sub-scale-signs=yes`，窗口缩放时字幕与符号同步缩放
- `sub-ass-force-margins=yes`，避免字幕落进黑边

> 霞鹜文楷使用 SIL Open Font License 1.1，许可证见 `LICENSES/LXGW-WenKai-OFL.txt`。

---

## 4. 快捷键

### 播放

| 按键 | 功能 |
|---|---|
| `Space` | 暂停 / 播放 |
| `←` / `→` | 后退 / 前进 5 秒 |
| `↑` / `↓` | 前进 / 后退 60 秒 |
| `Shift+←` / `Shift+→` | 精确后退 / 前进 1 秒 |
| `,` / `.` | 上一帧 / 下一帧 |
| `l` | 设置 / 清除 AB 循环 |
| `[` / `]` | 速度 -0.1 / +0.1 |
| `Backspace` | 速度重置为 1.0 |
| `-` / `=` | 音量 -2 / +2 |
| `m` | 静音 |
| `c` / `v` | 音频延迟 -0.1s / +0.1s |
| `z` / `x` | 字幕延迟 -0.1s / +0.1s |
| `Shift+Backspace` | 重置音频与字幕延迟 |
| `j` / `a` | 切换字幕轨 / 音轨 |
| `Shift+v` | 显示 / 隐藏字幕 |

### 画面 / 窗口

| 按键 | 功能 |
|---|---|
| `f` / `Alt+Enter` | 切换全屏 |
| `Enter` / `Esc` | 进入 / 退出全屏 |
| `1`～`0` | 对比度、亮度、伽马、饱和度、色相 ±1 |
| `Ctrl+Backspace` | 重置画面均衡器 |
| `Alt+滚轮` | 缩放画面 |
| `Alt+Backspace` | 重置缩放 / 平移 |
| `Ctrl+t` | 窗口置顶 |
| `Ctrl+b` | 窗口边框 |
| `s` / `Ctrl+s` / `Shift+s` | 原始画面（无字幕）/ 窗口（含 OSD）/ 原始画面（含字幕） |

### 工具 / 文件

| 按键 | 功能 |
|---|---|
| `i` | 统计信息 |
| `Ctrl+i` | 按键绑定列表 |
| `` ` `` | 控制台 |
| `Ctrl+o` | 打开文件 |
| `Ctrl+Shift+v` | 从剪贴板加载 URL |
| `Ctrl+p` | 播放列表 |
| `Ctrl+Left` / `Ctrl+Right` | 上一个 / 下一个文件 |
| `Ctrl+r` | 清除音量记忆 |
| `q` / `Ctrl+q` | 退出 |

### 着色器

| 按键 | 方案 |
|---|---|
| `Ctrl+1` | QCOM（默认，轻量缩放锐化） |
| `Ctrl+2` | Anime4K 快速（Clamp + Restore CNN M + Upscale CNN x2 M） |
| `Ctrl+3` | Anime4K AIO（AIO_optQ） |
| `Ctrl+4` | Ani4Kv2（动画 1080p→4K，较重） |
| `Ctrl+5` | FSRCNNX + 自适应锐化（真人向） |
| `Ctrl+6` | NNEDI3 边缘插值 |
| `Ctrl+7` | SSim 下采样（4K→1080p） |
| `Ctrl+0` | 关闭全部着色器 |

> 着色器方案是**替换式**的：切换方案会清空当前列表再加载，不会叠加。不要同时手动叠加 Anime4K 和 QCOM，否则会重复锐化。

---

## 5. 菜单

右键画面打开 uosc 菜单，包含：

- **加载**：打开文件、从剪贴板打开、加载字幕
- **导航**：播放列表、章节、版本、视频/音频/字幕轨、乱序播放
- **播放**：暂停、逐帧、AB 循环、定速、音量、音字幕延迟、轨道切换
- **视频**：均衡器、解码模式（硬解/复制/软解）、去色带、去隔行、ICC、性能/画质/动画预设、双声道下混、重置缩放
- **滤镜**：清空视频滤镜、插帧开关、视频同步模式
- **着色器**：方案 + 单项开关
- **截屏**：三种截图方式
- **工具**：统计、按键绑定、控制台、清除音量记忆、置顶、边框、打开文件位置/配置目录、缩略图开关/重建
- **退出**

菜单项全部来自 `input.conf` 中以 `#!` 结尾的注释；想增删菜单，直接编辑 `input.conf` 即可。

---

## 6. 滤镜 / 画质说明

### 默认策略

- **缩放**：`scale=bilinear` + `cscale=bicubic` + `dscale=mitchell`
- **锐化**：只加载 `QCOM_SGEDS_ms_RT.glsl`（POSTKERNEL 阶段缩放锐化），`STR=3.0`（默认 4.0，降低振铃）
- **去色带**：默认关闭；仅当本地文件码率低于 3000 kbps 时由 `[deband_low_bitrate]` 自动开启，参数为 2 次迭代 / 阈值 40 / 半径 12，比 PlayKit 默认更轻，减少糊化
- **插帧**：`video-sync=display-resample` + `interpolation=yes` + `tscale=oversample`，替代 VS 补帧
- **HDR**：`target-colorspace-hint=auto` 优先直通；SDR 显示器走 `[HDR]` 动态色调映射
- **HDR10+**：检测到逐场景元数据时由 `[HDR10plus]` 自动切换 `st2094-40`

### HDR 播放

Windows 端分两种情况：

1. **显示器支持 HDR，且 Windows 已开启 HDR**
   - 默认 `target-colorspace-hint=auto`：mpv 检测到显示器支持 HDR 时直接输出 HDR，避免二次色调映射
   - 如果自动检测不生效，菜单“视频 > HDR 模式 > 强制 HDR 输出”
   - 仍不行时可在启动参数加 `--profile=HDR_passthrough`

2. **SDR 显示器，或 Windows HDR 关闭**
   - `[HDR]` 自动启用：`hdr-compute-peak=yes` + `tone-mapping=bt.2446a` + `gamut-mapping-mode=perceptual`
   - `hdr-contrast-recovery=0.2` 在色调映射后补回一点对比度，避免 HDR 转 SDR 发灰
   - `hdr-peak-percentile=99.9`、`hdr-peak-decay-rate=100`、场景阈值 5/15，兼顾高光细节和亮度稳定
   - 不建议手动提高 `target-peak`，容易让 SDR 场景过曝

HDR10+ 片源会额外命中 `[HDR10plus]`，使用 `st2094-40` 动态色调映射；普通 HDR10 仍使用 `bt.2446a`。HDR 模式下 `blend-subtitles=no`，避免字幕被错误地混入 HDR 信号。

> 若使用 mpv 0.41+，还可以尝试 `target-colorspace-hint-mode=source`、`sub-hdr-peak` 等新选项；本配置为兼容 mpv 0.40 未启用这些选项。

### 着色器怎么选

| 场景 | 推荐 |
|---|---|
| 日常 / 核显 / 不想折腾 | **QCOM（默认）** |
| 1080p 动画 → 4K | Anime4K 快速；显卡强可用 Ani4Kv2 |
| 720p 动画 → 1080p | Anime4K 快速 |
| 真人电影 / 剧集 | FSRCNNX + 自适应锐化；或关闭着色器只看内置缩放 |
| 4K → 1080p 显示器 | SSim 下采样 |
| 老显卡 / 4K 高帧率 | `Ctrl+0` 关闭着色器 + `--profile=low_end` |

### 手动预设

启动参数或播放中执行：

```bat
mpv.exe --profile=quality   video.mkv
mpv.exe --profile=low_end   video.mkv
mpv.exe --profile=anime     video.mkv
mpv.exe --profile=stereo    video.mkv
```

播放中可在控制台执行 `apply-profile low_end`，或在菜单“视频”里选择“性能模式 / 画质模式”。

### 性能建议

- 核显或 4K 高帧率：`--profile=low_end`，关闭插值（菜单“滤镜 > 开关插帧”）和着色器
- 独显但风扇吵：保留 QCOM，关闭 Anime4K/Ani4Kv2
- 24p 在 60Hz 上仍觉得抖：确认 `interpolation=yes`，并把显示器设为 60Hz；VRR 显示器可尝试 `--video-sync=display-resample` 保持开启
- HDR 画面发灰/过曝：菜单“视频 > HDR 模式”在“自动 / 强制 HDR / 强制 SDR”之间切换；确认 Windows HDR 开关与显示器 HDR 模式
- Windows 常开 HDR 时，SDR 片源可能显得偏暗：这是系统 HDR 容器所致，可关闭系统 HDR，或接受桌面 SDR 内容的映射方式

---

## 7. 与 VapourSynth 相关的清理说明

已删除 / 不再引用：

- `portable_config/vs/` 全部 `.vpy`
- `MEMC_MVT_LQ`、`MEMC_RIFE_DML/NV/STD`、`MEMC_DRBA_DML/NV`、`MEMC_SVP_PRO`
- `MIX_UAI_DML/NV_TRT/MIGX`、`MIX_UVR_MAD`
- `NR_BM3D_NV`、`NR_CCD_STD`、`SR_ARTCNN_NV`、`ETC_DEINT_EX`
- `[EXT_vpy]` 预设、所有 `vf set vapoursynth=...` 菜单/快捷键
- `input-ipc-server` 的 SVP 依赖（保留注释示例）

因此本配置**不需要**安装 VapourSynth、SVP Manager、RIFE、TensorRT、CUDA 或 Python。补帧需求由 mpv 内置插值承担；如果需要真正的运动补偿，请自行另装 VS，并自行承担兼容性。

---

## 8. 常见问题

**Q: 缩略图不显示？**
- 视频时长需 ≥ 20 秒（`thumbfast.conf` 的 `min_duration`）
- 网络流默认不生成缩略图（`network=no`）
- 若 mpv 不在 PATH 且缩略图后端启动失败：把 `thumbfast.conf` 的 `binpath` 改成 `mpv.exe` 绝对路径，例如 `binpath=C:/mpv/mpv.exe`
- 可在菜单“工具 > 重建缩略图”手动重启

**Q: 右键没有菜单 / uosc 不显示？**
- 确认 mpv 版本 ≥ 0.40
- 按 `` ` `` 看控制台是否有 `uosc` 加载失败；确认 `scripts/uosc/main.lua` 存在
- 确认 `mpv.conf` 中 `osc=no`（uosc 与原生 OSC 二选一）

**Q: 中文界面变成英文？**
- `script-opts/uosc.conf` 中 `languages=zh-hans,en`
- 确认 `scripts/uosc/intl/zh-hans.json` 存在

**Q: 想换字幕字体 / 换回微软雅黑？**
- 本配置默认 `sub-font = "LXGW WenKai Mono Lite"`，字体已放在 `portable_config/fonts/`，无需安装
- 换回系统字体：把 `mpv.conf` 的 `sub-font` 改为 `"Microsoft YaHei UI"`
- 想用比例版：从 [LXGW WenKai](https://github.com/lxgw/LxgwWenKai) 下载 `LXGWWenKai-Regular.ttf`，把 `sub-font` 改为 `"LXGW WenKai"`，并将字体放进 `fonts/`
- ASS 字幕如果自带字体/样式，会优先使用字幕内嵌字体；本配置没有强制覆盖 ASS 样式

**Q: 着色器报错 / 黑屏？**
- 先按 `Ctrl+0` 关闭全部着色器，确认能正常播放
- 更新显卡驱动和 mpv；部分老 Intel 核显不支持较大的 CNN 着色器
- `Ani4Kv2` 和 `Anime4K AIO` 对显存/算力要求较高，4K 屏幕建议先用 Anime4K 快速或 QCOM

**Q: 没有声音？**
- 本配置使用 `ao=wasapi`；如果系统有多个输出设备，菜单“工具”里没有设备列表时，可在控制台执行 `set audio-device` 查看，或在 `mpv.conf` 里指定 `audio-device`
- 蓝牙耳机切换后如无声，重启 mpv 或切换一次设备

**Q: 为什么没有“补帧”菜单？**
- 本配置刻意移除了 VapourSynth。内置插值不是运动补偿，但零依赖、对弹幕/字幕/截图更友好；需要 MEMC 请自行安装 VS 并添加 `vf=vapoursynth=...`

---

## 9. 自定义

- **改快捷键 / 菜单**：编辑 `input.conf`；uosc 菜单由 `#!` 注释生成
- **改 uosc 外观**：编辑 `script-opts/uosc.conf`（颜色、透明度、控件、时间线等）
- **改字幕字体**：编辑 `mpv.conf` 的 `sub-font`；字体文件放 `portable_config/fonts/` 即可自动加载
- **改预设**：编辑 `profiles.conf`；`profile-cond` 是 Lua 表达式，可用 `p.` 访问 mpv 属性
- **加着色器**：放进 `shaders/`，在 `scripts/playkit.lua` 的 `presets` 表里加一项，并在 `input.conf` 加菜单项
- **恢复 PlayKit 的完整着色器库**：从 [PlayKit main 分支](https://github.com/hooke007/mpv_PlayKit/tree/main/portable_config/shaders) 复制需要的 `.glsl`，不要复制 `vs/`

---

## 10. 兼容性与校验

- 配置按 **mpv 0.40+** 编写；Windows 专属选项（`d3d11-*`、`ao=wasapi`）按 mpv 官方手册核对
- uosc 5.13.0 原版脚本 + 中文翻译；`thumb_engine` 仅增加 `thumbfast-info` 广播，以兼容 uosc 的缩略图协议
- 已在 macOS 的 mpv 0.40 上做过配置解析 / 脚本加载的冒烟测试（Windows 专属选项在测试时替换为对应平台值）；**着色器性能和 HDR 直通仍需在目标 Windows 机器上实测**
- 如果使用 mpv-lazy 自带 `portable_config`，请先备份，再用本目录覆盖；两者脚本可能重名

---

## 11. 致谢 / 许可

- [hooke007/mpv_PlayKit](https://github.com/hooke007/mpv_PlayKit)：配置结构、缩略图引擎、着色器整理与中文菜单参考
- [tomasklaen/uosc](https://github.com/tomasklaen/uosc)：面板（LGPL-2.1）
- [po5/thumbfast](https://github.com/po5/thumbfast)：缩略图协议（MPL-2.0）
- 着色器作者：QCOM/Snapdragon、bloc97/Anime4K、igv/FSRCNNX、Sirosky/Ani4Kv2、bacondither/Adaptive sharpen 等，各文件头部保留原始许可
- 字体：uosc 图标/纹理字体（随 uosc 分发）

本配置文件和脚本仅做整合与参数调整；第三方组件请遵循各自许可证。详见 `THIRD_PARTY_NOTICES.md`。
