# frozen_string_literal: true

RSpec.describe Readymade::Action do
  describe '#new' do
    let(:args) do
      {
        string: 'some string',
        integer: rand(1..10),
        array: Array
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

    describe '#call_async!' do
      class TestCallMethod < Readymade::Action
        def call
          @args
        end
      end

      subject { TestCallMethod.call_async!(**args) }

      it 'returns job_id' do
        expect(subject.class).to eq(Readymade::BackgroundBangJob)
        expect(subject.job_id.size).to eq(36)
        expect(*subject.arguments).to eq(args.merge!(class_name: TestCallMethod.name))
      end
    end

    describe '#call!' do
      let(:success_response) { Readymade::Response.new(:success, **args) }

      context 'with success response' do
        class SuccessTestCallMethod < Readymade::Action
          def call!
            @args

            Readymade::Response.new(:success, **@args)
          end
        end

        it 'creates instance variables from arguments' do
          SuccessTestCallMethod.call!(**args).then do |res|
            expect(res).to be_success
            expect(res.data).to eq(success_response.data)
          end
        end

        context 'with hash as arguments' do
          it 'creates instance variables from arguments' do
            SuccessTestCallMethod.call!(args).then do |res|
              expect(res).to be_success
              expect(res.data).to eq(success_response.data)
            end
          end
        end

        context 'without arguments' do
          it 'creates instance variables from arguments' do
            expect(SuccessTestCallMethod.call!).to be_kind_of(Readymade::Response)
          end
        end
      end

      context 'with fail response' do
        class FailTestCallMethod < Readymade::Action
          def call!
            @args

            Readymade::Response.new(:fail, **@args)
          end
        end

        it 'creates instance variables from arguments' do
          expect { FailTestCallMethod.call!(**args) }.to raise_error Readymade::Action::UnSuccessError
        end

        context 'with hash as arguments' do
          it 'creates instance variables from arguments' do
            expect { FailTestCallMethod.call!(args) }.to raise_error Readymade::Action::UnSuccessError
          end
        end

        context 'without arguments' do
          it 'creates instance variables from arguments' do
            expect { FailTestCallMethod.call! }.to raise_error Readymade::Action::UnSuccessError
          end
        end
      end

      context 'with consider_success' do
        class ConsiderSuccessTestCallMethod < Readymade::Action
          def call!
            @args

            Readymade::Response.new(:my_status, **@args.merge!(consider_success: true))
          end
        end

        it 'does not raise UnSuccess error' do
          expect(ConsiderSuccessTestCallMethod.call!(**args)).to be_kind_of(Readymade::Response)
        end

        context 'with hash as arguments' do
          it 'does not raise UnSuccess error' do
            expect(ConsiderSuccessTestCallMethod.call!(args)).to be_kind_of(Readymade::Response)
          end
        end

        context 'without arguments' do
          it 'does not raise UnSuccess error' do
            expect(ConsiderSuccessTestCallMethod.call!).to be_kind_of(Readymade::Response)
          end
        end
      end
    end
  end
end
