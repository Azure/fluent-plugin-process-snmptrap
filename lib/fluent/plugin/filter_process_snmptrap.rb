require 'fluent/plugin/filter'
require 'json'

module Fluent
  class ProcessSnmptrap < Filter
    Fluent::Plugin.register_filter('process_snmptrap', self)

    # config_param
    config_param :coloregion, :string
    # A set of character subsitution for cases in which they are invalid on the collector side.
    config_param :invalidChars, :hash, default: {'.'=>'_'}

    def configure(conf)
      super
    end

    def start
      super
    end

    def filter(tag, time, record)

      # Replace invalid characters
      fixedRecord = Hash.new
      record.each { |recKey, recValue|
          newKey = recKey
          invalidChars.each { |invalidKey, subChar|
              newKey = newKey.gsub(invalidKey, subChar)
          }
          record.delete(recKey)
          fixedRecord[newKey] = recValue
      }
      record.replace(fixedRecord)

      return record
    end


  end
end
