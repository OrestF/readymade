# frozen_string_literal: true

RSpec.describe Readymade::Action do
  describe '#new' do
    let(:args) do
      {
        string: 'some string',
        integer: rand(1..10),
        array: Array,
        struct: Struct.new(:test)
      }
    end

    describe '#new' do
      it 'creates instance variables from arguments' do
        instance = described_class.new(**args)

        args.each_key do |key|
          expect(instance.instance_variable_get("@#{key}")).to eq(args[key])
        end
        expect(instance.data).to eq(args)
      end

      context 'with hash as arguments' do
        it 'creates instance variables from arguments' do
          instance = described_class.new(args)

          args.each_key do |key|
            expect(instance.instance_variable_get("@#{key}")).to eq(args[key])
          end
          expect(instance.data).to eq(args)
        end
      end

      context 'without arguments' do
        it 'creates instance variables from arguments' do
          instance = described_class.new

          expect(instance.data).to be_empty
          expect(instance.args).to be_empty
        end
      end
    end

    describe '#call' do
      class TestCallMethod < Readymade::Action
        def call
          @args
        end
      end
      it 'creates instance variables from arguments' do
        expect(TestCallMethod.call(**args)).to eq(args)
      end

      context 'with hash as arguments' do
        it 'creates instance variables from arguments' do
          expect(TestCallMethod.call(args)).to eq(args)
        end
      end

      context 'without arguments' do
        it 'creates instance variables from arguments' do
          expect(TestCallMethod.call).to be_empty
        end
      end
    end

    describe '#call_async' do
      class TestCallMethod < Readymade::Action
        def call
          @args
        end
      end

      subject { TestCallMethod.call_async(**args) }

      it 'returns job_id' do
        expect(subject.class).to eq(Readymade::BackgroundJob)
        expect(subject.job_id.size).to eq(36)
        expect(*subject.arguments).to eq(args.merge!(class_name: TestCallMethod.name))
      end
    end
  end
end
