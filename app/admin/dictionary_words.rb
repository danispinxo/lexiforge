ActiveAdmin.register DictionaryWord do
  permit_params :word, :part_of_speech, :definition, :synsets

  index do
    selectable_column
    id_column
    column :word
    column :part_of_speech
    column :definition do |dw|
      truncate(dw.definition, length: 100) if dw.definition
    end
    column :synsets do |dw|
      if dw.synsets.present?
        dw.synsets.first(3).join(', ') + (dw.synsets.length > 3 ? '...' : '')
      end
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :word
      row :part_of_speech
      row :definition
      row :synsets do |dw|
        dw.synsets.join(', ') if dw.synsets.present?
      end
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :word
      f.input :part_of_speech, as: :select, collection: %w[n v a r s], include_blank: false
      f.input :definition, as: :text
      f.input :synsets, as: :text, hint: 'Enter synsets as comma-separated values'
    end
    f.actions
  end

  filter :word
  filter :part_of_speech, as: :select, collection: %w[n v a r s]
  filter :definition
  filter :created_at
  filter :updated_at

  sidebar 'Dictionary Statistics', only: :index do
    ul do
      li "Total words: #{DictionaryWord.count}"
      li "Nouns: #{DictionaryWord.where(part_of_speech: 'n').count}"
      li "Verbs: #{DictionaryWord.where(part_of_speech: 'v').count}"
      li "Adjectives: #{DictionaryWord.where(part_of_speech: 'a').count}"
      li "Adverbs: #{DictionaryWord.where(part_of_speech: 'r').count}"
      li "Satellites: #{DictionaryWord.where(part_of_speech: 's').count}"
    end
  end

  action_item :populate_from_wordnet, only: :index do
    link_to 'Populate from WordNet', populate_from_wordnet_admin_dictionary_words_path, method: :post
  end

  collection_action :populate_from_wordnet, method: :post do
    # This would call your rake task
    system('bundle exec rake dictionary:populate')
    redirect_to admin_dictionary_words_path, notice: t('admin.dictionary_words.populated')
  rescue StandardError => e
    redirect_to admin_dictionary_words_path, alert: t('admin.dictionary_words.populate_error', message: e.message)
  end

  action_item :clear_dictionary, only: :index do
    link_to 'Clear Dictionary', clear_dictionary_admin_dictionary_words_path,
            method: :delete,
            data: { confirm: 'Are you sure? This will delete ALL dictionary words!' }
  end

  collection_action :clear_dictionary, method: :delete do
    DictionaryWord.delete_all
    redirect_to admin_dictionary_words_path, notice: t('admin.dictionary_words.cleared')
  rescue StandardError => e
    redirect_to admin_dictionary_words_path, alert: t('admin.dictionary_words.clear_error', message: e.message)
  end

  controller do
    def create
      if params[:dictionary_word][:synsets].present?
        params[:dictionary_word][:synsets] = params[:dictionary_word][:synsets].split(',').map(&:strip)
      end
      super
    end

    def update
      if params[:dictionary_word][:synsets].present?
        params[:dictionary_word][:synsets] = params[:dictionary_word][:synsets].split(',').map(&:strip)
      end
      super
    end
  end
end
