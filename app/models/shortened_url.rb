

class ShortenedUrl < ApplicationRecord
    validates :long_url, :short_url, presence: true
    validates :short_url, uniqueness: true

    belongs_to :submitter,
      class_name: :User,
      foreign_key: :submitter_id,
      primary_key: :id

    has_many :visits,
      class_name: :Visit,
      foreign_key: :shortened_url_id,
      primary_key: :id,
      dependent: :destroy
    
    has_many :visitors,
       -> { distinct },
      through: :visits,
      source: :visitor

    has_many :taggings,
      primary_key: :id, 
      foreign_key: :shortened_url_id,
      class_name: :Tagging,
      dependent: :destroy
    
    has_many :tag_topics,
      through: :taggings,
      source: :tag_topic


    def self.create_for_user_and_long_url!(user, long_url)
      ShortenedUrl.create!(
          submitter_id: user.id,
          long_url: long_url,
          short_url: ShortenedUrl.random_code
      )
    end

    def self.random_code
      loop do
        random_code = SecureRandom::urlsafe_base64
        return random_code unless ShortenedUrl.exists?(short_url: random_code)
      end
    end

    def num_clicks
      visits.count
    end

    def num_uniques
      visitors.count
    end

    def num_recent_uniques
      visits
        .select('user_id')
        .where('created_at > ?', 10.minutes.ago)
        .distinct
        .count     
    end
end