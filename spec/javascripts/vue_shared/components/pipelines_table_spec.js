require('~/lib/utils/datetime_utility');
const Vue = require('vue');
const pipeline = require('../../commit/pipelines/mock_data');
const PipelinesTable = require('~/vue_shared/components/pipelines_table');

const PipelinesTableComponent = Vue.extend(PipelinesTable);

describe('Pipelines Table', () => {
  preloadFixtures('static/environments/element.html.raw');

  beforeEach(() => {
    loadFixtures('static/environments/element.html.raw');
  });

  describe('table', () => {
    let component;
    beforeEach(() => {
      component = new PipelinesTableComponent({
        el: document.querySelector('.test-dom-element'),
        propsData: {
          pipelines: [],
          svgs: {},
        },
      });
    });

    afterEach(() => {
      component.$destroy();
    });

    it('should render a table', () => {
      expect(component.$el).toEqual('TABLE');
    });

    it('should render table head with correct columns', () => {
      expect(component.$el.querySelector('th.js-pipeline-status').textContent).toEqual('Status');
      expect(component.$el.querySelector('th.js-pipeline-info').textContent).toEqual('Pipeline');
      expect(component.$el.querySelector('th.js-pipeline-commit').textContent).toEqual('Commit');
      expect(component.$el.querySelector('th.js-pipeline-stages').textContent).toEqual('Stages');
      expect(component.$el.querySelector('th.js-pipeline-date').textContent).toEqual('');
      expect(component.$el.querySelector('th.js-pipeline-actions').textContent).toEqual('');
    });
  });

  describe('without data', () => {
    it('should render an empty table', () => {
      const component = new PipelinesTableComponent({
        el: document.querySelector('.test-dom-element'),
        propsData: {
          pipelines: [],
          svgs: {},
        },
      });
      expect(component.$el.querySelectorAll('tbody tr').length).toEqual(0);
    });
  });

  describe('with data', () => {
    it('should render rows', () => {
      const component = new PipelinesTableComponent({
        el: document.querySelector('.test-dom-element'),
        propsData: {
          pipelines: [pipeline],
          svgs: {},
        },
      });

      expect(component.$el.querySelectorAll('tbody tr').length).toEqual(1);
    });
  });
});
