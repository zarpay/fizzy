module StorageTracking
  extend ActiveSupport::Concern

  included do
    after_save :track_storage_updated
    after_destroy :track_storage_removed
  end

  def bytes_used
    rich_text_associations.sum { |association| send(association.name).bytes_used }
  end

  private
    def track_storage_updated
      adjust_storage_later(calculate_changed_storage_delta)
    end

    def calculate_changed_storage_delta
      rich_text_associations.sum do |association|
        rich_text = send(association.name)
        next 0 unless rich_text&.body_previously_changed?

        rich_text.bytes_used - rich_text.body_previously_was&.bytes_used.to_i
      end
    end

    def track_storage_removed
      adjust_storage_later(-bytes_used)
    end

    def adjust_storage_later(delta)
      account.adjust_storage_later(delta)
    end

    def rich_text_associations
      self.class.reflect_on_all_associations(:has_one).filter { |association| association.klass == ActionText::RichText }
    end
end
