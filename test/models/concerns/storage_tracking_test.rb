require "test_helper"

class StorageTrackingTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:david)
    @account = Current.account
    @board = boards(:writebook)
  end

  test "tracks storage when creating card with rich text attachment" do
    assert_difference -> { @account.reload.bytes_used }, active_storage_blobs(:hello_txt).byte_size do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        @board.cards.create!(title: "Test", description: attachment_html(active_storage_blobs(:hello_txt)), status: :published)
      end
    end
  end

  test "tracks storage delta when updating card with different attachment" do
    card = perform_enqueued_jobs only: Account::AdjustStorageJob do
      @board.cards.create!(title: "Test", description: attachment_html(active_storage_blobs(:hello_txt)), status: :published)
    end

    expected_delta = active_storage_blobs(:list_pdf).byte_size - active_storage_blobs(:hello_txt).byte_size
    assert_difference -> { @account.reload.bytes_used }, expected_delta do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        card.update!(description: attachment_html(active_storage_blobs(:list_pdf)))
      end
    end
  end

  test "tracks negative delta when removing attachment from card" do
    card = perform_enqueued_jobs only: Account::AdjustStorageJob do
      @board.cards.create!(title: "Test", description: attachment_html(active_storage_blobs(:hello_txt)), status: :published)
    end

    assert_difference -> { @account.reload.bytes_used }, -active_storage_blobs(:hello_txt).byte_size do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        card.update!(description: "No attachments")
      end
    end
  end

  test "tracks negative storage when destroying card with attachment" do
    card = perform_enqueued_jobs only: Account::AdjustStorageJob do
      @board.cards.create!(title: "Test", description: attachment_html(active_storage_blobs(:hello_txt)), status: :published)
    end

    assert_difference -> { @account.reload.bytes_used }, -active_storage_blobs(:hello_txt).byte_size do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        card.destroy!
      end
    end
  end

  test "does not change storage when no attachments change" do
    assert_no_difference -> { @account.reload.bytes_used } do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        @board.cards.create!(title: "Test", description: "Plain text", status: :published)
      end
    end
  end

  test "does not change storage when updating title on card with attachment" do
    card = perform_enqueued_jobs only: Account::AdjustStorageJob do
      @board.cards.create!(title: "Test", description: attachment_html(active_storage_blobs(:hello_txt)), status: :published)
    end

    assert_no_difference -> { @account.reload.bytes_used } do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        card.update!(title: "New title")
      end
    end
  end

  test "does not change storage when updating description text but keeping same attachment" do
    card = perform_enqueued_jobs only: Account::AdjustStorageJob do
      @board.cards.create!(title: "Test", description: "Some text #{attachment_html(active_storage_blobs(:hello_txt))}", status: :published)
    end

    assert_no_difference -> { @account.reload.bytes_used } do
      perform_enqueued_jobs only: Account::AdjustStorageJob do
        card.update!(description: "Different text #{attachment_html(active_storage_blobs(:hello_txt))}")
      end
    end
  end

  private
    def attachment_html(blob)
      ActionText::Attachment.from_attachable(blob).to_html
    end
end
