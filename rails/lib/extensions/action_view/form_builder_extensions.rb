module Extensions
  module ActionView
    module FormBuilderExtensions
      # Extracts the group from each element in the collection
      #
      #   @users where User belongs_to :organization
      #
      # Alternative to grouped_collection_select, which requires a nested collection:
      #
      #   @organizations where Organization has_many :users
      #
      # Taken from https://makandracards.com/makandra/33755-a-non-weird-replacement-for-grouped_collection_select
      # without [collect_hash](https://makandracards.com/makandra/735-collect-a-hash-from-an-array)
      def flat_grouped_collection_select(field, collection, group_label_method, value_method, label_method, options = {}, html_options = {})
        hash = collection.group_by(&group_label_method).map do |group_label, group_entries|
          list_of_pairs = group_entries.collect do |entry|
            [entry.send(label_method), entry.send(value_method).to_s]
          end
          [group_label, list_of_pairs]
        end.to_h
        options_options = {} # options.slice(:prompt, :divider) are duplicative and ignored, respectively. So, passing nothing down.
        selected_key = object.send(field).to_s
        select(field, @template.grouped_options_for_select(hash, selected_key, options_options), options, html_options)
      end
    end
  end
end
