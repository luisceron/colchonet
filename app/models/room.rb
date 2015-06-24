class Room < ActiveRecord::Base
  #É necessário definir o has_many primeiro!
  has_many :reviews, dependent: :destroy
  has_many :reviewed_rooms, through: :reviews, source: :room
  belongs_to :user

  scope :most_recent, order("created_at DESC")

  validates_presence_of :title, :location, :description
  validates_length_of :description, minimum: 10, allow_blank: false

  def complete_name
    "#{title}, #{location}"
  end

  def self.search(query)
    if query.present?
      where(['location ILIKE :query OR
      title ILIKE :query OR
      description ILIKE :query', query: "%#{query}%"])
    else
      scoped
    end
  end

  def to_param
    "#{id}-#{title.parameterize}"
  end

end
