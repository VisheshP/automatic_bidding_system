class User < ApplicationRecord
  has_secure_password
  has_many :items
  has_many :bids, dependent: :destroy

  validates :full_name, :email, presence: true

  validates :full_name, format: { with: /\A[a-zA-Z ]+\z/, message: "only allows letters" }, length: { in: 1..40 }

  validates :email, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  before_save :format_data

  validates :password, presence: true, length: { in: 6..20 }, allow_nil: true

  enum :role, { buyer: 0, seller: 1 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  

  def format_data
    self.email = self.email.downcase
    self.full_name = self.full_name.capitalize
  end
end