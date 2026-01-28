class Schedule < ApplicationRecord
  belongs_to :broadcast
  has_one_attached :video

  validates :start_date, :end_date, :video, presence: true

  scope :active_now, ->(now) { where("start_date <= ? AND end_date >= ?", now, now) }
end
