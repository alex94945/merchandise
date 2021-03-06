class Style < ActiveRecord::Base
  belongs_to :product_set
  enum status: [ :created, :pending, :placed, :received, :cancelled, :deleted ]
  INCOMPLETE_STATUSES = [0,1]

  has_many :attachments, dependent: :destroy
  validates :vendor_style_number, presence: true

  scope :open, -> { where(status: [0,1,2,3]) } #ignores cancelled and deleted

  scope :incomplete, -> { where(status: Style::INCOMPLETE_STATUSES) }

  scope :with_value, -> { where(
                      "quantity > ? AND
                      (wholesale_cost > ? OR negotiated_cost > ?) AND
                      retail_price > ?", 0, 0, 0, 0) }

  def initial_mark_up
      return 0 if retail_price.blank? || wholesale_or_negotiated_cost.nil?
      ((retail_price - wholesale_or_negotiated_cost) / retail_price) * 100
  end

  def self.to_csv
    attributes = %w{Vendor_Style_Number Quantity Status Color Created
                        Negotiated_Cost Retail_Price Wholesale_Cost Category_Name Delivery_Date Notes Attachments}

    CSV.generate(headers: true) do |csv|
        csv << attributes
        all.each do |style|
          csv << [
              style.vendor_style_number,
              style.quantity,
              style.status,
              style.color,
              style.created_at.strftime("%Y-%m-%d"),
              style.negotiated_cost,
              style.retail_price,
              style.wholesale_cost,
              style.category_name,
              style.delivery_date,
              style.notes,
              style.attachments.map{ |a| Rails.application.routes.url_helpers.api_v1_url(a) }.join(' ')
            ]
        end
    end
  end

  def wholesale_or_negotiated_cost
    return 0 unless negotiated_cost || wholesale_cost
    negotiated_cost.present? ? negotiated_cost : wholesale_cost
  end

  def default_photo(size = 'large')

    return nil unless attachments.any?
    if default_attachment_id
      a = attachments.find_by_id(default_attachment_id)
      unless a.nil?
        a.photo.url(size)
      end
    else
      attachments.first.photo.url(size)
    end

  end

  # Called from Delayed Job
  def upload_attachments(photos)
    if photos.present?
      photos.each do |photo|
        attachments.create(photo: photo)
      end
    end
  end

end
