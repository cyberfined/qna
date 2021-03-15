class AttachmentsController < ApplicationController
  before_action :authenticate_user!, only: :destroy

  expose :attachment, id: -> { params[:id] }, model: ActiveStorage::Attachment

  def destroy
    if current_user.author_of?(attachment.record)
      attachment.purge 
    else
      render file: Rails.root.join(Rails.public_path, "403.html"), status: :forbidden
    end
  end
end
