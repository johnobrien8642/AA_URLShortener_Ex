

class Tagging < ApplicationRecord
    validates :shortened_url, :tag_topic, presence: true
    validates :shortened_url_id, uniqueness: { scope: :tag_topic_id }
    
    belongs_to :tag_topic,
      primary_key: :id, 
      foreign_key: :tag_topic_id,
      class_name: :TagTopic

    belongs_to :shortened_url,
      foreign_key: :shortened_url_id,
      primary_key: :id,
      class_name: :ShortenedUrl

end
