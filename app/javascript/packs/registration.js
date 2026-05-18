import Vue from 'vue'
import Registration from '../components/Registration.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    render: h => h(Registration)
  }).$mount('#app')
})
