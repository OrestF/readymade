# frozen_string_literal: true

RSpec.describe Lead::Response do
  describe '#new' do
    let(:args) do
      {
        string: 'some string',
        integer: rand(1..10),
        array: Array,
        struct: Struct.new(:test)
      }
    end

    context 'success' do
      let(:status) { 'success' }

      it 'creates data object and status method' do
        response = described_class.new(status, **args)

        expect(response.success?).to eq(true)
        expect(response.fail?).to eq(false)
        expect(response.custom_status?).to eq(false)
        expect(response.data).to eq(args)
      end
    end

    context 'fail' do
      let(:status) { 'fail' }

      it 'creates data object and status method' do
        response = described_class.new(status, **args)

        expect(response.success?).to eq(false)
        expect(response.fail?).to eq(true)
        expect(response.custom_status?).to eq(false)
        expect(response.data).to eq(args)
      end
    end

    context 'fail' do
      let(:status) { 'custom_status' }

      it 'creates data object and status method' do
        response = described_class.new(status, **args)

        expect(response.success?).to eq(false)
        expect(response.fail?).to eq(false)
        expect(response.custom_status?).to eq(true)
        expect(response.data).to eq(args)
      end
    end
  end
end
