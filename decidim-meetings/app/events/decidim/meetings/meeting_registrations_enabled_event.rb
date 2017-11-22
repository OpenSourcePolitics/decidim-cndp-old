# frozen-string_literal: true

module Decidim
  module Meetings
    class MeetingRegistrationsEnabledEvent < Decidim::Events::BaseEvent
      include Decidim::Events::EmailEvent
      include Decidim::Events::NotificationEvent

      def email_subject
        I18n.t(
          "decidim.meetings.events.meeting_registrations_enabled.email_subject",
          resource_title: resource_title
        )
      end

      def email_intro
        I18n.t(
          "decidim.meetings.events.meeting_registrations_enabled.email_intro",
          resource_title: resource_title
        )
      end

      def email_outro
        I18n.t(
          "decidim.meetings.events.meeting_registrations_enabled.email_outro",
          resource_title: resource_title
        )
      end

      def notification_title
        I18n.t(
          "decidim.meetings.events.meeting_registrations_enabled.notification_title",
          resource_title: resource_title,
          resource_path: resource_path
        ).html_safe
      end
    end
  end
end
