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
    it 'creates instance variables from arguments' do
      res = described_class.perform_later(**args.merge!(class_name: dummy_class.name))

      expect(res.job_id.size).to eq(36)
      expect(res.queue_name).to eq('default')
    end
  end
end
