module Imageable
  extend ActiveSupport::Concern

  included do
    attr_writer :image_sizes
    after_save :save_images
  end

  def get_image_path(prefix, ext)
    Rails.root.join('public', self.class.table_name, "#{id.to_s}-#{prefix}#{ext}")
  end

  def delete_old_images(prefix)
    png_path = get_image_path(prefix, 'png')
    jpg_path = get_image_path(prefix, 'jpg')
    File.delete(png_path) if File.exist?(png_path)
    File.delete(jpg_path) if File.exist?(jpg_path)
  end

  # image must be png or jpg and below 1MB in file size
  def image_valid(image, ext)
    if ext != '.png' && ext != '.jpg'
      errors.add(:image, 'Invalid image type, must be PNG or JPG')
    elsif image.size > 1048576
      errors.add(:image, 'Image is too big, maximum file size 1MB')
    end
    errors.empty?
  end

  def save_image(image, prefix)
    ext = File.extname(image.original_filename)
    local_filename = get_image_path(prefix, ext)
    if image_valid(image, ext)
      delete_old_images(prefix)
      File.open(local_filename, 'wb') { |f| f.write(image.read) }
    end
  rescue
    errors.add(:image, 'Unknown failure')
  end

  def save_images
    return unless @image_sizes.present?
    @image_sizes.each_key { |size_key| save_image(@image_sizes[size_key], size_key) }
  end

  def image
    png_path = get_image_path('big', 'png')
    jpg_path = get_image_path('big', 'jpg')
    return png_path if File.exists?(png_path)
    return jpg_path if File.exists?(jpg_path)
    "/#{self.class.table_name}/Default.png"
  end
end