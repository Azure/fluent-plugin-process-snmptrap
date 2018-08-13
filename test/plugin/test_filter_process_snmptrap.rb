require "fluent/test"
require "fluent/test/driver/filter"
require "fluent/test/helpers"
require "/etc/fluent/plugin/filter_process_snmptrap.rb"

class ProcessSnmptrapFilterTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  setup do
    Fluent::Test.setup
  end

  CONFIG = %[
    @type process_snmptrap
    HPEHostName HPETesthost
    coloregion testcolo
    domain hpetestdomain
  ]


  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::ProcessSnmptrap).configure(conf)
  end

  def test_configure
      d = create_driver(CONFIG)
      assert_equal 'testcolo', d.instance.coloregion
      assert_equal 'hpetestdomain', d.instance.domain
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
                "SNMPv2-MIB::sysUpTime.0":"43 days, 21:28:56.10","SNMPv2-MIB::snmpTrapOID.0":"SNMPv2-SMI::enterprises.59.3.800.100.20.3","SNMPv2-SMI::enterprises.59.3.800.10.10.1.1":"UV300-00000550","SNMPv2-SMI::enterprises.59.3.800.10.30.1.1":"r001i01b","SNMPv2-SMI::enterprises.59.3.800.30.10.1.1":"SYSPOWERSTATE","SNMPv2-SMI::enterprises.59.3.800.30.10.1.2":"0x0","SNMPv2-SMI::enterprises.59.3.800.30.10.1.4":"18","host":"192.168.254.61"
        }
    ]
    filtered_records = filter(records)
    assert_equal records[0]['message'], filtered_records[0]['message']
    assert_equal 'HPE:testcolo:UV300-00000550', filtered_records[0]['machineId']
    assert_equal 'Server Power ON', filtered_records[0]['event']
    assert_equal 'on', filtered_records[0]['status']
    assert_equal 'SYSPOWERSTATE', filtered_records[0]['type']
    assert_equal 'info', filtered_records[0]['severity']
    assert_equal '0x0', filtered_records[0]['device']
    assert_equal '', filtered_records[0]['error']
  end


  def test_poweron_filter
    records = [
        {
                "SNMPv2-MIB::sysUpTime.0":"43 days, 21:28:56.10","SNMPv2-MIB::snmpTrapOID.0":"SNMPv2-SMI::enterprises.59.3.800.100.20.3","SNMPv2-SMI::enterprises.59.3.800.10.10.1.1":"UV300-00000550","SNMPv2-SMI::enterprises.59.3.800.10.30.1.1":"r001i01b","SNMPv2-SMI::enterprises.59.3.800.30.10.1.1":"SYSPOWERSTATE","SNMPv2-SMI::enterprises.59.3.800.30.10.1.2":"0x0","SNMPv2-SMI::enterprises.59.3.800.30.10.1.4":"19","host":"192.168.254.61"
        }
    ]
    filtered_records = filter(records)
    assert_equal records[0]['message'], filtered_records[0]['message']
    assert_equal 'HPE:testcolo:UV300-00000550', filtered_records[0]['machineId']
    assert_equal 'Server Power OFF', filtered_records[0]['event']
    assert_equal 'on', filtered_records[0]['status']
    assert_equal 'SYSPOWERSTATE', filtered_records[0]['type']
    assert_equal 'info', filtered_records[0]['severity']
    assert_equal '0x0', filtered_records[0]['device']
    assert_equal '', filtered_records[0]['error']
  end
end

