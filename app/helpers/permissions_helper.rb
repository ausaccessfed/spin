module PermissionsHelper
  def permitted?(action)
    @subject && @subject.permits?(action)
  end
end
