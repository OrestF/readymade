# frozen_string_literal: true

RSpec.describe Readymade::Response do
  describe '#new' do
    subject(:response) do |ex|
      described_class.new(ex.metadata[:status], **args)
    end

    let(:args) do
      {
        string: 'some string',
        integer: rand(1..10),
        array: Array,
        struct: Struct.new(:test)
      }
    end

    context 'when success', status: 'success' do
      it 'creates data object and status method' do
        expect(response.success?).to be(true)
        expect(response.fail?).to be(false)
        expect(response.custom_status?).to be(false)
        expect(response.data).to eq(args)
      end
    end

    context 'when success with hash argument', status: 'success' do
      it 'creates data object and status method' do
        expect(response.success?).to be(true)
        expect(response.fail?).to be(false)
        expect(response.custom_status?).to be(false)
        expect(response.data).to eq(args)
      end
    end

    context 'when fail', status: 'fail' do
      it 'creates data object and status method' do
        expect(response.success?).to be(false)
        expect(response.fail?).to be(true)
        expect(response.custom_status?).to be(false)
        expect(response.data).to eq(args)
      end
    end

    context 'when fail', status: 'custom_status' do
      it 'creates data object and status method' do
        expect(response.success?).to be(false)
        expect(response.fail?).to be(false)
        expect(response.custom_status?).to be(true)
        expect(response.data).to eq(args)
      end
    end
  end
end
