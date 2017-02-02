class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :appointments
  has_many :styles, through: :appointments
  has_many :budgets
  has_many :reminders, dependent: :destroy

  has_one :profile_config, dependent: :destroy
  enum role: [ :buyer, :vendor ]

  belongs_to :company

  after_create :make_profile_config

  private
    def make_profile_config
      create_profile_config
    end

end
