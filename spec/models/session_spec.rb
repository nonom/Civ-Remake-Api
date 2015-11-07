require 'rails_helper'
require 'models/shared_examples/session_spec'
require 'models/shared_examples/modules_spec'
require 'models/helpers/session'

require 'models/shared_examples_spec'

RSpec.describe Session, type: :model do

  include_context 'include module Tokenable'

  context 'attributes' do
    it { should respond_to(:token) }
  end

  context 'unique indexes' do
    it { should have_db_index(:user_id).unique(true) }
    it { should have_db_index(:token).unique(true) }
  end

  context 'relationships' do
    it { should belong_to(:user) }
  end

  context 'validations' do
    it { should validate_presence_of(:user_id) }

    it { should validate_uniqueness_of(:token).allow_nil }
    it { should validate_uniqueness_of(:user_id) }

    # TODO: either write a custom validation for this or fix shoulda-matchers...
    # it { should validate_numericality_of(:user_id).only_integer.is_greater_than(0) }
  end

  context 'methods' do
    context '#create_token' do
      include_examples 'attribute_changed', :session, :token, :create_token, []
    end

    context '#update_token' do
      include_examples 'attribute_changed', :session, :token, :update_token, []
    end

    context '#destroy_token' do
      include_examples 'attribute_changed', :session, :token, :destroy_token, [], { desired_val: nil }
    end
  end
end
