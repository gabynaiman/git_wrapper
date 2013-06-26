require 'time'

module DateHelper

  def yesterday
    Time.now - seconds_per_day
  end

  def tomorrow
    Time.now + seconds_per_day
  end

  def today
    Time.parse Time.now.strftime("%Y-%m-%d 00:00:00 -0300")
  end

  def now
    Time.now
  end

  def next_hour
    Time.now + seconds_per_hour
  end

  def next_month
    Time.now + seconds_per_month
  end

  def next_year
    Time.new + seconds_per_year
  end

  private

  def seconds_per_hour
    60 * 60
  end

  def seconds_per_day
    seconds_per_hour * 24
  end

  def seconds_per_month
    seconds_per_day * 31
  end

  def seconds_per_year
    seconds_per_day * 365
  end

end