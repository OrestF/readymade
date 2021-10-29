# frozen_string_literal: true

RSpec.describe Virgin::Action do
  describe '#new' do
    let(:args) do
      {
        string: 'some string',
        integer: rand(1..10),
        array: Array,
        struct: Struct.new(:test)
      }
    end

    it 'creates instance variables from arguments' do
      instance = described_class.new(**args)

      args.each_key do |key|
        expect(instance.instance_variable_get("@#{key}")).to eq(args[key])
      end
      expect(instance.data).to eq(args)
    end
  end
end
