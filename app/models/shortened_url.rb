
class ShortenedUrl < ApplicationRecord
    validates :long_url, :short_url, presence: true
    validates :short_url, uniqueness: true
    validate :no_spamming, :non_premium_max

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

    def self.create_cust_url_for_user_from_long_url!(user, long_url, cust_url)
      ShortenedUrl.create!(
        submitter_id: user.id,
        long_url: long_url,
        short_url: cust_url
      )
    end

    def self.random_words
      loop do
        all_words = File.readlines("./lib/assets/dictionary.txt").map(&:chomp)
        rand_word = ''
        rand_word += all_words.sample until rand_word.length > 10
        return rand_word unless ShortenedUrl.exists?(short_url: rand_word)
      end
    end

    def no_spamming
      num_recent_uniques_in_last_minute_for_user
    end

    def non_premium_max
      return if User.find(self.submitter_id).premium
      
      if submitter.premium == false && total_urls_for_user > 5
        errors[:maximum] << 'urls for non-premium user' 
      end
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

    private

    def num_recent_uniques_in_last_minute_for_user
      last_minute = ShortenedUrl
        .select('id')
        .where(['created_at > ? AND submitter_id = ?', 1.minutes.ago, self.submitter_id])
        .count
      errors[:maximum] << 'of five short urls per minute' if last_minute >= 5
    end

    def total_urls_for_user
      total_count = ShortenedUrl
        .select('id')
        .where(['submitter_id = ?', self.submitter_id])
        .count
      total_count
    end

    def self.prune(n) 
      ShortenedUrl
        .joins(:submitter)
        .joins('LEFT JOIN visits ON visits.shortened_url_id = shortened_urls.id')
        .where("(shortened_urls.id IN (
          SELECT shortened_urls.id
          FROM shortened_urls
          JOIN visits
          ON visits.shortened_url_id = shortened_urls.id
          GROUP BY shortened_urls.id
          HAVING MAX(visits.created_at) < \'#{n.minute.ago}\'  
        ) OR (
          visits.id IS NULL and shortened_urls.created_at < \'#{n.minutes.ago}\'
        )) AND users.premium = \'f\'")
        .destroy_all
    end
end