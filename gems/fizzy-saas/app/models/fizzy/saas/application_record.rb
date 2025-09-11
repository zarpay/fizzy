module Fizzy
  module Saas
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
