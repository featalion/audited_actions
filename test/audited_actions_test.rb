require 'test_helper'

class AuditedActionsTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, AuditedActions
  end
end
