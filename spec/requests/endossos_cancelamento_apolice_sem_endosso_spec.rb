# spec/requests/endossos_cancelamento_apolice_sem_endosso_spec.rb (somente o request spec)
require 'rails_helper'
require 'bigdecimal'
require 'bigdecimal/util'
require 'securerandom'

RSpec.describe 'Apolice sem Endossos', type: :request do

  describe 'GET /apolices/:numero_apolice/endossos' do
    it 'Cancelar Endosso, de uma Apolice sem endosso e torna-la BAIXADA' do
      numero = SecureRandom.random_number(100_000..999_999)
      payload = {
        apolice: {
          numero: numero,
          data_emissao: Date.today.to_s,
          inicio_vigencia: (Date.today + 30).to_s,
          fim_vigencia: (Date.today + 60).to_s,
          importancia_segurada: 1000.01,
          lmg: 1000.00
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
               tipo_endosso: 'cancelamento'
             }
           }.to_json,
           headers: { 'Content-Type' => 'application/json' }


      # deve ter revertido o valor do LMG ao valor original da apólice
      get "/apolices/#{numero}", headers: { 'Accept' => 'application/json' }

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['apolice']['numero']).to eq(numero)
      expect(body['apolice']['importancia_segurada'].to_d).to eq(1000.01.to_d)
      expect(body['apolice']['lmg'].to_d).to eq(0)
      expect(body['apolice']['status']).to eq("BAIXADA")

    end
  end

end
