# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

# fluent-plugin-process-snmptrap

[Fluentd](https://fluentd.org/) filter plugin to do something.

This is a filter plugin for SNMP V2 traps. The plugin check the SNMP messages and maps the OID and associated values in SNMP Traps. 
It adds machineID, event, SNMP Trap type, host, status of machine, severity, device and message to events received. It detects the 
SNMP Traps based on the format <OID>:<Value>
The OID is of the format /SNMPv2-(\w+)(::)(\w+)((\.)(\d+)){1,13}/

Machin ID format 
HPE:<Coloregion>:<ChassisSerialNo>

Events detected:
Power ON
Power OFF

## Installation

### RubyGems

```
$ gem install fluent-plugin-process-snmptrap
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-process-snmptrap"
```

And then execute:

```
$ bundle
```

## Configuration

You can generate configuration template:

```
$ fluent-plugin-config-format filter process_snmptrap
```

<filter SNMPTrap.Alert>
   @type process_snmptrap
   HPEHostName ServerHostName
   coloregion <colo region>
   domain <domain>
</filter>



## Copyright

* Copyright(c) 2018- aj-rame3/Microsoft

## Trademarks 

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.
