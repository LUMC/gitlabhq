require 'spec_helper'
require_relative '../../config/initializers/6_validations.rb'

describe '6_validations', lib: true do
  before :all do
    FileUtils.mkdir_p('tmp/tests/paths/a/b/c/d')
    FileUtils.mkdir_p('tmp/tests/paths/a/b/c2')
    FileUtils.mkdir_p('tmp/tests/paths/a/b/d')
  end

  after :all do
    FileUtils.rm_rf('tmp/tests/paths')
  end

  context 'with correct settings' do
    before do
      mock_storages('foo' => { 'path' => 'tmp/tests/paths/a/b/c' }, 'bar' => { 'path' => 'tmp/tests/paths/a/b/d' })
    end

    it 'passes through' do
      expect { validate_storages }.not_to raise_error
    end
  end

  context 'with invalid storage names' do
    before do
      mock_storages('name with spaces' => { 'path' => 'tmp/tests/paths/a/b/c' })
    end

    it 'throws an error' do
      expect { validate_storages }.to raise_error('"name with spaces" is not a valid storage name. Please fix this in your gitlab.yml before starting GitLab.')
    end
  end

  context 'with nested storage paths' do
    before do
      mock_storages('foo' => { 'path' => 'tmp/tests/paths/a/b/c' }, 'bar' => { 'path' => 'tmp/tests/paths/a/b/c/d' })
    end

    it 'throws an error' do
      expect { validate_storages }.to raise_error('bar is a nested path of foo. Nested paths are not supported for repository storages. Please fix this in your gitlab.yml before starting GitLab.')
    end
  end

  context 'with similar but un-nested storage paths' do
    before do
      mock_storages('foo' => { 'path' => 'tmp/tests/paths/a/b/c' }, 'bar' => { 'path' => 'tmp/tests/paths/a/b/c2' })
    end

    it 'passes through' do
      expect { validate_storages }.not_to raise_error
    end
  end

  context 'with incomplete settings' do
    before do
      mock_storages('foo' => {})
    end

    it 'throws an error suggesting the user to update its settings' do
      expect { validate_storages }.to raise_error('foo is not a valid storage, because it has no `path` key. Refer to gitlab.yml.example for an updated example. Please fix this in your gitlab.yml before starting GitLab.')
    end
  end

  context 'with deprecated settings structure' do
    before do
      mock_storages('foo' => 'tmp/tests/paths/a/b/c')
    end

    it 'throws an error suggesting the user to update its settings' do
      expect { validate_storages }.to raise_error("foo is not a valid storage, because it has no `path` key. It may be configured as:\n\nfoo:\n  path: tmp/tests/paths/a/b/c\n\nRefer to gitlab.yml.example for an updated example. Please fix this in your gitlab.yml before starting GitLab.")
    end
  end

  def mock_storages(storages)
    allow(Gitlab.config.repositories).to receive(:storages).and_return(storages)
  end
end
