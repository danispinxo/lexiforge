class Poem < ApplicationRecord
  belongs_to :source_text
  belongs_to :author, polymorphic: true, optional: true

  ALLOWED_TECHNIQUES = ['cutup', 'erasure', 'blackout', 'n+7', 'definitional', 'snowball', 'mesostic',
                        'found', 'kwic', 'prisoners_constraint', 'beautiful_outlaw', 'lipogram',
                        'reverse_lipogram', 'abecedarian', 'univocal', 'aleatory', 'alliterative'].freeze

  validates :title, presence: true
  validates :content, presence: true
  validates :technique_used, presence: true, inclusion: {
    in: ALLOWED_TECHNIQUES,
    message: "%<value>s is not a valid technique. Allowed techniques: #{ALLOWED_TECHNIQUES.join(', ')}"
  }

  scope :cut_up_poems, -> { where(technique_used: 'cutup') }
  scope :erasure_poems, -> { where(technique_used: 'erasure') }
  scope :blackout_poems, -> { where(technique_used: 'blackout') }
  scope :n_plus_seven_poems, -> { where(technique_used: 'n+7') }
  scope :definitional_poems, -> { where(technique_used: 'definitional') }
  scope :snowball_poems, -> { where(technique_used: 'snowball') }
  scope :mesostic_poems, -> { where(technique_used: 'mesostic') }
  scope :found_poems, -> { where(technique_used: 'found') }
  scope :kwic_poems, -> { where(technique_used: 'kwic') }
  scope :prisoners_constraint_poems, -> { where(technique_used: 'prisoners_constraint') }
  scope :beautiful_outlaw_poems, -> { where(technique_used: 'beautiful_outlaw') }
  scope :lipogram_poems, -> { where(technique_used: 'lipogram') }
  scope :reverse_lipogram_poems, -> { where(technique_used: 'reverse_lipogram') }
  scope :abecedarian_poems, -> { where(technique_used: 'abecedarian') }
  scope :univocal_poems, -> { where(technique_used: 'univocal') }
  scope :aleatory_poems, -> { where(technique_used: 'aleatory') }
  scope :alliterative_poems, -> { where(technique_used: 'alliterative') }

  scope :recent, -> { order(created_at: :desc) }
  scope :public_poems, -> { where(is_public: true) }
  scope :private_poems, -> { where(is_public: false) }
  scope :for_author, ->(author) { where(author: author) }

  def word_count
    content.split.length
  end

  def line_count
    content.lines.length
  end

  def created_date
    created_at.strftime('%B %d, %Y at %l:%M %p')
  end

  def short_content(limit = PoemGenerationConstants::MODEL[:short_content_limit])
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
       author_id author_type is_public]
  end
end
