class HelpfulableController < ApplicationController
  def helpful
    @helpful_mark = HelpfulMark.find_or_create_by(
        submitted_by: current_user.id,
        helpfulable_id: params[:id],
        helpfulable_type: controller_name.classify)
    if params.has_key?(:helpful)
      @helpful_mark.helpful = params[:helpful]
      if @helpful_mark.save
        render json: {status: :ok}
      else
        render json: @helpful_mark.errors, status: :unprocessable_entity
      end
    else
      if @helpful_mark.destroy
        render json: {status: :ok}
      else
        render json: @helpful_mark.errors, status: :unprocessable_entity
      end
    end
  end
end