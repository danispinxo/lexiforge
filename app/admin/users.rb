ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :created_at
    column :updated_at
    column :sign_in_count
    column :last_sign_in_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :first_name
      row :last_name
      row :bio do |user|
        simple_format(user.bio) if user.bio.present?
      end
      row :full_name
      row :created_at
      row :updated_at
      row :sign_in_count
      row :last_sign_in_at
      row :last_sign_in_ip
      row :reset_password_sent_at
    end

    panel "Authored Poems (#{user.authored_poems.count})" do
      if user.authored_poems.any?
        table_for user.authored_poems.includes(:source_text).order(created_at: :desc) do
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

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  filter :email
  filter :created_at
  filter :updated_at
  filter :sign_in_count
  filter :last_sign_in_at

  sidebar 'User Details', only: :show do
    ul do
      li link_to 'View Source Texts', admin_source_texts_path(q: { user_id_eq: user.id })
      li link_to 'View Poems', admin_poems_path(q: { user_id_eq: user.id })
    end
  end

  action_item :reset_password, only: :show do
    if user.respond_to?(:send_reset_password_instructions)
      link_to 'Reset Password', reset_password_admin_user_path(user),
              method: :post
    end
  end

  member_action :reset_password, method: :post do
    user = User.find(params[:id])
    user.send_reset_password_instructions
    redirect_to admin_user_path(user), notice: t('admin.users.password_reset_sent')
  end
end
