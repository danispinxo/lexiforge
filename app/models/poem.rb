class Poem < ApplicationRecord
  belongs_to :source_text
  
  validates :title, presence: true
  validates :content, presence: true
  validates :technique_used, presence: true
  
  scope :cut_up_poems, -> { where(technique_used: 'cut-up') }
  scope :recent, -> { order(created_at: :desc) }
  
  def word_count
    content.split.length
  end
  
  def line_count
    content.lines.length
  end
  
  def created_date
    created_at.strftime("%B %d, %Y at %l:%M %p")
  end
  
  def short_content(limit = 100)
    return content if content.length <= limit
    content.truncate(limit, separator: ' ')
  end
end
