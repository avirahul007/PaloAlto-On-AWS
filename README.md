Deploy your Palo Alto Firewall hassle free using IaaC onto AWS
-------------------------------------------------------

0. PreRequisites:
-------------
 - Install Terraform on your source machine.
 - Copy your AWS access-key and secret-key from management console.

1. Code Description:
-----------------

  ```
      Palo-Alto_On_AWS/
      - fw.tf: Contains the definition of the various artifacts of the firewall and its dependent that will be deployed on AWS.
      - variables.tf: Define the various variables that will be required as inputs to the Terraform code.
      - terraform.tfvars: Defines default values for some of the variables.
      - main.tf: Defines the creation of S3 bucket with sub directories and required IAM roles with policy for bootstrap poll.
      - output.tf: Defines the output genrated by main.tf file for bucket_id and instance_profile_name.
      - init-cfg.txt.tmpl: Defines various fields required for intial configuration of Palo Alto Firewall. Some of the fields can be made optional depending upon your requirement.
      - check_fw.sh: Contains a script to probe pan.log and see if the firewall is booted up and ready to play.
      - aws_creds.tf: Contains your secrets, refer point # 2 for defining the secret.
  ```

  Note: 
      1. The variables.tf has default values provided for certain variables. These can be overridden by
         specifying those variables and values in the terraform.tfvars file.
      2. The bucket_id value can then be  used in a aws_instance resource to instantiate a VM-Series instance. It is used in the        user-data parameter. The instance_profile_name value is used in the iam_instance_profile parameter. Both are neeeded to define the location of the S3 bootstrap bucket and the permissions needed to access it.

2. Credentials Definition:
------------------------------

  - The structure of the ```aws_creds.tf``` file should be as follows:

    ```
        provider "aws" {
          access_key = "<access_key>"
          secret_key = "<secret_key>"
          region     = "${var.aws_region}"
        }
    ```

3. S3 bucket Configuration details:

  - S3 bucket will be created in the region of the infrastructure will be deployed to.
  - In the bucket, following sub-folders will be created:
    - ```config```
    - ```license```
    - ```software```
    - ```content```
  - We need to upload the required files under respective subfolders (like license, init-cfg.txt, content etc ) from the following link:
    ``` https://github.com/PaloAltoNetworks/aws/tree/master/two-tier-sample/bootstrap ```
    - Upload the ``` init-cfg.txt ``` files to the ``` config ``` folder.
    - Upload the ```panupv2-all-contents-695-4002``` file to the ``` content ``` folder.

Usage:
------
Commands should be run as per below order:

   run terraform: ```terraform init``` /n
   run terraform: ```terraform validate``` /n
   run terraform: ```terraform plan``` /n
   run terraform: ```terraform apply``` /n
   run terraform: ```terraform destroy```  ==> !!! CAUTION !!! IT WILL DESTROY THE COMPLETE CONFIGURATION /n
--------

Support:

This is just a draft verion, however actual deployment has still not been tested out. Any suggestion and improvement is always welcome.
#SupportCommunity #DevelopCommunity.
