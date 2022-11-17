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
class User < ApplicationRecord

    validates :username, :session_token, :password_digest, presence: true
    validates :username, :session_token, uniqueness: true
    validates :password, length: {minimum: 6}, allow_nil: true
    before_validation :ensure_session_token

    attr_reader :password


    #SPIRE

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        if user&.is_password?(password)
            return user 
        else    
            return nil 
        end 
    end 

    def password=(password)
        self.password_digest = BCrypt::Password.create(password)
        @password = password
    end 

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

    def reset_session_token
        self.session_token = generate_unique_session_token
        save!
        return self.session_token
    end

    def ensure_session_token
        self.session_token ||= generate_unique_session_token
    end

    private 
    def generate_unique_session_token
        while true
            token = SecureRandom::urlsafe_base64
            return token unless User.exists?(session_token: token)
        end
    end

end
