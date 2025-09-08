ActiveAdmin.register Poem do
  permit_params :title, :content, :technique_used, :source_text_id, :is_public, :author_type, :author_id

  # Add scopes for quick filtering by technique
  scope :all, default: true
  scope :cut_up_poems, -> { cut_up_poems }, 'Cut-Up'
  scope :erasure_poems, -> { erasure_poems }, 'Erasure'
  scope :blackout_poems, -> { blackout_poems }, 'Blackout'
  scope :n_plus_seven_poems, -> { n_plus_seven_poems }, 'N+7'
  scope :definitional_poems, -> { definitional_poems }, 'Definitional'
  scope :snowball_poems, -> { snowball_poems }, 'Snowball'
  scope :mesostic_poems, -> { mesostic_poems }, 'Mesostic'
  scope :found_poems, -> { found_poems }, 'Found'
  scope :kwic_poems, -> { kwic_poems }, 'KWIC'
  scope :prisoners_constraint_poems, -> { prisoners_constraint_poems }, 'Prisoner\'s Constraint'
  scope :public_poems, -> { public_poems }, 'Public'
  scope :private_poems, -> { private_poems }, 'Private'
  scope :recent, -> { recent }, 'Recent'

  # Add filters for more detailed searching
  filter :title
  filter :technique_used, as: :select, collection: Poem::ALLOWED_TECHNIQUES.map { |t| [t.humanize, t] }
  filter :is_public, as: :select, collection: [['Public', true], ['Private', false]]
  filter :source_text, as: :select, collection: -> { SourceText.all.pluck(:title, :id) }
  filter :author_type, as: :select, collection: [['User', 'User'], ['Admin User', 'AdminUser']]
  filter :created_at
  filter :updated_at
  filter :content, label: 'Content contains'

  index do
    selectable_column
    id_column
    column :title
    column :technique_used do |poem|
      color_style = case poem.technique_used
                    when 'cutup' then 'background-color: #3498db; color: white;'
                    when 'erasure' then 'background-color: #2ecc71; color: white;'
                    when 'blackout' then 'background-color: #2c3e50; color: white;'
                    when 'n+7' then 'background-color: #f39c12; color: white;'
                    when 'definitional' then 'background-color: #9b59b6; color: white;'
                    when 'snowball' then 'background-color: #1abc9c; color: white;'
                    when 'mesostic' then 'background-color: #e91e63; color: white;'
                    when 'found' then 'background-color: #ff9800; color: white;'
                    when 'kwic' then 'background-color: #e74c3c; color: white;'
                    when 'prisoners_constraint' then 'background-color: #95a5a6; color: white;'
                    else 'background-color: #bdc3c7; color: white;'
                    end
         content_tag :span, poem.technique_used.humanize,
                     style: "display: inline-block; padding: 4px 8px; border-radius: 3px; " \
                            "font-size: 11px; font-weight: bold; text-transform: uppercase; #{color_style}"
    end
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
      row :technique_used do |poem|
        color_style = case poem.technique_used
                      when 'cutup' then 'background-color: #3498db; color: white;'
                      when 'erasure' then 'background-color: #2ecc71; color: white;'
                      when 'blackout' then 'background-color: #2c3e50; color: white;'
                      when 'n+7' then 'background-color: #f39c12; color: white;'
                      when 'definitional' then 'background-color: #9b59b6; color: white;'
                      when 'snowball' then 'background-color: #1abc9c; color: white;'
                      when 'mesostic' then 'background-color: #e91e63; color: white;'
                      when 'found' then 'background-color: #ff9800; color: white;'
                      when 'kwic' then 'background-color: #e74c3c; color: white;'
                      when 'prisoners_constraint' then 'background-color: #95a5a6; color: white;'
                      else 'background-color: #bdc3c7; color: white;'
                      end
        content_tag :span, poem.technique_used.humanize,
                    style: "display: inline-block; padding: 4px 8px; border-radius: 3px; " \
                           "font-size: 11px; font-weight: bold; text-transform: uppercase; #{color_style}"
      end
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

  action_item :technique_stats, only: :index do
    link_to 'View Technique Statistics', technique_stats_admin_poems_path, class: 'button'
  end

  collection_action :technique_stats, method: :get do
    @stats = Poem.group(:technique_used).count
  end
end
