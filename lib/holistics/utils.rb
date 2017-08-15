module Holistics
  module Utils
    class << self
      COLORIZE_MAPPING = {
        green: %w{active success ok},
        red: %w{fail failure error cancelled},
        yellow: %w{new running pending unknown}
      }
      def colorize(text)
        color = COLORIZE_MAPPING.find { |color, values| values.include?(text) }
        color ? text.method(color[0]).call : text
      end
      def duration secs
        [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map{ |count, name|
          if secs > 0
            secs, n = secs.divmod(count)
            "#{n.to_i} #{name}"
          end
        }.compact.reverse.join(' ')
      end
    end
  end
end