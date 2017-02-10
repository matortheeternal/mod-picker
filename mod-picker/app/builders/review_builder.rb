class ReviewBuilder < Builder
  # core
  def resource_class
    Review
  end

  def created_by_key
    "submitted_by"
  end

  def updated_by_key
    "edited_by"
  end

  # callbacks
  def before_update
    resource.clear_ratings
  end
end