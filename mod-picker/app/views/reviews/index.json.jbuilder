json.array!(@reviews) do |review|
  json.extract! review, :id, :submitted_by, :mod_id, :hidden, :rating1, :rating2, :rating3, :rating4, :TINYINT, :submitted, :edited, :text_body
  json.url review_url(review, format: :json)
end
