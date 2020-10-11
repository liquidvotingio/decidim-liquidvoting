# frozen_string_literal: true

module Decidim
  module ActionDelegator
    # This controller handles user profile actions for this module
    class UserDelegationsController < ActionDelegator::ApplicationController
      include Decidim::UserProfile

      def index
        enforce_permission_to :read, :user, current_user: current_user
      end
    end
  end
end
