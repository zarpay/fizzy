class Bubble::Thread
  def initialize(bubble)
    @bubble = bubble
  end

  def entries
    @entries ||= bubble.thread_entries
  end

  def latest_rollup
    if entries.last&.rollup?
      entries.last.rollup
    else
      Rollup.new
    end
  end

  private
    attr_reader :bubble
end
