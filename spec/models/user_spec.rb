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

    it 'is not valid without a username' do
      user = build(:user, username: nil)
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include("can't be blank")
    end

    it 'is not valid with a username shorter than 3 characters' do
      user = build(:user, username: 'ab')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('is too short (minimum is 3 characters)')
    end

    it 'is not valid with a username longer than 30 characters' do
      user = build(:user, username: 'a' * 31)
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('is too long (maximum is 30 characters)')
    end

    it 'is not valid with a username containing invalid characters' do
      user = build(:user, username: 'user@name')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('is invalid')
    end

    it 'is not valid with a duplicate username' do
      create(:user, username: 'testuser')
      user = build(:user, username: 'testuser')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('has already been taken')
    end

    it 'is not valid with a duplicate username in different case' do
      create(:user, username: 'testuser')
      user = build(:user, username: 'TESTUSER')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to include('has already been taken')
    end

    it 'is not valid without a first name' do
      user = build(:user, first_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'is not valid without a last name' do
      user = build(:user, last_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'is not valid with a first name longer than 50 characters' do
      user = build(:user, first_name: 'a' * 51)
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include('is too long (maximum is 50 characters)')
    end

    it 'is not valid with a last name longer than 50 characters' do
      user = build(:user, last_name: 'a' * 51)
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include('is too long (maximum is 50 characters)')
    end

    it 'is not valid with a bio longer than 500 characters' do
      user = build(:user, bio: 'a' * 501)
      expect(user).not_to be_valid
      expect(user.errors[:bio]).to include('is too long (maximum is 500 characters)')
    end

    it 'is valid with a bio of 500 characters' do
      user = build(:user, bio: 'a' * 500)
      expect(user).to be_valid
    end

    it 'is valid with an empty bio' do
      user = build(:user, bio: '')
      expect(user).to be_valid
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

    it 'is not valid with a password shorter than 12 characters' do
      user = build(:user, password: '12345678901') # 11 characters
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 12 characters)')
    end

    it 'is not valid with mismatched password confirmation' do
      user = build(:user, password: 'password123456', password_confirmation: 'different123456')
      expect(user).not_to be_valid
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end

  describe 'authentication' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123456') }

    it 'can authenticate with valid credentials' do
      expect(user.valid_password?('password123456')).to be true
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

  describe 'username normalization' do
    it 'downcases username before validation' do
      user = create(:user, username: 'TestUser123')
      expect(user.username).to eq('testuser123')
    end
  end

  describe '#full_name' do
    it 'returns first and last name concatenated' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end

    it 'handles empty first name' do
      user = build(:user, first_name: '', last_name: 'Doe')
      expect(user.full_name).to eq('Doe')
    end

    it 'handles empty last name' do
      user = build(:user, first_name: 'John', last_name: '')
      expect(user.full_name).to eq('John')
    end
  end

  describe '#gravatar_url' do
    let(:user) { build(:user, email: 'test@example.com') }

    it 'returns a gravatar URL with default size' do
      expected_hash = Digest::MD5.hexdigest('test@example.com')
      expected_url = "https://www.gravatar.com/avatar/#{expected_hash}?s=80&d=retro"
      expect(user.gravatar_url).to eq(expected_url)
    end

    it 'returns a gravatar URL with custom size' do
      expected_hash = Digest::MD5.hexdigest('test@example.com')
      expected_url = "https://www.gravatar.com/avatar/#{expected_hash}?s=150&d=retro"
      expect(user.gravatar_url(150)).to eq(expected_url)
    end

    it 'handles email with uppercase and whitespace' do
      user = build(:user, email: ' TEST@EXAMPLE.COM ')
      expected_hash = Digest::MD5.hexdigest('test@example.com')
      expected_url = "https://www.gravatar.com/avatar/#{expected_hash}?s=80&d=retro"
      expect(user.gravatar_url).to eq(expected_url)
    end
  end
end
