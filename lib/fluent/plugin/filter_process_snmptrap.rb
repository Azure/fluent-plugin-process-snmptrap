require 'fluent/plugin/filter'
require 'json'

module Fluent
  class ProcessSnmptrap < Filter
    Fluent::Plugin.register_filter('process_snmptrap', self)

    # config_param
    config_param :coloregion, :string

    #object identifiers outlined in /usr/share/snmp/mibs/sgi-uv300-smi.mib
    @@snmptrapOid = "SNMPv2-MIB::snmpTrapOID.0"
    @@rmcSerialNum = "SNMPv2-SMI::enterprises.59.3.800.10.10.1.1"
    @@chassisBMCId = "SNMPv2-SMI::enterprises.59.3.800.10.30.1.1"
    @@device = "SNMPv2-SMI::enterprises.59.3.800.30.10.1.1"
    @@status = "SNMPv2-SMI::enterprises.59.3.800.30.10.1.4"
    @@sensorValue = "SNMPv2-SMI::enterprises.59.3.800.30.10.1.2"
    @@host = "host"
    @@serverPowerUp = "Server Power ON"
    @@serverPowerDown = "Server Power OFF"
    ChassisSensorEvent = "Chassis Sensor Event"
    ServerPowerUp = 18
    ServerPowerDown = 19
    #mib labels for object identifiers outlined in 
    #/usr/share/snmp/mibs/sgi-uv300-smi.mib
    #possible values for chassisSensorTraps
    Status_array = ["unavailable", "ok", "LowerNonrecoverable", "LowerCritical", "LowerNonCritical","UpperNonCritical", "UpperCritical",
    "UpperNonRecoverable", "notPresent", "failed", "redundant", "degraded", 
    "nonRedundant", "lost", "enabled", "disabled",
    "deviceAbsent", "devicePresent", "on", "off", "asserted", "deasserted", 
    "limitNotExceeded", "limitExceeded"]

    def configure(conf)
      super
    end

    def start
      super
    end

    def filter(tag, time, record)
      @time = time
      @tag = tag
      message = record.to_s
      message = message.delete('\\"')
      snmp_msg = message.gsub(/(?:(SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}(=>))|(host=>))/, "")
      record["machineId"] = ""
      record["rmcHostIP"] = ""
      record["event"] = ""
      record["status"] = ""
      record["device"] = ""
      record["severity"] = ""
      record["sensorValue"] = ""
      record["error"] = ""
      record["message"] = ""
      record["timestamp"] = ""

      determineMachineId(record)
      getrmcHost(record)
      processEvent(record)
      determineSensorValue(record)
      determineStatus(record)
      makeMessage(record)
      record["timestamp"] = time
      record.delete_if { |key, value| key.to_s.match(/(?:SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}|(host))/)}
      return record
    end

    def makeMessage(record)
      message = 
      {
        :timestamp => @time,
        :source => "snmp",
        :host => record[@@host],
        :device => record[@@device],
        :status => record[@@status],
      }
      record["message"] = message.to_json
    end

    def determineMachineId(record)
      rmcSerialNo = record[@@rmcSerialNum].to_s
      if rmcSerialNo.nil?
        record["error"] << " : Can not determine Machine ID"
        return
      end
      record["machineId"] = "HPE:#{coloregion}:#{rmcSerialNo}"
    end

    def processEvent(record)
      record["severity"] = "info"
      determineEvent(record)
      if record["event"].nil?
        record["error"] << " : Can not determine the event"
      end
    end

    def getrmcHost(record)
      host = record[@@host]
      if host.nil?
        record["error"] << " : Can not Determine the host IP"
      end
      record["rmcHostIP"] = host
    end

    def determineSensorValue(record)
      record["sensorValue"] = record[@@sensorValue]
    end

    def determineStatus(record)
      get_status = record[@@status].to_i
      status = Status_array[get_status]
      record["status"] = status
    end

    def determineEvent(record)
      device = record[@@device]
      record["device"] = device
      if device == "SYSPOWERSTATE"
        if record[@@status].to_s == ServerPowerUp
          event = @@serverPowerUp
        elsif record[@@status].to_s == ServerPowerDown
          event = @@serverPowerDown
        else
          record["error"] << " : Unknown Status"
        end
      else
        event = ChassisSensorEvent
      end
      record["event"] = event
    end
  end
end
