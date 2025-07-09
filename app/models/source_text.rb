class SourceText < ApplicationRecord
    has_many :poems, dependent: :destroy
    
    validates :title, presence: true
    validates :content, presence: true
    validates :gutenberg_id, uniqueness: true, allow_nil: true
    
    scope :from_gutenberg, -> { where.not(gutenberg_id: nil) }
    scope :custom, -> { where(gutenberg_id: nil) }
end
