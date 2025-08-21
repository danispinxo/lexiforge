ActiveAdmin.register SourceText do
  permit_params :title, :content, :gutenberg_id, :author, :is_public, :owner_type, :owner_id

  index do
    selectable_column
    id_column
    column :title
    column :author
    column :gutenberg_id
    column :is_public do |source_text|
      if source_text.is_public
        status_tag 'Public', class: 'green'
      else
        status_tag 'Private', class: 'red'
      end
    end
    column :owner do |source_text|
      if source_text.owner
        case source_text.owner_type
        when 'User'
          link_to source_text.owner.full_name || source_text.owner.username, admin_user_path(source_text.owner)
        when 'AdminUser'
          link_to source_text.owner.email, admin_admin_user_path(source_text.owner)
        else
          source_text.owner.to_s
        end
      else
        'System'
      end
    end
    column 'Content Preview' do |source_text|
      truncate(source_text.content, length: 100) if source_text.content
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :author
      row :gutenberg_id
      row :is_public do |source_text|
        if source_text.is_public
          status_tag 'Public', class: 'green'
        else
          status_tag 'Private', class: 'red'
        end
      end
      row :owner do |source_text|
        if source_text.owner
          case source_text.owner_type
          when 'User'
            link_to source_text.owner.full_name || source_text.owner.username, admin_user_path(source_text.owner)
          when 'AdminUser'
            link_to source_text.owner.email, admin_admin_user_path(source_text.owner)
          else
            source_text.owner.to_s
          end
        else
          'System'
        end
      end
      row :content do |source_text|
        simple_format(truncate(source_text.content, length: 500)) if source_text.content
      end
      row :created_at
      row :updated_at
    end

    panel 'Full Content' do
      div style: 'max-height: 400px; overflow-y: auto; white-space: pre-wrap; ' \
                 'font-family: monospace; font-size: 12px;' do
        source_text.content
      end
    end

    panel 'Generated Poems' do
      table_for source_text.poems do
        column :title
        column :technique_used
        column :created_at
        column 'Actions' do |poem|
          link_to 'View', admin_poem_path(poem), class: 'button'
        end
      end
    end
  end
end
