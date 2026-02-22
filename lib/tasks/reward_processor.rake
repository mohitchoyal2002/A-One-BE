namespace :rewards do
  desc "Start the background reward processor (auto-verify receipts, auto-reject stale requests)"
  task process: :environment do
    puts "Starting Reward Processor..."
    puts "Processing pending reward requests every 30 minutes."
    puts "Press Ctrl+C to stop."

    loop do
      begin
        RewardProcessorJob.perform_now
      rescue => e
        Rails.logger.error "[RewardProcessor] Error: #{e.message}"
        puts "Error: #{e.message}"
      end

      sleep 1800  # 30 minutes
    end
  end

  desc "Run reward processor once (one-shot)"
  task process_once: :environment do
    puts "Running Reward Processor (one-shot)..."
    RewardProcessorJob.perform_now
    puts "Done."
  end
end
