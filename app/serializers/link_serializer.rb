class LinkSerializer < ActiveModel::Serializer
  attributes :id
  attribute :gist?, key: :gist

  def attributes(arg1, arg2)
    data = super(arg1, arg2)
    if data[:gist]
      data[:content] = object.gist_content
    else
      data[:title] = object.title
      data[:url] = object.url
    end
    data
  end
end
