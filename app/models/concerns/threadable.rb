module Threadable
  extend ActiveSupport::Concern

  included do
    has_one :thread_entry, as: :threadable
  end
end
