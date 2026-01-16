class Account::DataTransfer::Manifest
  Cursor = Struct.new(:record_class, :last_id)

  include Enumerable

  RECORD_SETS = [
    Account::DataTransfer::AccountRecordSet,
    Account::DataTransfer::UserRecordSet,
    Account::DataTransfer::TagRecordSet,
    Account::DataTransfer::BoardRecordSet,
    Account::DataTransfer::ColumnRecordSet,
    Account::DataTransfer::EntropyRecordSet,
    Account::DataTransfer::BoardPublicationRecordSet,
    Account::DataTransfer::WebhookRecordSet,
    Account::DataTransfer::AccessRecordSet,
    Account::DataTransfer::CardRecordSet,
    Account::DataTransfer::CommentRecordSet,
    Account::DataTransfer::StepRecordSet,
    Account::DataTransfer::AssignmentRecordSet,
    Account::DataTransfer::TaggingRecordSet,
    Account::DataTransfer::ClosureRecordSet,
    Account::DataTransfer::CardGoldnessRecordSet,
    Account::DataTransfer::CardNotNowRecordSet,
    Account::DataTransfer::CardActivitySpikeRecordSet,
    Account::DataTransfer::WatchRecordSet,
    Account::DataTransfer::PinRecordSet,
    Account::DataTransfer::ReactionRecordSet,
    Account::DataTransfer::MentionRecordSet,
    Account::DataTransfer::FilterRecordSet,
    Account::DataTransfer::WebhookDelinquencyTrackerRecordSet,
    Account::DataTransfer::EventRecordSet,
    Account::DataTransfer::NotificationRecordSet,
    Account::DataTransfer::NotificationBundleRecordSet,
    Account::DataTransfer::WebhookDeliveryRecordSet,
    Account::DataTransfer::ActiveStorageBlobRecordSet,
    Account::DataTransfer::ActiveStorageAttachmentRecordSet,
    Account::DataTransfer::ActionTextRichTextRecordSet,
    Account::DataTransfer::BlobFileRecordSet
  ]

  attr_reader :account

  def initialize(account)
    @account = account
  end

  def each_record_set(start: nil)
    raise ArgumentError, "No block given" unless block_given?

    RECORD_SETS.each do |record_set_class|
      yield record_set_class.new(account)
    end
  end
end
