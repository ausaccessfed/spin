class SubjectsController < ApplicationController
  include CreateInvitation

  def index
    check_access!('admin:subjects:list')
    @objects = Subject.all
  end

  def show
    check_access!('admin:subjects:read')
    @object = Subject.find(params[:id])
  end

  def destroy
    check_access!('admin:subjects:delete')
    @object = Subject.find(params[:id])
    @object.destroy!

    flash[:success] = "Deleted subject #{@object.name}"

    redirect_to(subjects_path)
  end

  def resend_invite
    check_access!('admin:subjects:read')
    subject = Subject.find(params[:id])
    deliver(subject.invitations.first)
    flash[:success] = "Sent email to #{subject.mail}"
    redirect_to(subject_path(subject))
  end
end
