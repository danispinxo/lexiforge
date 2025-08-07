require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      user = build(:user)
      expect(user).to be_valid
    end

    it 'is not valid without an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is not valid with an invalid email format' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'is not valid with a duplicate email' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is not valid without a password' do
      user = build(:user, password: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is not valid with a password shorter than 6 characters' do
      user = build(:user, password: '12345')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'is not valid without password confirmation' do
      user = build(:user, password: 'password123', password_confirmation: nil)
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end

    it 'is not valid with mismatched password confirmation' do
      user = build(:user, password: 'password123', password_confirmation: 'different123')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    it 'can authenticate with valid credentials' do
      expect(user.valid_password?('password123')).to be true
    end

    it 'cannot authenticate with invalid password' do
      expect(user.valid_password?('wrongpassword')).to be false
    end

    it 'encrypts the password' do
      expect(user.encrypted_password).not_to eq('password123')
      expect(user.encrypted_password).to be_present
    end
  end

  describe 'Devise modules' do
    it 'includes trackable module' do
      expect(User.devise_modules).to include(:trackable)
    end

    it 'includes database_authenticatable module' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes validatable module' do
      expect(User.devise_modules).to include(:validatable)
    end

    it 'includes registerable module' do
      expect(User.devise_modules).to include(:registerable)
    end
  end

  describe 'trackable fields' do
    let(:user) { create(:user) }

    it 'has trackable attributes' do
      expect(user).to respond_to(:sign_in_count)
      expect(user).to respond_to(:current_sign_in_at)
      expect(user).to respond_to(:last_sign_in_at)
      expect(user).to respond_to(:current_sign_in_ip)
      expect(user).to respond_to(:last_sign_in_ip)
    end

    it 'initializes trackable fields with default values' do
      expect(user.sign_in_count).to eq(0)
      expect(user.current_sign_in_at).to be_nil
      expect(user.last_sign_in_at).to be_nil
      expect(user.current_sign_in_ip).to be_nil
      expect(user.last_sign_in_ip).to be_nil
    end
  end

  describe 'factory' do
    it 'creates a valid user with factory' do
      user = create(:user)
      expect(user).to be_valid
      expect(user.email).to be_present
      expect(user.encrypted_password).to be_present
    end
  end

  describe 'email uniqueness' do
    it 'enforces case-insensitive email uniqueness' do
      create(:user, email: 'test@example.com')
      user = build(:user, email: 'TEST@EXAMPLE.COM')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'password validation' do
    it 'requires password on creation' do
      user = User.new(email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'does not require password on update if not changed' do
      user = create(:user)
      user.email = 'newemail@example.com'
      expect(user).to be_valid
    end
  end
end
