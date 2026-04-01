## Why

当前详情页 `PasswordDetailView` 只能查看密码信息，用户无法直接编辑已保存的密码条目中的详细信息（如用户名、密码、备注等）。同时，添加密码页面的分类选择器宽度与输入区域不一致，影响用户体验。此外，编辑功能的 UI 需要进一步优化以符合现有设计规范。

## What Changes

1. **详情页编辑功能**：在密码详情页添加内联编辑模式，支持直接编辑标题、用户名、密码、备注、分类等所有字段，保存后更新到数据库（不跳转到添加页面）
2. **分类选择器宽度适配**：修复添加密码页面中分类选择器的宽度，使用 `.pickerStyle(.menu)` 使其与上方输入区域（标题、用户名、密码）宽度保持一致
3. **UI 优化**：
   - 编辑按钮多语言支持
   - 密码显示宽度撑满容器
   - 非编辑态显示分类信息
   - 编辑模式输入区域垂直间距优化
   - 编辑模式隐藏删除按钮
   - 编辑模式 UI 对齐查看态效果

## Capabilities

### New Capabilities
- `password-detail-edit`: 支持在密码详情页直接编辑字段

### Modified Capabilities
- 无（现有密码管理功能的行为不变，仅优化 UI）

## Impact

- 修改 `Sources/Views/PasswordDetailView.swift` - 添加编辑 UI 和逻辑
- 修改 `Sources/Views/AddEditPasswordView.swift` - 修复分类选择器宽度
- 修改 `Sources/Views/MainView.swift` - 添加 onSave 回调
- 修改 `Resources/en.lproj/Localizable.strings` - 添加编辑按钮多语言
- 修改 `Resources/zh-Hans.lproj/Localizable.strings` - 添加编辑按钮多语言