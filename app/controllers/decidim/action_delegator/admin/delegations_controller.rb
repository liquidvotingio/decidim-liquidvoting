# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Admin
      class DelegationsController < ActionDelegator::Admin::ApplicationController
        include NeedsPermission
        include Filterable

        helper DelegationHelper
        helper_method :current_setting

        layout "decidim/admin/users"

        def index
          enforce_permission_to :index, :delegation

          delegations = filtered_collection.map do |delegation|
            DelegationPresenter.new(delegation)
          end

          render :index, locals: { delegations: delegations }
        end

        def new
          @delegation = Delegation.new
        end

        def create
          enforce_permission_to :create, :delegation

          @delegation = build_delegation

          if @delegation.save
            notice = I18n.t("delegations.create.success", scope: "decidim.action_delegator.admin")
            redirect_to setting_delegations_path(@delegation.setting), notice: notice
          else
            error = I18n.t("delegations.create.error", scope: "decidim.action_delegator.admin")
            redirect_to delegations_path, flash: { error: error }
          end
        end

        def destroy
          enforce_permission_to :destroy, :delegation

          if delegation.destroy
            notice = I18n.t("delegations.destroy.success", scope: "decidim.action_delegator.admin")
            redirect_to delegations_path, notice: notice
          else
            error = I18n.t("delegations.destroy.error", scope: "decidim.action_delegator.admin")
            redirect_to delegations_path, flash: { error: error }
          end
        end

        private

        def build_delegation
          Delegation.new(delegation_params)
        end

        def delegation_params
          params.require(:delegation).permit(:granter_id, :grantee_id, :decidim_action_delegator_setting_id)
        end

        def collection
          @collection ||= OrganizationDelegations.new(current_organization).query
        end

        def delegation
          Delegation.find_by(id: params[:id])
        end

        def current_setting
          @current_setting ||= Setting.find_by(id: params[:setting_id])
        end
      end
    end
  end
end
