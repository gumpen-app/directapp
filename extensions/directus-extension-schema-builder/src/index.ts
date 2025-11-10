import { defineModule } from '@directus/extensions-sdk';
import ModuleComponent from './module.vue';

export default defineModule({
  id: 'schema-builder',
  name: 'Schema Builder',
  icon: 'architecture',
  routes: [
    {
      path: '',
      component: ModuleComponent,
    },
  ],
});
