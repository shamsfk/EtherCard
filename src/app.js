import Vue from 'vue'

const app = new Vue({
  data: {
    message: 'Ethereum Gift Cards'
  },
  template: '<div id="app"><h1>EtherCard</h1>{{ message }}</div>'
})

export { app }
