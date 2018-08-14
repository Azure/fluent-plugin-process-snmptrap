require 'fluent/plugin/filter'

module Fluent
  class ProcessSnmptrap < Filter
    Fluent::Plugin.register_filter('process_snmptrap', self)

    # config_param
    config_param :coloregion, :string

    @@snmptrapOid = "SNMPv2-MIB::snmpTrapOID.0"
    @@rmcSerialNum = "SNMPv2-SMI::enterprises.59.3.800.10.10.1.1"
    @@chassisBMCId = "SNMPv2-SMI::enterprises.59.3.800.10.30.1.1"
    @@type = "SNMPv2-SMI::enterprises.59.3.800.30.10.1.1"
    @@status = "SNMPv2-SMI::enterprises.59.3.800.30.10.1.4"
    @@device = "SNMPv2-SMI::enterprises.59.3.800.30.10.1.2"
    @@host = "host"
    @@serverPowerUp = "Server Power ON"
    @@serverPowerDown = "Server Power OFF"

    def configure(conf)
      super
    end

    def start
      super
    end

    def filter(tag, time, record)
      message = record.to_s
      message = message.delete('\\"')
      snmp_msg = message.gsub(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, "")
      record["machineId"] = ""
      record["rmc_host"] = ""
      record["event"] = ""
      record["status"] = ""
      record["type"] = ""
      record["severity"] = ""
      record["device"] = ""
      record["error"] = ""
      record["message"] = ""
      record["timestamp"] = ""

      determineMachineId(record)
      getrmchost(record)
      processEvent(record)
      determineDevice(record)
      record["status"] = determineStatus(record)
      record["message"] = snmp_msg
      record["timestamp"] = time
      record.delete_if { |key, value| key.to_s.match(/(?:SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}|(host))/)}
      return record

    end

    def determineMachineId(record)
      rmcSerialNo = record[@@rmcSerialNum].to_s
      if rmcSerialNo.nil?
        record["error"] = "Cannot determine Machine ID"
        return
      end
      record["machineId"] = "HPE:#{coloregion}:#{rmcSerialNo}"
    end


    def processEvent(record)
      record["severity"] = "info"
      event = determineEvent(record)
      if !event.nil?
        record["event"] = event
      else record["error"] = "Cannot determine the event"
      end
    end

    def getrmchost(record)
      rmc_host = record[@@host]
      if rmc_host.nil?
        record["error"] = "cannot Determine the host IP"
      end
      record["rmc_host"] = rmc_host
    end

    def determineDevice(record)
      record["device"] = record[@@device]
    end

    def determineStatus(record)
      status_array = ["unavailable", "ok", "LowerNonrecoverable", "LowerCritical", "LowerNonCritical","UpperNonCritical", "UpperCritical",
                      "UpperNonRecoverable", "notPresent", "failed", "redundant", "degraded", "nonRedundant", "lost", "enabled", "disabled",
                      "deviceAbsent", "devicePresent", "on", "off", "asserted", "deasserted", "limitNotExceeded", "limitExceeded"]
      get_status = record[@@status].to_i
      status = status_array[get_status]
      return status
    end


    def determineEvent(record)
      type = record[@@type]
      record["type"] = type
      record["status"] =
      case type
        when "SYSPOWERSTATE"
          if record[@@status].to_s == "18"
            event = @@serverPowerUp
          elsif record[@@status].to_s == "19"
            event = @@serverPowerDown
          else
            record["error"] = "Unknown Status"
          end
        else
          event = "Chassis Sensor Event"
        end
      event
    end
  end
end

