module SenderVerifiable

  extend ActiveSupport::Concern

  included do
    before_action :set_signature_base64
    before_action :set_certificate_pem
  end

  private

  def set_signature_base64
    @signature_base64 = params[:signature]
  end

  def set_certificate_pem
    @certificate_pem = params[:certificate]
  end

  def ensure_signature_and_certificate
    unless @signature_base64 && @certificate_pem
      render json: { errors: ['Signature and certificate are required'] }, status: :unprocessable_entity
    end
  end

end