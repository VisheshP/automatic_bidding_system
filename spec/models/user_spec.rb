require "rails_helper"

RSpec.describe User, type: :model do
  subject do
    build(
      :user,
      full_name: "Vishesh Purohit",
      email: "TEST@EMAIL.COM",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  # -----------------------------
  # Associations
  # -----------------------------
  describe "associations" do
    it { is_expected.to have_many(:items) }
    it { is_expected.to have_many(:bids).dependent(:destroy) }
  end

  # -----------------------------
  # Validations
  # -----------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }

    it do
      expect(subject).to validate_length_of(:full_name)
        .is_at_least(1)
        .is_at_most(40)
    end

    it do
      expect(subject).to allow_value("Vishesh Purohit").for(:full_name)
      expect(subject).not_to allow_value("Vishesh123").for(:full_name)
    end

    it do
      expect(subject).to validate_uniqueness_of(:email)
    end

    it do
      expect(subject).to allow_value("test@example.com").for(:email)
      expect(subject).not_to allow_value("invalid-email").for(:email)
    end

    it do
      expect(subject).to validate_length_of(:password)
        .is_at_least(6)
        .is_at_most(20)
    end
  end

  # -----------------------------
  # Enums
  # -----------------------------
  describe "enums" do
    it do
      expect(subject).to define_enum_for(:role)
        .with_values(buyer: 0, seller: 1)
    end
  end

  # -----------------------------
  # Secure Password
  # -----------------------------
  describe "has_secure_password" do
    it "authenticates with valid password" do
      user = create(
        :user,
        password: "password123",
        password_confirmation: "password123"
      )

      expect(user.authenticate("password123")).to be_truthy
    end

    it "does not authenticate with invalid password" do
      user = create(:user, password: "password123")

      expect(user.authenticate("wrongpass")).to be_falsey
    end
  end

  # -----------------------------
  # Callbacks
  # -----------------------------
  describe "callbacks" do
    it "downcases email before save" do
      subject.save!
      expect(subject.email).to eq("test@email.com")
    end

    it "capitalizes full_name before save" do
      subject.save!
      expect(subject.full_name).to eq("Vishesh purohit")
    end
  end

  # -----------------------------
  # Class Methods
  # -----------------------------
  describe ".digest" do
    it "returns a BCrypt password hash" do
      digest = described_class.digest("password123")
      expect(BCrypt::Password.new(digest)).to eq("password123")
    end
  end
end
