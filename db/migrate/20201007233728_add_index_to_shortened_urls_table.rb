class AddIndexToShortenedUrlsTable < ActiveRecord::Migration[5.1]
  def change
    add_index :shortened_urls, :short_url, unique: true
    add_index :shortened_urls, :submitter_id
  end
end
