class Poem < ApplicationRecord
  belongs_to :source_text
  belongs_to :author, polymorphic: true, optional: true

  ALLOWED_TECHNIQUES = ['cutup', 'erasure', 'blackout', 'n+7', 'definitional', 'snowball', 'mesostic',
                        'found', 'kwic'].freeze

  validates :title, presence: true
  validates :content, presence: true
  validates :technique_used, presence: true, inclusion: {
    in: ALLOWED_TECHNIQUES,
    message: "%<value>s is not a valid technique. Allowed techniques: #{ALLOWED_TECHNIQUES.join(', ')}"
  }

  scope :cut_up_poems, -> { where(technique_used: 'cutup') }
  scope :recent, -> { order(created_at: :desc) }

  def word_count
    content.split.length
  end

  def line_count
    content.lines.length
  end

  def created_date
    created_at.strftime('%B %d, %Y at %l:%M %p')
  end

  def short_content(limit = 100)
    return content if content.length <= limit

    content.truncate(limit, separator: ' ')
  end

  def author_name
    return 'Anonymous' unless author

    if author.respond_to?(:full_name) && author.full_name.present?
      author.full_name
    elsif author.respond_to?(:username) && author.username.present?
      author.username
    else
      author.email
    end
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[source_text author]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[content created_at id id_value source_text_id technique_used title updated_at
       author_id author_type]
  end
end
