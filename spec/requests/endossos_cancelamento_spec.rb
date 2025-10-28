# spec/requests/apolices_spec.rb (somente o request spec)
require 'rails_helper'
require 'bigdecimal'
require 'bigdecimal/util'
require 'securerandom'

RSpec.describe 'Endossos', type: :request do

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [aumento_is]' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01
        }
      }

      post '/apolices',
           params: payload.to_json,
           headers: { 'Content-Type' => 'application/json' }

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: +350.00
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               tipo_endosso: 'cancelamento'
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }


      # deve ter revertido o valor do LMG ao valor original da apólice
      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['lmg'].to_d).to eq(1000.01.to_d)
    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [reducao_is]' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01
        }
      }

      post '/apolices',
           params: payload.to_json,
           headers: { 'Content-Type' => 'application/json' }

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: -350.00
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               tipo_endosso: 'cancelamento'
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }


      # deve ter revertido o valor do LMG ao valor original da apólice
      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['lmg'].to_d).to eq(1000.01.to_d)

    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [aumento_is_alteracao_vigencia]' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01
        }
      }

      post '/apolices',
           params: payload.to_json,
           headers: { 'Content-Type' => 'application/json' }

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: +350.00,
               fim_vigencia: (Date.today + 90).to_s
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               tipo_endosso: 'cancelamento'
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }


      # deve ter revertido o valor do LMG ao valor original da apólice
      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      # deve ter revertido o valor do fim_vigencia ao valor original da apólice
      expect(body['apolice']['fim_vigencia']).to eq((Date.today + 60).to_s)
      expect(body['apolice']['lmg'].to_d).to eq(1000.01)

    end
  end

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Criar endosso sobre uma apólice [reducao_is_alteracao_vigencia]' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01
        }
      }

      post '/apolices',
           params: payload.to_json,
           headers: { 'Content-Type' => 'application/json' }

      numero_endosso = SecureRandom.random_number(100_000..999_999)

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               numero: numero_endosso,
               importancia_segurada: -350.00,
               fim_vigencia: (Date.today + 90).to_s
             } }.to_json,
           headers: { 'Content-Type' => 'application/json' }

      post "/apolices/#{numero}/endossos",
           params: {
             endosso: {
               tipo_endosso: 'cancelamento'
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }


      # deve ter revertido o valor do LMG ao valor original da apólice
      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      # deve ter revertido o valor do fim_vigencia ao valor original da apólice
      expect(body['apolice']['fim_vigencia']).to eq((Date.today + 60).to_s)
      expect(body['apolice']['lmg'].to_d).to eq(1000.01)

    end
  end




end
