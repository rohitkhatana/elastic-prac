require 'elasticsearch/model'
#require 'elasticsearch/persistence/model'
class Articel < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  settings index: { number_of_shards: 1,
      analysis: {
        filter: {
          custom_synonym:{
            synonyms: [
              "cp,consumer",
              "foo,bar,baz"
            ],
            type: 'synonym'
          }
        },
        analyzer: {
          custom_synonym: {
            filter: ['custom_synonym'],
            type: 'snowball',
            tokenizer: 'snowball'
          } 
        }
      }  
    } do
    mappings dynamic: 'false' do
      indexes :desc, search_analyzer: 'custom_synonym', index_analyzer: 'custom_synonym'
    end
  end
  
  def custom_create
    Articel.__elasticsearch__.client.indices.delete index: Articel.index_name rescue nil
    Articel.__elasticsearch__.client.indices.create \
        index: Articel.index_name,
        body: { settings: Articel.settings.to_hash, mappings: Articel.mappings.to_hash }
  end
end
