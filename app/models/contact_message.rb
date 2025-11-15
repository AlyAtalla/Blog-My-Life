class ContactMessage < ApplicationRecord
  validates :name, :email, :message, presence: true
end
