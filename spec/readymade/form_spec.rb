# frozen_string_literal: true

RSpec.describe Readymade::Form do
  describe '#new' do
    subject(:instance) { described_class.new(params, **args) }

    let(:params) do
      {
        string: 'some string',
        integer: rand(1..10),
        array: Array,
        struct: Struct.new(:test)
      }
    end

    let(:args) do
      {
        other_string: 'some other string',
        other_integer: rand(2..20),
        other_hash: Hash,
        other_struct: Struct.new(:other_test)
      }
    end

    it 'creates record, params and args attr_accessors' do
      expect(instance.respond_to?(:params)).to be(true)
      expect(instance.respond_to?(:args)).to be(true)
      expect(instance.respond_to?(:record)).to be(true)
    end
  end
end
