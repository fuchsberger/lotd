import MainView from '../main'

export default class View extends MainView {
  mount() {
    super.mount()
    console.log('PageIndex mounted')
  }

  unmount() {
    console.log('PageIndex unmounted')
    super.unmount()
  }
}
