# frozen_string_literal: true

RSpec.describe Readymade::BackgroundJob do
  class Dummy < Readymade::Action
  end

  let(:dummy_class) { Dummy }
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
        allow_any_instance_of(Dummy).to receive(:call_async).with(**args)

        res = described_class.perform_later(**args.merge!(class_name: dummy_class.name))

        expect(res.job_id.size).to eq(36)
        expect(res.queue_name).to eq('default')
      end
    end

    context 'with queue name' do
      it 'creates instance variables from arguments' do
        allow_any_instance_of(Dummy).to receive(:call_async).with(**args.merge!(queue_as: :test))

        res = described_class.perform_later(**args.merge!(class_name: dummy_class.name))

        expect(res.job_id.size).to eq(36)
        expect(res.queue_name).to eq('test')
      end

      context 'when as job options provided' do
        it 'uses the provided job options' do
          job_options = { queue_as: :test }
          allow_any_instance_of(Dummy).to receive(:call_async).with(**args.merge!(job_options: job_options))

          res = described_class.perform_later(**args.merge!(class_name: dummy_class.name, job_options: job_options))
          expect(res.job_id.size).to eq(36)
          expect(res.queue_name).to eq('test')
          expect(res.arguments.first[:job_options]).to eq(job_options)
        end
      end
    end
  end
end
