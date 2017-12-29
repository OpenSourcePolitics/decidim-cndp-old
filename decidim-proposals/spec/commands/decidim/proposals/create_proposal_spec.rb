# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe CreateProposal do
      describe "call" do
        let(:form_klass) { ProposalForm }
        it_behaves_like "create a proposal", true
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: organization) }
        let(:feature) { create :feature, manifest_name: :proposals, participatory_space: participatory_process }
        let(:author) { create(:user, organization: organization) }
        let(:admin) {create(:user, :admin, organization: organization)}
        let(:process_admin) {create(:user, :process_admin, organization: feature.organization, participatory_process: feature.participatory_space)}
        let(:user_manager) {create(:user, :user_manager, organization: feature.organization)}

        let(:body) { ::Faker::Lorem.sentences(3).join("\n") }
        let(:title) { ::Faker::Lorem.sentence(3) }
        let(:form_params) do
          {
            "proposal" => {
              "body" => body,
              "title" => title,
            }
          }
        end

        let(:form) do
          ProposalForm.from_params(
            form_params
          )
        end
        let(:command) { described_class.new(form, author) }

        it "creates a new proposal" do
          expect(Proposal).to receive(:create!).with(
            author: author,
            body: body,
            title: title
          ).and_call_original

          expect do
            command.call
          end.to change { Proposal.count }.by(1)
        end
      end
    end
  end
end
