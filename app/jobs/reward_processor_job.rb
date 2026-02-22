class RewardProcessorJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[RewardProcessor] Starting reward processing..."

    pending_requests = RewardApplication.pending
    now = Time.current

    pending_requests.find_each do |request|
      process_request(request, now)
    end

    Rails.logger.info "[RewardProcessor] Completed reward processing."

    # Re-enqueue to run again in 30 minutes
    self.class.set(wait: 30.minutes).perform_later
  end

  private

  def process_request(request, now)
    # Find a receipt that exists and has NOT been used yet
    receipt = Receipt.find_by(receipt_no: request.receipt_no, used: false)

    if receipt
      # Auto-approve: valid, unused receipt found
      points = ((receipt.amount / 100).floor * 10).to_i
      ActiveRecord::Base.transaction do
        request.update!(
          status: 'approved',
          receipt_amount: receipt.amount,
          points_to_earn: points,
          processed_at: now,
          auto_approved: true
        )
        receipt.mark_as_used!
      end
      Rails.logger.info "[RewardProcessor] Auto-approved request ##{request.id} - #{points} points"
    elsif request.created_at <= 7.days.ago
      # Auto-reject: pending for more than 7 days
      request.update!(
        status: 'rejected',
        processed_at: now,
        auto_rejected: true,
        rejection_reason: 'Auto-rejected: Receipt not verified within 7 days'
      )
      Rails.logger.info "[RewardProcessor] Auto-rejected request ##{request.id} - exceeded 7 day limit"
    end
  rescue => e
    Rails.logger.error "[RewardProcessor] Error processing request ##{request.id}: #{e.message}"
  end
end
