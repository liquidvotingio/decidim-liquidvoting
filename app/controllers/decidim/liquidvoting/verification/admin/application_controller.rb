# frozen_string_literal: true

module Decidim
  module ActionDelegator
    module Verification
      module Admin
        # This controller is the abstract class from which all other controllers of
        # this engine inherit.
        #
        class ApplicationController < Decidim::Admin::ApplicationController
        end
      end
    end
  end
end
