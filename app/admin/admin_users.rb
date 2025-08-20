ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :first_name
      row :last_name
      row :bio do |admin_user|
        simple_format(admin_user.bio) if admin_user.bio.present?
      end
      row :full_name
      row :created_at
      row :updated_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :remember_created_at
    end

    panel "Authored Poems (#{admin_user.authored_poems.count})" do
      if admin_user.authored_poems.any?
        table_for admin_user.authored_poems.includes(:source_text).order(created_at: :desc) do
          column :title do |poem|
            link_to poem.title, admin_poem_path(poem)
          end
          column :technique_used
          column :source_text do |poem|
            link_to poem.source_text.title, admin_source_text_path(poem.source_text) if poem.source_text
          end
          column 'Content Preview' do |poem|
            truncate(poem.content, length: 100) if poem.content
          end
          column :created_at do |poem|
            poem.created_at.strftime('%m/%d/%Y')
          end
        end
      else
        div class: 'blank_slate_container' do
          span class: 'blank_slate' do
            span 'No poems authored yet'
          end
        end
      end
    end
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end
end
