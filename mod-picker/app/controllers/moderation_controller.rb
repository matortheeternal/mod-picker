class ModerationController < ApplicationController
  # GET /moderation_cp
  def index
    raise AccessDenied("You must be a moderator to access this resource.") unless current_user.can_moderate?
    render json: {
        unapproved: {
            curator_requests: CuratorRequest.eager_load(:mod).game(params[:game]).unapproved_count,
            reviews: Review.game(params[:game]).unapproved_count,
            compatibility_notes: CompatibilityNote.game(params[:game]).unapproved_count,
            install_order_notes: InstallOrderNote.game(params[:game]).unapproved_count,
            load_order_notes: LoadOrderNote.game(params[:game]).unapproved_count,
            mods: Mod.game(params[:game]).unapproved_count,
            help_pages: HelpPage.unapproved_count
        },
        unresolved_reports: BaseReport.unresolved_count
    }
  end
end