# require 'byebug'

class Vote < ApplicationRecord
    validates :user_id, :shortened_url_id, presence: true
    validates :user_id, uniqueness: { scope: :shortened_url_id,
        message: 'can only vote for a given URL once'
    }
    validate :no_self_voting

    belongs_to :voter,
        class_name: :User,
        foreign_key: :user_id,
        primary_key: :id

    belongs_to :shortened_url


    def self.vote!(user, shortened_url)
        Vote.create!(
            user_id: user.id,
            shortened_url_id: shortened_url.id
        )   
    end

    def no_self_voting
        if ShortenedUrl.find(shortened_url.id).submitter_id == voter.id
          errors[:User] << 'can''t vote for their own urls' 
        end
    end
end
