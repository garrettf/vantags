require 'active_support/concern'

module Taggable
  extend ActiveSupport::Concern

  included do
    serialize :tags, Tags
    scope :with_tag,  -> (tag)  { where "tags ? #{ self.sanitize tag }" }
    scope :with_tags, -> (tags) { tags.inject( self, &:with_tag ) }
  end

  class Tags
    def self.dump(data)
      case data
      when Set
        Hash[ data.map { |item| [ item, nil ] } ]
      when Array
        Hash[ data.uniq.map { |item| [ item, nil ] } ]
      when nil
        nil
      else
        raise "Cannot save #{ data.class.name } as tags."
      end
    end

    def self.load(data)
      Set.new data.keys if data.present?
    end
  end
end
