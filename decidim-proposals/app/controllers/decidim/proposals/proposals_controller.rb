# frozen_string_literal: true

module Decidim
  module Proposals
    # Exposes the proposal resource so users can view and create them.
    class ProposalsController < Decidim::Proposals::ApplicationController
      helper Decidim::WidgetUrlsHelper
      include FormFactory
      include FilterResource
      include Orderable
      include Paginable

      helper_method :geocoded_proposals
      before_action :authenticate_user!, only: [:new, :create]

      def index
        @proposals = search
                      .results
                      .not_hidden
                      .authorized
                      .includes(:author)
                      .includes(:category)
                      .includes(:scope)


        @voted_proposals = if current_user
                             ProposalVote.where(
                               author: current_user,
                               proposal: @proposals.pluck(:id)
                             ).pluck(:decidim_proposal_id)
                           else
                             []
                           end

        @proposals = paginate(@proposals)
        @proposals = reorder(@proposals)
      end

      def show
        @proposal = Proposal
                    .not_hidden
                    .where(feature: current_feature)
                    .find(params[:id])
        @report_form = form(Decidim::ReportForm).from_params(reason: "spam")
      end

      def new
        authorize! :create, Proposal

        @form = form(ProposalForm).from_params(
          attachment: form(AttachmentForm).from_params({})
        )
      end

      def create
        authorize! :create, Proposal

        @form = form(ProposalForm).from_params(params)

        CreateProposal.call(@form, current_user) do
          on(:ok) do |proposal|
            flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")
            redirect_to proposal_path(proposal)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
            render :new
          end
        end
      end

      private

      def get_user_with_process_role(participatory_process_id)
        Decidim::ParticipatoryProcessUserRole.where(decidim_participatory_process_id: participatory_process_id).map(&:user)
      end


      def admin_or_moderator?
        current_user && (current_user.admin? ||
          current_organization.users_with_any_role.include?(current_user) ||
          get_user_with_process_role(current_participatory_process.id).include?(current_user)
        )
      end

      def geocoded_proposals
        @geocoded_proposals ||= search.results.not_hidden.select(&:geocoded?)
      end

      def search_klass
        ProposalSearch
      end

      def default_filter_params
        {
          search_text: "",
          origin: "all",
          activity: "",
          category_id: "",
          state: "all",
          scope_id: nil,
          related_to: ""
        }
      end
    end
  end
end
