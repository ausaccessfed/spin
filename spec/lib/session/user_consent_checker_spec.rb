require 'rails_helper'

module Session
  RSpec.describe UserConsentChecker do
    subject(:checker) { UserConsentChecker.new(app) }

    context 'requesting /auth/login directly' do
      let(:app) { double }
      let(:env) do
        { 'REQUEST_PATH' => '/auth/login' }
      end
      before { allow(app).to receive(:call).and_return('requested path') }

      it 'redirects to root' do
        expect(checker.call(env))
          .to eq([301, { 'Location' => '/', 'Content-Type' => 'text/html' },
                  []])
      end
    end

    context 'log in with consent' do
      let(:app) { double }
      let(:env) do
        { 'REQUEST_PATH' => '/auth/login',
          'rack.session' => { consent: true } }
      end
      before { allow(app).to receive(:call).and_return('requested path') }

      it 'follows to requested path' do
        expect(checker.call(env))
          .to eq('requested path')
      end
    end

    context 'navigating' do
      let(:app) { double }
      let(:env) { {} }
      before { allow(app).to receive(:call).and_return('requested path') }

      it 'follows to requested path' do
        expect(checker.call(env))
          .to eq('requested path')
      end
    end
  end
end
