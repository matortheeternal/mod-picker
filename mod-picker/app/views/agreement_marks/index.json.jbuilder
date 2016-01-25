json.array!(@agreement_marks) do |agreement_mark|
  json.extract! agreement_mark, :id, :incorrect_note_id, :submitted_by, :agree
  json.url agreement_mark_url(agreement_mark, format: :json)
end
