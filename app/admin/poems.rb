ActiveAdmin.register Poem do
  permit_params :title, :content, :technique_used, :source_text_id, :is_public, :author_type, :author_id

  index do
    selectable_column
    id_column
    column :title
    column :technique_used
    column :is_public do |poem|
      if poem.is_public
        status_tag 'Public'
      else
        status_tag 'Private'
      end
    end
    column 'Content Preview' do |poem|
      truncate(poem.content, length: 150) if poem.content
    end
    column :source_text do |poem|
      link_to poem.source_text.title, admin_source_text_path(poem.source_text) if poem.source_text
    end
    column :author do |poem|
      if poem.author
        case poem.author_type
        when 'User'
          link_to poem.author_name, admin_user_path(poem.author)
        when 'AdminUser'
          link_to poem.author_name, admin_admin_user_path(poem.author)
        else
          poem.author_name
        end
      else
        'Anonymous'
      end
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :technique_used
      row :is_public do |poem|
        if poem.is_public
          status_tag 'Public', class: 'green'
        else
          status_tag 'Private', class: 'red'
        end
      end
      row :source_text do |poem|
        link_to poem.source_text.title, admin_source_text_path(poem.source_text) if poem.source_text
      end
      row :author do |poem|
        if poem.author
          case poem.author_type
          when 'User'
            link_to poem.author_name, admin_user_path(poem.author)
          when 'AdminUser'
            link_to poem.author_name, admin_admin_user_path(poem.author)
          else
            poem.author_name
          end
        else
          'Anonymous'
        end
      end
      row :content do |poem|
        simple_format(truncate(poem.content, length: 300)) if poem.content
      end
      row :word_count
      row :line_count
      row :created_at
      row :updated_at
    end

    panel 'Full Poem Content' do
      div style: 'max-height: 400px; overflow-y: auto; white-space: pre-wrap; ' \
                 'font-family: serif; font-size: 14px; line-height: 1.6; ' \
                 'padding: 15px; background: #f9f9f9; border-radius: 5px;' do
        poem.content
      end
    end
  end
end
