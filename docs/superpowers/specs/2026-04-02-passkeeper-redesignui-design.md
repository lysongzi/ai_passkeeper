# PassKeeper RedesignUI 高保真还原设计文档

## 背景

本次目标是以 `RedesignUI` 原型工程为唯一视觉基准，对当前 SwiftUI macOS 应用进行高保真 UI 还原。用户要求优先保证 1:1 视觉与交互一致性；若需要大量自定义实现，则应同步抽象成可复用组件体系，而不是在页面中散落样式拼装。

本设计文档基于以下输入形成：
- `RedesignUI/src/app/App.tsx` 原型实现
- `prototype-screenshots/` 中 6 组真实页面截图（含亮色模式）
- 当前 SwiftUI 组件实现：`UnlockView.swift`、`SidebarView.swift`、`MainContentView.swift`、`PasswordDetailView.swift`、`AddEditPasswordView.swift`、`SettingsView.swift`

## 目标

1. 让 SwiftUI 应用在关键页面上尽可能 1:1 对齐 RedesignUI 原型。
2. 保留现有业务逻辑、ViewModel、数据存储、安全流程，不做大规模业务改写。
3. 建立一套可复用的 PassKeeper UI 组件与 design tokens，避免页面级硬编码样式继续扩散。
4. 同时支持暗色与亮色模式，并以原型截图为校准基准。

## 非目标

1. 不在本阶段重构加密、数据库、认证等底层服务。
2. 不扩展原型之外的新功能。
3. 不为了“更原生的 macOS 风格”偏离原型视觉。
4. 不追求一次性重写整个应用；应以 UI 壳层重构 + 页面替换为主。

## 原型分析结论

### 1. 锁屏页
- 中心构图，留白非常充足。
- macOS 风格窗口壳 + 暖黑背景。
- 主视觉由橙色圆角图标容器、标题、副标题、输入框、CTA 按钮构成。
- 输入框与按钮等宽，圆角大，按钮是唯一强强调元素。

### 2. 主界面默认态
- 整体是桌面 Web App 风格的三段式布局：toolbar / sidebar / main content。
- Toolbar 极简，只有图标操作和主题切换。
- Sidebar 含搜索、密码列表、分类、底部设置入口。
- 主区域默认为空态，居中 icon + 标题 + 文案 + 添加按钮。

### 3. 详情页
- 左侧选中项有暖橙高亮与描边。
- 右侧详情区以标题区 + 字段区 + 元信息区 + 删除动作组成。
- 字段展示呈“输入框式静态容器”，强调统一块面而非原生表单。
- 用户名/密码具备复制与显示切换操作。

### 4. 添加密码弹窗
- 自定义 overlay modal，不是系统 sheet。
- Header 为左取消、中标题、右保存。
- 正文为右对齐 label 的表单结构。
- 背景压暗，当前页面仍可见。

### 5. 设置弹窗
- 与添加密码共用相同 modal 体系。
- 内容由通用和安全两个 section 构成。
- 每一项设置保持低密度、高留白。

### 6. 重置密码流程
- 仍然处于设置 modal 的语境内。
- 是设置内容的子状态，而不是新的系统级 sheet。
- 三个输入框与底部双按钮共用与原型一致的表单视觉语义。

## 当前 SwiftUI 实现差异

### 差异 1：Modal 体系不一致
当前 `SettingsViewNew` 通过 `.sheet` 打开 `PasswordResetViewNew`。原型要求重置密码是设置弹窗内部的子流程，不是二级系统 sheet。这个差异会破坏交互连续性、层级感与视觉一致性。

### 差异 2：设计系统边界还不够清晰
虽然当前已经有 `AppColors`、若干 `*New` 视图与按钮封装，但仍缺少统一的 modal、表单行、toolbar button、字段容器、sidebar row 语义抽象，导致“像原型”但还不是“结构化复刻原型”。

### 差异 3：页面壳层统一性不足
Toolbar、Sidebar、Detail、Modal 虽使用了相近的颜色与圆角，但边框、阴影、间距、层次仍不是完全统一的一组规则。

### 差异 4：状态语义不足
selected / hover / focus / destructive / disabled 的表现仍偏实现导向，而原型要求一套统一且稳定的视觉规则。

### 差异 5：亮色模式需要完整校准
当前实现已支持主题切换，但仍需逐项对照 `*-light.png` 截图校准色板、边框强度、背景层次与对比度，而不能只靠暗色模式反推。

## 设计原则

### 原则 1：原型截图优先于现有代码
任何 UI 取舍以 `prototype-screenshots/` 为准，而不是以当前 SwiftUI 页面现状为准。

### 原则 2：保留业务逻辑，重构 UI 壳层
改造应主要发生在 View、样式系统、modal 路由和组件抽象层；尽量不动 ViewModel 与 Service。

### 原则 3：先建设计系统，再页面落地
禁止继续以页面硬编码方式修修补补。必须先建立可复用的 token 与 primitive 组件，再进行屏幕级还原。

