# frozen_string_literal: true

RSpec.describe Readymade::BackgroundBangJob do
  class DummyBang < Readymade::Action
    def call!
      Readymade::Response.new(:success, string: @string, integer: @integer, array: @array)
    end
  end

  let(:dummy_class) { DummyBang }
  let(:args) do
    {
      string: 'some string',
      integer: rand(1..10),
      array: Array,
    }
  end

  describe '#perform_later' do
    context 'without queue name' do
      it 'creates instance variables from arguments' do
        allow_any_instance_of(DummyBang).to receive(:call_async!).with(**args)

        res = described_class.perform_later(**args.merge!(class_name: dummy_class.name))

        expect(res.job_id.size).to eq(36)
        expect(res.queue_name).to eq('default')
      end
    end

    context 'with queue name' do
      it 'creates instance variables from arguments' do
        allow_any_instance_of(DummyBang).to receive(:call_async!).with(**args.merge!(queue_as: :test))

        res = described_class.perform_later(**args.merge!(class_name: dummy_class.name))

        expect(res.job_id.size).to eq(36)
        expect(res.queue_name).to eq('test')
      end
    end
  end
end
