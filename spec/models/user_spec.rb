# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:swag) { User.create!(username: 'Swag', password: 'jimmy') }

  it {should validate_presence_of(:username)}
  it {should validate_presence_of(:password_digest)}
  it {should validate_presence_of(:session_token)}

  it {should validate_uniqueness_of(:username)}
  it {should validate_uniqueness_of(:session_token)}

  it {should validate_length_of(:password).is_at_least(6)}


  describe "::find_by_credentials" do 
    context "with validate credentials" do
      
      it "returns the user" do 
        bob = User.create!(username: 'Bob', password: 'password')
        user = User.find_by_credentials('Bob', 'password')
        expect(bob.username).to eq(user.username)  
        expect(bob.password_digest).to eq(user.password_digest)  
      end 
    end

    context "with invalid credentials" do
      it "returns nil" do
        # bob = User.create!(username: 'Bob', password: 'password')
        user = User.find_by_credentials('Bob', 'wrong_password')
        expect(user).to eq(nil)  
        expect(user).to eq(nil)  
      end
    end
    
  end 

  describe "password encryption" do 
    it "does not save password to database" do 
      # User.create!(username:'Swag' , password: 'jimmy')
      swag = User.find_by(username: 'Swag')
      expect(swag.password).not_to be('jimmy')  
    end 

    it "ensuring BCrypt is used on password" do
      expect(BCrypt::Password).to receive(:create) 
      User.new(username:'Swag', password: 'jimmy')
    end
  end 

  describe "is_password?" do 
    swag = User.find_by(username: 'Swag')
    

    it "should use BCrypt.new to make a BCrypt obj" do 
      expect(BCrypt::Password).to receive(:new) 
      swag.is_password?('jimmy')
    end 

    it "calls BCrypt.is_password" do
      expect(BCrypt::Password).to receive(:is_password?) 
      swag.is_password?('jimmy')
    end
  end 

  describe "reset_session_token & ensure's session token" do 
    swag = User.find_by(username: 'Swag')
    
  
    it "regenerates a new session token" do 
      old_session_token = swag.session_token
      new_session_token = swag.reset_session_token
      expect(old_session_token).not_to eq(new_session_token)  
    end 

    it "ensures session token is generated if missing" do
      old_session_token = swag.session_token
      new_user = User.create!(username:'jimmy' , password: 'mannn')
      expect(new_user.session_token).not_to be_nil
    end
  end 

end
