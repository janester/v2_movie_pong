
module MoviePong
  module Common
    module ClassMethods
      def create_or_find(id, params = nil)
        record = find_by_tmdb_id(id)
        return record if record.present?
        record = params ? params : retrieve_record_from_api(id)
        create(format_from_api(record))
      end

      def retrieve_record_from_api(id)
        MovieDb.send("get_#{to_s.downcase}", id)
      end

      def format_from_api(_response)
        fail "Implement Me!"
      end

      def association_method
        {
          Actor => "movies",
          Movie => "actors"
        }[self]
      end
    end

    module InstanceMethods
      def associated_records
        send(self.class.association_method)
      end

      def add_if_new(new_record)
        return if associated_records.include?(new_record)
        associated_records << new_record
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
