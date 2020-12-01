import { Menu, MenuItem } from 'electron'

export function setDefaultApplicationMenu () {
  Menu.setApplicationMenu(null)
}

export function handleContextMenu (event, props) {
  if (!props.selectionText && !props.isEditable) return
  const contextMenu = new Menu()
  if (props.selectionText) {
    contextMenu.append(new MenuItem({
      role: 'copy',
      label: '复制'
    }))
    if (props.isEditable) {
      contextMenu.append(new MenuItem({
        role: 'cut',
        label: '剪切'
      }))
    }
  }
  if (props.isEditable) {
    contextMenu.append(new MenuItem({
      role: 'paste',
      label: '粘贴'
    }))
    if (props.editFlags.canSelectAll) {
      contextMenu.append(new MenuItem({
        role: 'selectall',
        label: '全选'
      }))
    }
    if (props.editFlags.canUndo) {
      contextMenu.append(new MenuItem({
        type: 'separator'
      }))
      contextMenu.append(new MenuItem({
        role: 'undo',
        label: '撤销'
      }))
    }
    if (props.editFlags.canRedo) {
      contextMenu.append(new MenuItem({
        role: 'redo',
        label: '重做'
      }))
    }
  }
  contextMenu.popup()
}
