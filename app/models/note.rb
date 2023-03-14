class Note < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  has_many :reminders, dependent: :destroy
  has_many :sentences, dependent: :destroy
  has_one_attached :audio

  validates :text, :audio, presence: true
end
