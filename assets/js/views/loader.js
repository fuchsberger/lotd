import MainView from './main'

export default function loadView(viewPath) {
  let view

  try {
    const ViewClass = require('./' + viewPath)
    view = new ViewClass.default
  } catch (e) {
    view = new MainView
  }

  return view
}
