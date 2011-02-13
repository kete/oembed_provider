Factory.define :item do |f|
  f.sequence(:label) { |n| "a label#{n}"}
  f.sequence(:description) { |n| "a description#{n}"}
end

Factory.define :photo do |f|
  f.sequence(:title) { |n| "a title#{n}"}
  f.sequence(:url) { |n| "http://example.com/photo?id=#{n}"}
  f.sequence(:width) { |n| "600"}
  f.sequence(:height) { |n| "400"}
end
#   f.sequence(:author_name) { |n| "an author_name#{n}"}
#   f.sequence(:author_url) { |n| "http://example.com/author?id=#{n}"}

