# Vantags
A demonstration utilizing PostgreSQL HStore for arbitrary tagging.

## Why?
Sometimes you want to make a model taggable. There are many ways to do this on
the db level, for example you can:
* Create a joins table to store each individual tag instance
* Serialize tags into a string column
* Use a Postgres ARRAY type a la `table.text :tags, array: true, default: []`

Or, you can use an HStore. Think of HStore as a key-value store for every row.
For querying, especially with large amounts of data per store, it's faster than
parsing through an array.  The HStore datatype has also great support for 
[GIN and GiST indexes](http://www.postgresql.org/docs/9.4/static/textsearch-indexes.html).

## How?
Simply store each tag as a key-value pair: `{ 'tag_name': nil }`.
Sure, throwing around `nil` as a value is a little hacky, but this is easily
abstracted away. You could also hypothetically use it to store other data, such
as created-at dates. In the end, storing tags as keys is a major plus due to
constant time key queries and set semantics (no duplicates!).

## How, really?
First you'll need a HStore column. This is a simple migration:
```ruby
def change
  enable_extension 'hstore'
  change_table :table_name do |t|
    t.hstore :tags
  end
end
```

`rake db:migrate` and then use this 
[handy-dandy model concern](https://github.com/garrettf/vantags/blob/master/app/models/concerns/taggable.rb)
to do the work:
```ruby
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
```
Simply include the concern on your model:
```ruby
class ModelName < ActiveRecord::Base
  include Taggable
end
```
And now you can update and query for tags, e.g.
```ruby
# Can assigned via array
> red_van.tags = ['red', 'fast', 'automatic']
# Or via Sets
> blue_van.tags = Set['blue', 'slow', 'automatic']

# But it always returns a Set
> red_van.tags
# => #<Set: {"red", "fast", "shiny", "automatic"}>

# You can query via with_tag or with_tags
> Van.with_tag 'automatic'
# Van Load (3.9ms)  SELECT "vans".* FROM "vans"  WHERE (tags ? 'automatic')
=> [#<Van id: 1, make: "Fjord", model: "Picnic", tags: #<Set: {"blue", "slow", "automatic"}>>,
 #<Van id: 2, make: "Chase", model: "Neutrino", tags: #<Set: {"red", "fast", "automatic"}>>]
> Van.with_tags ['automatic', 'red']
# Van Load (0.5ms)  SELECT "vans".* FROM "vans"  WHERE (tags ? 'automatic') AND (tags ? 'red')
=> [#<Van id: 2, make: "Chase", model: "Neutrino", tags: #<Set: {"red", "fast", "automatic"}>>]
```
