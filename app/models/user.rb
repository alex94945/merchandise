class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :product_sets
  has_many :styles, through: :product_sets
  has_many :budgets

  has_one :profile_config, dependent: :destroy
  has_one :payment_account
  enum role: [ :buyer, :vendor ]

  belongs_to :company
  accepts_nested_attributes_for :company

  after_create :make_profile_config

  private
    def make_profile_config
      create_profile_config
    end

end
