json.array!(@reviews) do |review|
  json.extract! review, :id, :r_id, :submitted_by, :mod_id, :hidden, :rating1, :TINYINT, :rating2, :TINYINT, :rating3, :TINYINT, :rating4, :TINYINT, :rating5, :TINYINT, :submitted, :edited
  json.url review_url(review, format: :json)
end
