class Account::DataTransfer::RecordSet
  class IntegrityError < StandardError; end

  IMPORT_BATCH_SIZE = 100

  attr_reader :account

  def initialize(account)
    @account = account
  end

  def export(to:, start: nil)
    with_zip(to) do
      block = lambda do |record|
        export_record(record)
      end

      records.respond_to?(:find_each) ? records.find_each(&block) : records.each(&block)
    end
  end

  def import(from:, start: nil, callback: nil)
    with_zip(from) do
      files.each_slice(IMPORT_BATCH_SIZE) do |file_batch|
        import_batch(file_batch)
        callback&.call(record_set: self, files: file_batch)
      end
    end
  end

  def validate(from:, start: nil, callback: nil)
    with_zip(from) do
      files.each do |file_path|
        validate_record(file_path)
        callback&.call(record_set: self, file: file_path)
      end
    end
  end

  private
    attr_reader :zip

    def with_zip(zip)
      old_zip = @zip
      @zip = zip
      yield
    ensure
      @zip = old_zip
    end

    def records
      []
    end

    def export_record(record)
      raise NotImplementedError
    end

    def files
      []
    end

    def import_batch(files)
      raise NotImplementedError
    end

    def validate_record(file_path)
      raise NotImplementedError
    end

    def load(file_path)
      JSON.parse(zip.read(file_path))
    rescue ArgumentError => e
      raise IntegrityError, e.message
    end
end
