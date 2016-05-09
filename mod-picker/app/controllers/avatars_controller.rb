class AvatarsController < ApplicationController
  def delete_old_avatars
    jpg_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '.jpg')
    jpg_medium_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '-m.jpg')
    jpg_small_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '-s.jpg')
    png_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '.png')
    png_medium_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '-m.png')
    png_small_path = Rails.root.join('public', 'avatars', current_user.id.to_s + '-s.png')

    File.delete(jpg_path) if File.exist?(jpg_path)
    File.delete(jpg_medium_path) if File.exist?(jpg_medium_path)
    File.delete(jpg_small_path) if File.exist?(jpg_small_path)
    File.delete(png_path) if File.exist?(png_path)
    File.delete(png_medium_path) if File.exist?(png_medium_path)
    File.delete(png_small_path) if File.exist?(png_small_path)
  end

  # POST /avatar
  def create
    authorize! :set_avatar, current_user

    response = 'Invalid submission'
    if params[:avatar].present?
      avatar = params[:avatar]
      # check image file type
      ext = File.extname(avatar[:big].original_filename)
      local_filename = Rails.root.join('public', 'avatars', current_user.id.to_s)
      if (ext != '.png') && (ext != '.jpg')
        response = 'Invalid image type, must be PNG or JPG'
      elsif avatar[:big].size > 262144 || # 256KB
          avatar[:medium].size > 131072 || # 128KB
          avatar[:small].size > 65536 # 64KB
        response = 'Image is too big'
      else
        begin
          delete_old_avatars

          # write big avatar
          File.open(local_filename + ext, 'wb') do |f|
            f.write(avatar[:big].read)
          end
          # write medium avatar
          File.open(local_filename + '-m' + ext, 'wb') do |f|
            f.write(avatar[:medium].read)
          end
          # write small avatar
          File.open(local_filename + '-s' + ext, 'wb') do |f|
            f.write(avatar[:small].read)
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
