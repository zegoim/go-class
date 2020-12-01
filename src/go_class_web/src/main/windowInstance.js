class WinsClient {

  constructor() {
    this.wins  = new Map()
    this.opens = new Map()
  }

  setInstance (key, ins) {
    this.wins.set(key, ins)
  }

  getInstance (...args) {
    return [].concat(args.map(key => this.wins.get(key)))
  }

  getAllInstance () {
    const all = {}
    this.wins.forEach((value, key) => {
      all[key] = value
    })
    return all
  }
}

const wins = {
  login: null
}

const winClient = new WinsClient()

export {
  wins,
  winClient
}
