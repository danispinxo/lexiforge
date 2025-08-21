class SourceText < ApplicationRecord
  has_many :poems, dependent: :destroy
  belongs_to :owner, polymorphic: true, optional: true

  validates :title, presence: true
  validates :content, presence: true
  validates :gutenberg_id, uniqueness: {
    conditions: -> { where(is_public: true) },
    message: ->(_object, _data) { I18n.t('source_texts.errors.gutenberg_id_taken_public') }
  }, allow_nil: true

  scope :from_gutenberg, -> { where.not(gutenberg_id: nil) }
  scope :custom, -> { where(gutenberg_id: nil) }
  scope :public_texts, -> { where(is_public: true) }
  scope :private_texts, -> { where(is_public: false) }
  scope :for_owner, ->(owner) { where(owner: owner) }

  def self.ransackable_associations(_auth_object = nil)
    ['poems']
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[content created_at gutenberg_id id id_value title updated_at is_public owner_id owner_type]
  end
end
