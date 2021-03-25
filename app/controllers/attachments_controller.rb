class AttachmentsController < ApplicationController
  before_action :authenticate_user!, only: :destroy

  expose :attachment, id: -> { params[:id] }, model: ActiveStorage::Attachment

  def destroy
    authorize!(:destroy, attachment)
    attachment.purge 
  end
end
