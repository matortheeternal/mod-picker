class ModerationController < ApplicationController
  # GET /moderation_cp
  def index
    raise AccessDenied("You must be a moderator to access this resource.") unless current_user.can_moderate?
    render json: {
        unapproved: {
            curator_requests: CuratorRequest.unapproved_count,
            reviews: Review.unapproved_count,
            compatibility_notes: CompatibilityNote.unapproved_count,
            install_order_notes: InstallOrderNote.unapproved_count,
            load_order_notes: LoadOrderNote.unapproved_count,
            mods: Mod.unapproved_count,
            help_pages: HelpPage.unapproved_count
        },
        unresolved_reports: BaseReport.unresolved_count
    }
  end
end