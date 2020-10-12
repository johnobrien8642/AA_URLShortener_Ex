

class User < ApplicationRecord
    validates :email, uniqueness: true, presence: true

    has_many :submitted_urls,
      class_name: :ShortenedUrl,
      foreign_key: :submitter_id,
      primary_key: :id

    has_many :visits,
      class_name: :Visit,
      foreign_key: :user_id,
      primary_key: :id

    has_many :visited_urls,
      through: :visits,
      source: :shortened_url

    has_many :votes_for_user,
      class_name: :Vote,
      foreign_key: :user_id,
      primary_key: :id


    def make_premium
      toggle(:premium).save
    end

    def make_non_premium
      toggle(:premium).save
    end
      
end