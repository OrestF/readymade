# frozen_string_literal: true

RSpec.describe Readymade::Form::FormOptions do
  class TestForm < Readymade::Form
    PERMITTED_ATTRIBUTES = %i[attr1 attr2 attr3]
    REQUIRED_ATTRIBUTES = %i[attr1 attr3]
  end

  class TestFormWithFormOptions < Readymade::Form
    PERMITTED_ATTRIBUTES = %i[attr1 attr2 attr3]
    REQUIRED_ATTRIBUTES = %i[attr1 attr3]

    def form_options
      {
        attr1: [1,2,3],
        passed_argument: args[:passed_argument]
      }
    end
  end

  let(:args) do
    {
      attr1: [1,2,3],
      attr2: 'attr two',
      attr3: 'attr three',
      passed_argument: 'passed_argument'
    }
  end

  describe '#to_h' do
    context 'with undefined form_options' do
      it 'raises an error' do
        instance = TestForm.form_options(**args)

        expect { instance[:attr1] }.to raise_error(Readymade::Error)
      end
    end

    context 'with defined form_options' do
      it 'creates args keys' do
        instance = TestFormWithFormOptions.form_options(**args)

        expect(instance[:attr1]).to eq(args[:attr1])
        expect(instance[:passed_argument]).to eq('passed_argument')
        expect(instance[:attr2]).to eq(nil)
        expect(instance[:attr3]).to eq(nil)
      end
    end
  end

  describe '#required?' do
    it 'returns boolean' do
      instance = TestForm.form_options(**args)

      expect(instance.required?(:attr1)).to eq(true)
      expect(instance.required?(:attr2)).to eq(false)
      expect(instance.required?(:attr3)).to eq(true)
    end
  end
end
