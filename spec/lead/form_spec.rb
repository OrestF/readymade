# frozen_string_literal: true

RSpec.describe Lead::Form do
  describe '#new' do
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
      instance = described_class.new(params, **args)

      expect(instance.respond_to?(:params)).to eq(true)
      expect(instance.respond_to?(:args)).to eq(true)
      expect(instance.respond_to?(:record)).to eq(true)
    end

    context 'without permitted_params' do
      it 'creates record, params and args attr_accessors' do
        instance = described_class.new(params, **args)

        expect(instance.params).to be_blank
      end
    end

    context 'without permitted_params' do
      let(:permitted) { %i[array struct] }

      it 'creates record, params and args attr_accessors' do
        instance = described_class.new(params, **args.merge!(permitted: permitted))

        expect(instance.params.keys).to match_array(permitted)
      end
    end

    context 'with required' do
      let(:required) { %i[array struct] }

      it 'creates record, params and args attr_accessors' do
        instance = described_class.new(params, **args.merge!(required: required))

        expect(instance.params.keys).to match_array(required)
      end
    end

    context 'without required' do
      let(:params) do
        {
          empty_value: nil
        }
      end

      let(:required) { %i[empty_value] }

      it 'creates record, params and args attr_accessors' do
        instance = described_class.new(params, **args.merge!(required: required))

        expect(instance.params.keys).to include(:empty_value)
        expect(instance.validate).to eq(false)
        expect(instance.errors.messages.keys).to match_array(%i[empty_value])
        expect(instance.errors.messages[:empty_value]).to match_array(["can't be blank"])
      end
    end
  end
end
