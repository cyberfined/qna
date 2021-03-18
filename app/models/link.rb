require 'octokit'
require 'uri'

class Link < ApplicationRecord
  URL_REGEXP = /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?\z/ix
  GIST_REGEXP = /\Ahttps:\/\/gist\.github\.com\/\w+\/\w+(\/)?\z/ix

  GistFile = Struct.new(:filename, :content)

  belongs_to :linkable, polymorphic: true

  validates :title, presence: true
  validates :url, presence: true, format: URL_REGEXP

  def gist?
    url =~ GIST_REGEXP
  end

  def gist_content
    raise ArgumentError, 'link must follow to a gist' unless gist?

    gist = Octokit::Client.new.gist(gist_id)
    gist.files.map { |_,f| GistFile.new(f.filename, f.content) }
  end

  private

  def gist_id
    URI(url).path.split('/').last
  end
end
