class SourceText < ApplicationRecord
  has_many :poems, dependent: :destroy
  belongs_to :owner, polymorphic: true, optional: true

  validates :title, presence: true
  validates :content, presence: true
  validate :unique_public_gutenberg_id

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

  def is_public?
    return true unless self.class.column_names.include?('is_public')
    
    super
  end

  private

  def unique_public_gutenberg_id
    return if gutenberg_id.nil?
    return unless is_public?

    existing_public = SourceText.where(gutenberg_id: gutenberg_id, is_public: true)
    existing_public = existing_public.where.not(id: id) if persisted?

    return unless existing_public.exists?

    errors.add(:gutenberg_id, I18n.t('source_texts.errors.gutenberg_id_taken_public'))
  end
end
