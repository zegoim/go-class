import { isElectron } from '@/utils/tool'
import { WebLiveHelper } from './web'
import { ElectronLiveHelper } from './electron'

export const LiveHelper = isElectron ? ElectronLiveHelper : WebLiveHelper
