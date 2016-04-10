class AvatarsController < ApplicationController
  def delete_old_avatars
    jpg_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '.jpg')
    png_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '.png')

    File.delete(jpg_path) if File.exist?(jpg_path)
    File.delete(png_path) if File.exist?(png_path)
  end

  # POST /avatar
  def create
    if cannot? :set_avatar, current_user
      render json: {status: "Unauthorized"}
      return
    end

    response = 'Invalid submission'
    if params[:avatar].present?
      file = params[:avatar]
      # check image file type
      ext = File.extname(file.original_filename)
      local_filename = Rails.root.join('public', 'avatars', current_user.id.to_s + ext)
      if (ext != '.png') && (ext != '.jpg')
        response = 'Invalid image type, must be PNG or JPG'
      elsif file.size > 1048576 # 1 megabyte max file size
        response = 'Image is too big'
      else
        begin
          delete_old_avatars
          File.open(local_filename, 'wb') do |f|
            f.write(file.read)
          end
          response = 'Success'
        rescue
          response = 'Unknown failure'
        end
      end
    end

    # render json response
    render json: {status: response}
  end
end
