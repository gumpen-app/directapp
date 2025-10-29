import { definePanel } from '@directus/extensions-sdk';
import PanelComponent from './panel.vue';

export default definePanel({
  id: 'key-tag-scanner',
  name: 'Key Tag Scanner',
  icon: 'qr_code_scanner',
  description: 'Scan key tags to quickly register vehicle arrivals',
  component: PanelComponent,
  options: [
    {
      field: 'title',
      name: 'Title',
      type: 'string',
      meta: {
        interface: 'input',
        width: 'full',
        options: {
          placeholder: 'Key Tag Scanner',
        },
      },
      schema: {
        default_value: 'Key Tag Scanner',
      },
    },
    {
      field: 'auto_redirect',
      name: 'Auto-Redirect to Car',
      type: 'boolean',
      meta: {
        interface: 'boolean',
        width: 'half',
        note: 'Automatically redirect to car form after successful scan',
      },
      schema: {
        default_value: true,
      },
    },
  ],
  minWidth: 12,
  minHeight: 12,
});
