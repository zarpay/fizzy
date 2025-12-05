require "test_helper"

class Account::StorageTrackingTest < ActiveSupport::TestCase
  setup do
    @account = Current.account
    @account.update!(bytes_used: 0)
  end

  test "track storage deltas" do
    @account.adjust_storage(1000)
    assert_equal 1000, @account.reload.bytes_used

    @account.adjust_storage(-100)
    assert_equal 900, @account.reload.bytes_used
  end

  test "track storage deltas in jobs" do
    assert_enqueued_with(job: Account::AdjustStorageJob, args: [ @account, 1000 ]) do
      @account.adjust_storage_later(1000)
    end

    assert_no_enqueued_jobs only: Account::AdjustStorageJob do
      @account.adjust_storage_later(0)
    end
  end
end
