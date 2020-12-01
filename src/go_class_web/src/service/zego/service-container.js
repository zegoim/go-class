import { WebLiveInterface } from "@/service/zego/interface/live";

const WhiteboardRepositoryInterface = {
  on () {},
  loginRoom () {},
}

const DocsRepositoryInterface = {
  on () {},
  loginRoom () {},
}

function bind (repositoryFactory, Interface) {
  return {
    ...Object.keys(Interface).reduce((prev, method) => {
      const resolvableMethod = async (...args) => {
        const repository = await repositoryFactory()
        return repository.default[method](...args)
      }
      return { ...prev, [method]: resolvableMethod }
    }, {})
  }
}

export default {
  get LiveRepository () {
    return bind(() => import('./repository/live.js'), WebLiveInterface)
  },
  get WhiteboardRepository () {
    return bind(() => import('./repository/whiteboard.js'), WhiteboardRepositoryInterface)
  },
  get DocsRepositoryInterface () {
    return bind(() => import('./repository/docs.js'), DocsRepositoryInterface)
  }
}
