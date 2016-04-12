module Helpfulable
  def self.handle(params, type)
    @helpful_mark = HelpfulMark.find(current_user.id, params[:id], type)
    if @helpful_mark
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
end