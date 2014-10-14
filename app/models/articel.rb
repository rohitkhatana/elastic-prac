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
            filter: ['standard','lowercase', 'stop','custom_synonym'],
            type: 'custom',
            tokenizer: 'standard'
          } 
        }
      }  
    } do
    mappings dynamic: 'false' do
      indexes :desc, analyzer: 'custom_synonym'
    end
  end
  
  def custom_create
    Articel.__elasticsearch__.client.indices.delete index: Articel.index_name rescue nil
    Articel.__elasticsearch__.client.indices.create \
        index: Articel.index_name,
        body: { settings: Articel.settings.to_hash, mappings: Articel.mappings.to_hash }
  end

  def custom_search
    fr = Articel.search facets: { tags: {terms: {field: 'desc'} } }
  end
end
