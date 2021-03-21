module VoteHelper
  def vote_links(votable)
    if user_signed_in? && !current_user.author_of?(votable)
      vote = votable.votes.find_by(user: current_user)
      disable_first = vote&.for?
      disable_second = vote&.against?
      vote_for = link_to('Vote for', polymorphic_path(votable, action: :vote_for),
                         class: 'vote-for', method: :post, remote: true, disabled: disable_first)
      vote_against = link_to('Vote against', polymorphic_path(votable, action: :vote_against),
                             class: 'vote-against', method: :post, remote: true, disabled: disable_second)
      safe_join([ content_tag(:p, vote_for), content_tag(:p, vote_against) ])
    end
  end
end
