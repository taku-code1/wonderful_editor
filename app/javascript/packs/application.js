require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import Vue from 'vue/dist/vue.esm'
import App from '../app.vue'
import vuetify from '../plugins/vuetify'

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    vuetify,
    render: h => h(App)
  }).$mount('#app')
})
