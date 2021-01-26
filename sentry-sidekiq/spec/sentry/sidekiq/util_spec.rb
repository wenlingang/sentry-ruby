require 'spec_helper'

RSpec.describe Sentry::Sidekiq::Util do
  describe '.transaction_name_from_context' do
    subject(:transaction_name) { described_class.transaction_name_from_context(context) }

    context 'when the context is a job' do
      let(:context) { { 'class' => 'FooJob' } }

      it 'extracts the class' do
        expect(transaction_name).to eq('Sidekiq/FooJob')
      end
    end

    context 'when the context is a wrapped job' do
      let(:context) { { 'wrapped' => 'FooJob', 'class' => 'WrapperJob' } }

      it 'extracts the class' do
        expect(transaction_name).to eq('Sidekiq/FooJob')
      end
    end

    context 'when the context is a nested job' do
      let(:context) { { job: { 'class' => 'FooJob' } } }

      it 'extracts the class' do
        expect(transaction_name).to eq('Sidekiq/FooJob')
      end
    end

    context 'when the context is a wrapped nested job' do
      let(:context) { { job: { 'wrapped' => 'FooJob', 'class' => 'WrapperJob' } } }

      it 'extracts the class' do
        expect(transaction_name).to eq('Sidekiq/FooJob')
      end
    end

    context 'when the context is an event' do
      let(:context) { { event: 'startup' } }

      it 'extracts the class' do
        expect(transaction_name).to eq('Sidekiq/startup')
      end
    end

    context 'when the context is for something else' do
      let(:context) { { foo: 'bar' } }

      it 'extracts the class' do
        expect(transaction_name).to eq('Sidekiq')
      end
    end
  end
end
