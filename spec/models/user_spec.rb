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
  subject! { User.create!(username: 'Swag', password: 'jimmmy') }

  it {should validate_presence_of(:username)}
  it {should validate_presence_of(:password_digest)}

  it {should validate_uniqueness_of(:username)}
  it {should validate_uniqueness_of(:session_token)}

  it {should validate_length_of(:password).is_at_least(6)}


  describe "::find_by_credentials" do 
    context "with valid credentials" do
      
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
      expect(subject.password_digest).not_to be('jimmmy')  
    end 

    it "ensuring BCrypt is used on password" do
      expect(BCrypt::Password).to receive(:create) 
      User.new(username:'Swag', password: 'jimmmy')
    end
  end 

  describe "is_password?" do 
    it "should use BCrypt.new to make a BCrypt obj" do 
      
      new_user = User.create(username: "Darren", password: "123456")
      expect(BCrypt::Password).to receive(:new).and_return(BCrypt::Password.new(new_user.password_digest))
      #debugger
      new_user.is_password?('123456')
    end 
  end 

  describe "reset_session_token & ensure's session token" do 
    it "regenerates a new session token" do 
      old_session_token = subject.session_token
      new_session_token = subject.reset_session_token
      expect(old_session_token).not_to eq(new_session_token)  
    end 

    it "ensures session token is generated if missing" do
      old_session_token = subject.session_token
      new_user = User.create!(username:'jimmy' , password: 'mannnn')
      expect(new_user.session_token).not_to be_nil
    end
  end 

end
