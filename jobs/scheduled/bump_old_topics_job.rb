# frozen_string_literal: true

module Jobs
  class BumpOldTopics < ::Jobs::Scheduled
    every 5.minutes
    sidekiq_options retry: false

    THRESHOLD_HOURS = 24
    TARGET_HOURS = 1
    BATCH_SIZE = 500

    def execute(args)
      Rails.logger.info("[BumpOldTopicsJob] Starting job at #{Time.zone.now}")

      threshold_time = THRESHOLD_HOURS.hours.ago
      target_time = TARGET_HOURS.hours.ago

      topic_ids_to_update = find_eligible_topic_ids(threshold_time)

      if topic_ids_to_update.empty?
        Rails.logger.info("[BumpOldTopicsJob] No topics found older than #{THRESHOLD_HOURS} hours. Exiting.")
        return
      end

      Rails.logger.info("[BumpOldTopicsJob] Found #{topic_ids_to_update.count} topics to be bumped.")

      total_updated = 0
      topic_ids_to_update.in_groups_of(BATCH_SIZE, false) do |batch_ids|
        updated_count = Topic.where(id: batch_ids).update_all(bumped_at: target_time)
        total_updated += updated_count
        Rails.logger.info("[BumpOldTopicsJob] Successfully bumped #{updated_count} topics in a batch.")
      end

      Rails.logger.info("[BumpOldTopicsJob] Finished job successfully. Total updated: #{total_updated}")
    end

    private

    def find_eligible_topic_ids(threshold_time)
      Topic.where("bumped_at <= ?", threshold_time)
           .where(archetype: Archetype.default)
           .where(visible: true)
           .where(closed: false)
           .where(archived: false)
           .pluck(:id)
    end
  end
end