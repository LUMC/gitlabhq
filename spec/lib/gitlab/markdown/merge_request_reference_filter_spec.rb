require 'spec_helper'

module Gitlab::Markdown
  describe MergeRequestReferenceFilter do
    include ReferenceFilterSpecHelper

    let(:project) { create(:project) }
    let(:merge)   { create(:merge_request, source_project: project) }

    it 'requires project context' do
      expect { described_class.call('MergeRequest !123', {}) }.
        to raise_error(ArgumentError, /:project/)
    end

    %w(pre code a style).each do |elem|
      it "ignores valid references contained inside '#{elem}' element" do
        exp = act = "<#{elem}>Merge !#{merge.iid}</#{elem}>"
        expect(filter(act).to_html).to eq exp
      end
    end

    context 'internal reference' do
      let(:reference) { "!#{merge.iid}" }

      it 'links to a valid reference' do
        doc = filter("See #{reference}")

        expect(doc.css('a').first.attr('href')).to eq urls.
          namespace_project_merge_request_url(project.namespace, project, merge)
      end

      it 'links with adjacent text' do
        doc = filter("Merge (#{reference}.)")
        expect(doc.to_html).to match(/\(<a.+>#{Regexp.escape(reference)}<\/a>\.\)/)
      end

      it 'ignores invalid merge IDs' do
        exp = act = "Merge !#{merge.iid + 1}"

        expect(filter(act).to_html).to eq exp
      end

      it 'includes a title attribute' do
        doc = filter("Merge #{reference}")
        expect(doc.css('a').first.attr('title')).to eq "Merge Request: #{merge.title}"
      end

      it 'includes default classes' do
        doc = filter("Merge #{reference}")
        expect(doc.css('a').first.attr('class')).to eq 'gfm gfm-merge_request'
      end

      it 'includes an optional custom class' do
        doc = filter("Merge #{reference}", reference_class: 'custom')
        expect(doc.css('a').first.attr('class')).to include 'custom'
      end

      it 'supports an :only_path context' do
        doc = filter("Merge #{reference}", only_path: true)
        link = doc.css('a').first.attr('href')

        expect(link).not_to match %r(https?://)
        expect(link).to eq urls.namespace_project_merge_request_url(project.namespace, project, merge, only_path: true)
      end
    end

    context 'cross-project reference' do
      let(:namespace) { create(:namespace, name: 'cross-reference') }
      let(:project2)  { create(:project, namespace: namespace) }
      let(:merge)     { create(:merge_request, source_project: project2) }
      let(:reference) { "#{project2.path_with_namespace}!#{merge.iid}" }

      before do
        allow_any_instance_of(described_class).
          to receive(:user_can_reference_project?).and_return(true)
      end

      it 'links to a valid reference' do
        doc = filter("See #{reference}")

        expect(doc.css('a').first.attr('href')).
          to eq urls.namespace_project_merge_request_url(project2.namespace,
                                                         project, merge)
      end

      it 'links with adjacent text' do
        doc = filter("Merge (#{reference}.)")
        expect(doc.to_html).to match(/\(<a.+>#{Regexp.escape(reference)}<\/a>\.\)/)
      end

      it 'ignores invalid merge IDs on the referenced project' do
        exp = act = "Merge #{project2.path_with_namespace}!#{merge.iid + 1}"

        expect(filter(act).to_html).to eq exp
      end
    end
  end
end
