module DateHelper

  def yesterday
    (Time.new - seconds_per_day).strftime("%Y-%m-%d")
  end

  def tomorrow
    (Time.new + seconds_per_day).strftime("%Y-%m-%d")
  end

  private

  def seconds_per_day
    60 * 60 * 24
  end

end