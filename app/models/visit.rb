

class Visit < ApplicationRecord
    validates :user_id, :shortened_url_id, presence: true

    def self.record_visit!(user, shortened_url)
      Visit.create!(user_id: user.id, shortened_url_id: shortened_url.id)
    end
end