### 原则 4：同一交互问题只解决一次
例如 modal、字段容器、toolbar icon button、sidebar row 等，都应抽象成统一实现，避免在多个页面重复定义不同版本。

## 目标架构

### 1. Design Tokens
建议明确以下语义层：
- Color tokens：背景、前景、卡片、边框、accent、primary、destructive、sidebar 专用色
- Radius tokens：小、中、大、超大圆角
- Spacing tokens：列表行、字段、modal 内边距、toolbar 内边距
- Elevation tokens：窗口阴影、modal 阴影、按钮阴影
- Typography tokens：标题、副标题、字段标签、正文、说明文字
- Control tokens：输入框高度、按钮高度、图标按钮尺寸、sidebar 宽度

### 2. Primitive Components
建议建立：
- `PKWindowChrome`：macOS 风格窗口壳和顶部控制点
- `PKPrimaryButton` / `PKSecondaryButton`
- `PKIconButton`
- `PKTextField` / `PKSecureField`
- `PKFieldContainer`
- `PKModalContainer`
- `PKSectionHeader`
- `PKListSelectionBackground`

### 3. Composite Components
建议建立：
- `PKSidebarSearchField`
- `PKPasswordRow`
- `PKCategoryRow`
- `PKToolbar`
- `PKDetailFieldRow`
- `PKMetadataPanel`
- `PKFormRowRightLabel`
- `PKSettingsRow`

### 4. Screen Containers
建议组织为：
- `PKUnlockScreen`
- `PKVaultShell`
- `PKPasswordDetailScreen`
- `PKAddPasswordModal`
- `PKSettingsModal`
- `PKResetPasswordContent`

## 页面级还原要求

### Unlock
- 严格维持单中心列布局。
- 输入框、按钮宽度一致。
- 图标容器、标题、副标题、控件之间的纵向间距必须校准到接近截图。

### Main Shell
- Toolbar 高度、图标按钮大小、左右留白应与原型一致。
- Sidebar 中搜索框、列表、分类、设置入口采用统一块面风格。
- Empty state 必须与原型一致，不要引入原生 macOS 风格空态。

### Detail
- 标题区要复现左 icon + 右 title/subtitle 结构。
- 字段区统一为可复用字段容器样式。
- copy / reveal 操作使用统一 icon button primitive。
- 元信息区采用块面化面板。

### Add Password Modal
- 使用自定义 overlay modal。
- Header 与表单布局对齐原型。
- 右对齐 label 的 form row 抽象为复用组件。

### Settings Modal
- 与 Add Modal 共用容器系统。
- 行项目、Section 标题、下拉选择视觉统一。

### Reset Password
- 作为设置 modal 内部子状态，而不是 `.sheet`。
- 保持相同 modal 外层，仅切换内部 content。
- 保证字段、按钮和标题区域与原型截图一致。

## 状态管理调整

### 当前问题
`SettingsViewNew` 使用 `showingResetSheet` 控制系统 sheet，不符合原型。

### 目标状态模型
建议将设置视图切换为显式内容状态，例如：
- `enum SettingsModalRoute { case general, resetPassword }`

`SettingsViewNew` 或其上层持有该状态，在同一 `PKModalContainer` 内切换 content，而不是创建第二层 modal。

## 文件组织建议

### 保留并改造
- `Sources/Views/Components/Theme.swift`
- `Sources/Views/Components/UIComponents.swift`
- `Sources/Views/Components/WindowComponents.swift`
- `Sources/Views/Components/UnlockView.swift`
- `Sources/Views/Components/SidebarView.swift`
- `Sources/Views/Components/MainContentView.swift`
- `Sources/Views/Components/PasswordDetailView.swift`
- `Sources/Views/Components/AddEditPasswordView.swift`
- `Sources/Views/Components/SettingsView.swift`

### 建议新增
- `Sources/Views/Components/ModalComponents.swift`
- `Sources/Views/Components/FormComponents.swift`
- `Sources/Views/Components/ToolbarComponents.swift`
- `Sources/Views/Components/SidebarComponents.swift`
- 如现有 `Theme.swift` 过重，可新增 `DesignTokens.swift`

## 实施顺序

1. 建立 tokens 与 primitive components
2. 重构 unlock screen
3. 重构 vault shell（toolbar / sidebar / empty state）
4. 重构 detail screen
5. 重构 add password modal
6. 重构 settings modal + reset password 子流程
7. 逐页校准 light/dark mode
8. 统一 hover / focus / selected / disabled / destructive 状态

## 验收标准

1. 与 `prototype-screenshots/` 逐页比对，结构、间距、颜色、圆角、层级达到高一致度。
2. 重置密码流程不再使用系统 `.sheet`。
3. 所有关键页面均在 light/dark 两种模式下可对齐原型。
4. 组件抽象清晰，可复用，避免在页面中重复硬编码样式。
5. 保持当前业务逻辑可用，不引入核心功能回归。
