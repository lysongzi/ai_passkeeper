## Why

当前应用的 UI 设计与现代 macOS 应用标准存在差距，用户体验不够一致。需要基于 RedesignUI 原型工程对现有 UI 进行全面升级，同时保持现有功能完整性，并避免之前发现的 UI bug 重复出现。

## What Changes

1. **整体 UI 风格重塑**：采用原型工程的 shadcn/ui 风格设计语言
2. **解锁页面重构**：使用新的渐变图标和圆角输入框设计
3. **侧边栏重构**：优化分类展示和密码列表样式
4. **详情页重构**：统一卡片样式、间距和交互元素
5. **添加密码弹窗重构**：采用新的弹窗布局和输入框样式
6. **设置页面重构**：统一设置项的展示样式
7. **暗色/亮色模式优化**：完善主题切换功能
8. **多语言文案优化**：根据原型工程更新为更友好的文案

## Capabilities

### New Capabilities
- `ui-redesign-unlock`: 解锁页面全新设计
- `ui-redesign-main`: 主界面（侧边栏+内容区）全新设计
- `ui-redesign-detail`: 密码详情页全新设计
- `ui-redesign-add-password`: 添加密码弹窗全新设计
- `ui-redesign-settings`: 设置页面全新设计

### Modified Capabilities
- `password-detail-edit`: 现有编辑功能保持不变，仅调整 UI 样式

## Impact

- 修改 `Sources/Views/` 目录下的所有视图文件
- 可能需要新增 UI 组件或调整现有组件
- 更新 `Resources/` 目录下的本地化字符串
- 保持 `Sources/Services/` 和 `Sources/ViewModels/` 业务逻辑不变