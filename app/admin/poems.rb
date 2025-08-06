ActiveAdmin.register Poem do
  permit_params :title, :content, :technique_used, :source_text_id

  index do
    selectable_column
    id_column
    column :title
    column :technique_used
    column 'Content Preview' do |poem|
      truncate(poem.content, length: 150) if poem.content
    end
    column :source_text do |poem|
      link_to poem.source_text.title, admin_source_text_path(poem.source_text) if poem.source_text
    end
    column :created_at
    actions
  end

  # Customize the show page (detail view)
  show do
    attributes_table do
      row :id
      row :title
      row :technique_used
      row :source_text do |poem|
        link_to poem.source_text.title, admin_source_text_path(poem.source_text) if poem.source_text
      end
      row :content do |poem|
        simple_format(truncate(poem.content, length: 300)) if poem.content
      end
      row :word_count
      row :line_count
      row :created_at
      row :updated_at
    end

    # Show full content in a separate panel
    panel 'Full Poem Content' do
      div style: 'max-height: 400px; overflow-y: auto; white-space: pre-wrap; font-family: serif; font-size: 14px; line-height: 1.6; padding: 15px; background: #f9f9f9; border-radius: 5px;' do
        poem.content
      end
    end
  end
end
