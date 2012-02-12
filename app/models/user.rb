class User < ActiveRecord::Base
  has_many :projects

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
end
