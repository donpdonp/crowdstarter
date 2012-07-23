class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :username

  has_many :projects
  has_many :contributions
  has_many :activities

  validates :email, :uniqueness => true
  validates :username, :uniqueness => {:allow_nil => true}
  validates :facebook_uid, :uniqueness => {:allow_nil => true}

  def self.find_or_create_from_auth_hash(hash)
    user = find_by_facebook_uid(hash.uid)
    if user
      return user
    else
      return User.create(:facebook_uid => hash.uid,
                         :email => hash.info.email,
                         :name => hash.info.name,
                         :image_url => hash.info.image,
                         :oauth_token => hash.credentials.token)
    end
  end

  def profile_image_url
    image_url || "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}?s=50"
  end

  def wepay_token_hash
    JSON.parse(wepay_token)
  end

  def payment_gateway
    attributes['payment_gateway'] || SETTINGS.default_payment_gateway
  end
end
