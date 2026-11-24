--[[
  playkit.lua —— 为这套 Windows 便携配置补充的小工具

  功能:
    1. 着色器预设 / 单项开关（替代 PlayKit 的 uosc_addones 着色器菜单）
    2. 重置音字幕延迟、均衡器、画面缩放
    3. 所有操作都有中文 OSD 提示

  约定:
    着色器全部放在 portable_config/shaders/ 下，路径用 “~~/shaders/...” 表示。
    以 script-binding playkit/<name> 调用，例如:
      script-binding playkit/shader_anime4k
      script-binding playkit/shader_off
]]

local mp = require 'mp'
local msg = require 'mp.msg'

local shader_root = '~~/shaders/'

-- 顺序即菜单中“方案”的顺序
local presets = {
	{
		id = 'qcom',
		label = 'QCOM 缩放锐化',
		files = { 'QCOM/QCOM_SGEDS_ms_RT.glsl' },
	},
	{
		id = 'anime4k',
		label = 'Anime4K 快速',
		files = {
			'Anime4K/Anime4K_Clamp_Highlights.glsl',
			'Anime4K/Anime4K_Restore_CNN_M.glsl',
			'Anime4K/Anime4K_Upscale_CNN_x2_M.glsl',
		},
	},
	{
		id = 'anime4k_aio',
		label = 'Anime4K AIO',
		files = { 'Anime4K/Anime4K_AIO_optQ.glsl' },
	},
	{
		id = 'ani4k',
		label = 'Ani4Kv2',
		files = { 'Ani/Ani4Kv2_ArtCNN_C4F32_i2_dx.glsl' },
	},
	{
		id = 'live',
		label = 'FSRCNNX + 锐化',
		files = {
			'FSRCNNX/FSRCNNX_x2_16_0_4_1.glsl',
			'Adaptive_sharpen/Adaptive_sharpen_lite_RT.glsl',
		},
	},
	{
		id = 'nnedi3',
		label = 'NNEDI3 边缘插值',
		files = { 'EDI/nnedi3_nns64_win8x4.glsl' },
	},
	{
		id = 'downscale',
		label = 'SSim 下采样',
		files = { 'SSim/SSimDownscaler_RT.glsl' },
	},
	{
		id = 'off',
		label = '关闭全部',
		files = {},
	},
}

local function expand(path)
	local result = mp.command_native({ 'expand-path', path })
	return result
end

local function norm(path)
	local p = expand(path) or path
	return p:gsub('\\', '/'):lower()
end

local function get_list()
	return mp.get_property_native('glsl-shaders') or {}
end

local function set_list(list, message)
	mp.set_property_native('glsl-shaders', list)
	mp.osd_message(message, 2)
end

local function apply(files, label)
	local list = {}
	for _, file in ipairs(files) do
		list[#list + 1] = expand(shader_root .. file)
	end
	if #list == 0 then
		set_list({}, '着色器：已关闭')
	else
		set_list(list, string.format('着色器：%s（%d 个）', label, #list))
	end
end

local function has(list, path)
	local target = norm(path)
	for _, item in ipairs(list) do
		if norm(item) == target then return true end
	end
	return false
end

local function toggle(files, label)
	local list = get_list()
	local present = 0
	for _, file in ipairs(files) do
		if has(list, shader_root .. file) then present = present + 1 end
	end

	if present == #files then
		-- 全部存在：全部移除
		local remove = {}
		for _, file in ipairs(files) do remove[norm(shader_root .. file)] = true end
		local result = {}
		for _, item in ipairs(list) do
			if not remove[norm(item)] then result[#result + 1] = item end
		end
		set_list(result, '已关闭：' .. label)
	else
		-- 存在缺项：补齐缺的，不重复添加
		local result = {}
		local seen = {}
		for _, item in ipairs(list) do
			result[#result + 1] = item
			seen[norm(item)] = true
		end
		for _, file in ipairs(files) do
			local path = shader_root .. file
			if not seen[norm(path)] then
				result[#result + 1] = expand(path)
				seen[norm(path)] = true
			end
		end
		set_list(result, '已开启：' .. label)
	end
end

-- 注册预设
for _, preset in ipairs(presets) do
	mp.add_key_binding(nil, 'shader_' .. preset.id, function()
		apply(preset.files, preset.label)
	end)
end

-- 单项开关
mp.add_key_binding(nil, 'toggle_qcom', function()
	toggle({ 'QCOM/QCOM_SGEDS_ms_RT.glsl' }, 'QCOM')
end)

mp.add_key_binding(nil, 'toggle_anime4k', function()
	toggle({
		'Anime4K/Anime4K_Clamp_Highlights.glsl',
		'Anime4K/Anime4K_Restore_CNN_M.glsl',
		'Anime4K/Anime4K_Upscale_CNN_x2_M.glsl',
	}, 'Anime4K 三件套')
end)

mp.add_key_binding(nil, 'toggle_ani4k', function()
	toggle({ 'Ani/Ani4Kv2_ArtCNN_C4F32_i2_dx.glsl' }, 'Ani4Kv2')
end)

mp.add_key_binding(nil, 'toggle_sharpen', function()
	toggle({ 'Adaptive_sharpen/Adaptive_sharpen_lite_RT.glsl' }, '自适应锐化')
end)

mp.add_key_binding(nil, 'toggle_ssim', function()
	toggle({ 'SSim/SSimDownscaler_RT.glsl' }, 'SSim 下采样')
end)

-- 重置音字幕同步
mp.add_key_binding(nil, 'reset_sync', function()
	mp.set_property_number('audio-delay', 0)
	mp.set_property_number('sub-delay', 0)
	mp.osd_message('音字幕延迟已重置', 2)
end)

-- 重置画面均衡器
mp.add_key_binding(nil, 'reset_eq', function()
	for _, prop in ipairs({ 'contrast', 'brightness', 'gamma', 'saturation', 'hue' }) do
		mp.set_property_number(prop, 0)
	end
	mp.osd_message('画面均衡器已重置', 2)
end)

-- 重置缩放 / 平移
mp.add_key_binding(nil, 'reset_zoom', function()
	for _, prop in ipairs({
		'video-zoom', 'panscan',
		'video-pan-x', 'video-pan-y',
		'video-align-x', 'video-align-y',
	}) do
		mp.set_property_number(prop, 0)
	end
	mp.set_property_number('video-scale-x', 1)
	mp.set_property_number('video-scale-y', 1)
	mp.osd_message('缩放 / 平移已重置', 2)
end)

msg.info('playkit.lua 已加载：着色器预设 + 重置工具')
