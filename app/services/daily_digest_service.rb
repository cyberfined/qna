class DailyDigestService
  def send_digest
    User.find_each do |user|
      DailyDigestMailer.digest_email(user).deliver_later
    end
  end
end
