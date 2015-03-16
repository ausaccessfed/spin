class SubjectsController < ApplicationController
  include CreateInvitation

  def index
    check_access!('admin:subjects:list')
    subjects_scope = Subject.all

    if params[:filter].present?
      subjects_scope = subjects_scope.filter(params[:filter])
    end

    @filter = params[:filter]
    @subjects =
      smart_listing_create(:subject, subjects_scope,
                           partial: 'subjects/listing',
                           default_sort: { name: 'asc' })
  end

  def show
    check_access!('admin:subjects:read')
    @object = Subject.find(params[:id])
  end

  def destroy
    check_access!('admin:subjects:delete')
    @object = Subject.find(params[:id])
    @object.destroy!

    flash[:success] = "Deleted user #{@object.name}"

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
