class User < ActiveRecord::Base
  EMAIL_REGEXP = /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/

  has_many :rooms, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates_presence_of :email, :full_name, :location,
     :password_confirmation
  validates_length_of :bio, minimum: 10,
     allow_blank: false
  validates_format_of :email, with: EMAIL_REGEXP
  validates_uniqueness_of :email

  has_secure_password

  scope :confirmed, -> { where.not(confirmed_at: nil) }

  before_create do |user|
    user.confirmation_token = SecureRandom.urlsafe_base64
  end

  def confirm!
    return if confirmed?
    self.confirmed_at = Time.current
    self.confirmation_token = ''
    self.password_confirmation = 'x'
    save!
  end

  def confirmed?
    confirmed_at.present?
  end

  def self.authenticate(email, password)
    user = confirmed.find_by(email: email).try(:authenticate, password)
  end

  #Should be a service
  def self.verifyConfirmedEmails()
    query = '4 minutes'
    User.where('(LOCALTIMESTAMP - created_at) >
      interval ? AND
      confirmed_at is null', query).destroy_all
  end

end
