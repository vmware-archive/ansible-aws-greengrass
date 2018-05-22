#greengrass-init

This role configures a minimum set of items in an existing AWS account to allow
the deployment of AWS Greengrass groups, cores, and devices.

### Requirements

A previously configured AWS CLI is required, with credentials already
configured with sufficient permissions to create AWS Greengrass objects.

This role uses the json_query filter which requires jmespath on the local
machine.

### Variables

The following configuration variables affect the operation of this role:

* ```greengrass_group_names```  List of greengrass groups to create.
* ```greengrass_device_stub``` Base name for devices to be created.
* ```greengrass_device_count``` Role will create this many devices, prepending
a number to the device_stub above.
* ```root_ca_checksum``` This is the checksum of the root CA used by Greengrass,
and should not change in most circumstances.
* ```greengrass_s3_bucket``` AWS S3 bucket to store generated Greengrass
configuration files.
* ```lambda_role```  Role document to allow Lambda execution, a typical
Greengrass feature.
* ```greengrass_service_role``` Role to allow Greengrass and IoT access.
* ```greengrass_core_policy``` Policy to be applied to Greengrass core (by
  default IoT and Greengrass is assumed).
* ```greengrass_device_policy``` Policy to applied to devices (again, IoT and
  Greengrass is default).

### Example Playbook

    - hosts: greengrass
      roles:
         - { role: vmware.greengress-init, greengrass_group_names: [g1, g2] }

### License

ASL-V2
