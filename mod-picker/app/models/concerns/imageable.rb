module Imageable
  extend ActiveSupport::Concern

  included do
    attr_writer :image_file

    after_save :save_image
  end

  def delete_old_images
    png_path = Rails.root.join('public', self.class.table_name, self.id.to_s + '.png')
    jpg_path = Rails.root.join('public', self.class.table_name, self.id.to_s + '.jpg')

    if File.exist?(png_path)
      File.delete(png_path)
    end
    if File.exist?(jpg_path)
      File.delete(jpg_path)
    end
  end

  def save_image
    if @image_file
      ext = File.extname(@image_file.original_filename)
      local_filename = Rails.root.join('public', self.class.table_name, self.id.to_s + ext)
      if ext != '.png' && ext != '.jpg' # image must be png or jpg
        self.errors.add(:image, 'Invalid image type, must be PNG or JPG')
      elsif @image_file.size > 1048576
        self.errors.add(:image, 'Image is too big')
      else
        begin
          self.delete_old_images
          File.open(local_filename, 'wb') do |f|
            f.write(@image_file.read)
          end
        rescue
          self.errors.add(:image, 'Unknown failure')
        end
      end
    end
  end

  def image
    table_name = self.class.table_name
    png_path = File.join(Rails.public_path, "#{table_name}/#{id}.png")
    jpg_path = File.join(Rails.public_path, "#{table_name}{/#{id}.jpg")
    if File.exists?(png_path)
      "/#{table_name}/#{id}.png"
    elsif File.exists?(jpg_path)
      "/#{table_name}/#{id}.jpg"
    else
      "/#{table_name}/Default.png"
    end
  end
end