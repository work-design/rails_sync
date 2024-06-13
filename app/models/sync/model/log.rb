# frozen_string_literal: true
module Sync
  module Model::Log
    extend ActiveSupport::Concern

    included do
      attribute :exception, :string
      attribute :exception_backtrace, :string, array: true, default: []

      belongs_to :item, counter_cache: true
      belongs_to :related, polymorphic: true, optional: true
    end

  end
end

