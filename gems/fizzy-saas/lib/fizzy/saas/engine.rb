module Fizzy
  module Saas
    class Engine < ::Rails::Engine
      isolate_namespace Fizzy::Saas
    end
  end
end
