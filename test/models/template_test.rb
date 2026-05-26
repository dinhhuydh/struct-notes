require "test_helper"

class TemplateTest < ActiveSupport::TestCase
  test "validates name presence" do
    template = Template.new(slug: "test", prompt_template: "test %{raw_notes}")
    assert_not template.valid?
    assert_includes template.errors[:name], "can't be blank"
  end

  test "validates slug uniqueness" do
    template = Template.new(name: "Duplicate", slug: "travel-experience", prompt_template: "test %{raw_notes}")
    assert_not template.valid?
    assert_includes template.errors[:slug], "has already been taken"
  end

  test "validates prompt_template presence" do
    template = Template.new(name: "Test", slug: "test")
    assert_not template.valid?
    assert_includes template.errors[:prompt_template], "can't be blank"
  end

  test "default_template returns template with is_default true" do
    default = Template.default_template
    assert_equal templates(:travel_experience), default
  end

  test "system_templates returns templates without user" do
    system = Template.system_templates
    system.each do |t|
      assert_nil t.user_id
    end
  end

  test "system? returns true when user_id is nil" do
    assert templates(:travel_experience).system?
  end
end
