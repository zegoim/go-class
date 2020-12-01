import { isElectron } from '@/utils/tool'
import webZegoClient from './web'
import electronZegoClient from './electron'

export default isElectron ? electronZegoClient : webZegoClient
