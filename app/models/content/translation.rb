class Content::Translation < ActiveRecord::Base
    extend Content
    extend Batchelor

    self.table_name = 'translation'
    self.primary_keys = :ayah_key, :resource_id # composite primary key which is a combination of ayah_key & resource_id

    belongs_to :resource, class_name: 'Content::Resource'
    belongs_to :ayah, class_name: 'Quran::Ayah'

    def self.import(options = {})
        transform = lambda do |a|
            { index: {
                    _id: "#{a.resource_id},#{a.ayah_key}",
                _parent: a.ayah_key,
                   data: a.__elasticsearch__.as_indexed_json.merge( { 'resource' => a.resource.__elasticsearch__.as_indexed_json, 'language' => a.resource.language.__elasticsearch__.as_indexed_json, 'source' => a.resource.source.__elasticsearch__.as_indexed_json, 'author' => a.resource.author.__elasticsearch__.as_indexed_json } )
            } }
        end

        options = { transform: transform, batch_size: 6236 }.merge(options)
        self.importing options 
    end
end
# notes:
# - provides a 'text' column
# transform = lambda do |a|
#    {index: {_id: a.id, _parent: a.author_id, data: a.__elasticsearch__.as_indexed_json}}
# end


