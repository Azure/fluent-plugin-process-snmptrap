require "fluent/test"
require "fluent/test/driver/filter"
require "fluent/test/helpers"
require "fluent/plugin/filter_process_snmptrap.rb"

class ProcessSnmptrapFilterTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
    @type process_snmptrap
    coloregion testcolo
    invalidChars {".":"_", "-":"_", "::":"_"}
  ]


  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::ProcessSnmptrap).configure(conf)
  end

  def test_configure
      d = create_driver(CONFIG)
      assert_equal 'testcolo', d.instance.coloregion
  end

  def filter(records, conf = CONFIG)
      d = create_driver(conf)
      d.run(default_tag: "TestTrap") do
         records.each do |record|
             d.feed(record)
         end
      end
      d.filtered_records
  end


  def test_snmptrap_filter
    records = [
        {
            "SNMPv2-MIB::sysUpTime.0"=>"179 days,13:26:54.66",
            "SNMPv2-MIB::snmpTrapOID.0"=>"SGI-UV300::chassisSensor",
            "SGI-UV300::ssnName"=>"UV300-00000547",
            "SGI-UV300::chassisName"=>"r001i24b",
            "SGI-UV300::chassisSensorName"=>"PSU2_COMP_TEMP1",
            "SGI-UV300::chassisSensorValue"=>"10.3289",
            "SGI-UV300::chassisSensorStatus"=>"1",
            "host"=>"172.17.0.2"
        }
    ]
    filtered_records = filter(records)
    assert_equal(records[0].length, filtered_records[0].length, "Incorrect record size")
    assert_equal(records[0]["host"], filtered_records[0]["host"], "Non MIB value was modified")
    # Values should remain unmodified.
    records.each { |recKey, recValue|
        fixedKey = recKey.to_s.gsub("-","_").gsub(".","_").gsub("::","_")
        assert_equal(records[0][recKey], filtered_records[0][fixedKey], "Value has been modified")
    }
  end

end

