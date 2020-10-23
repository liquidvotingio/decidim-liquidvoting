# frozen_string_literal: true

module Decidim
  module Liquidvoting 
    class DelegationsController < Decidim::Liquidvoting::ApplicationController
      before_action :authenticate_user!

      def create
        Decidim::Liquidvoting::Client.create_delegation(
          proposal_url: params[:proposal_url],
          delegator_email: params[:delegator_email],
          delegate_email: params[:delegate_email]
        )

        
        session[:delegated_to] = params[:delegate_email]
        flash[:notice] = "Delegated support to #{session[:delegated_to]}"
      rescue Exception => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end

      def index
        respond_to do |format|
          format.html { render html: "<p>placeholder module homepage</p>".html_safe }
        end
      end

      def destroy
        Decidim::Liquidvoting::Client.delete_delegation(
          proposal_url: params[:proposal_url],
          delegator_email: params[:delegator_email],
          delegate_email: session[:delegated_to]
        )

        flash[:notice] = "Removed delegation to #{session[:delegated_to]}"
        session[:delegated_to] = nil
      rescue Exception => e
        flash[:error] = e.message
      ensure
        redirect_to request.referer
      end

      def current_component
        Decidim::Component.where(manifest_name: "liquidvoting").first
      end

      def permission_class_chain
        [
          Decidim::Liquidvoting::Permissions
        ]
      end
    end
  end
end