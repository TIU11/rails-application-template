# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Type::EditorText, type: :model do

  # Define a test model. Subclass of self to namespace within this test.
  class self::ModelForType
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :notice, :editor_text
  end

  it "strip empty notices" do
    empty_notices = ['<p> </p>', '<p>&nbsp;</p>', '<p><br></p>', '<p>&nbsp;</p><p>&nbsp;</p>']
    empty_notices.each do |notice|
      model = self.class::ModelForType.new(notice: notice)
      expect(model.notice).to be_nil
    end
  end

end
