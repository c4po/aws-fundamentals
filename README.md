# aws-fundamentals


# Objective

Using a base Amazon Machine Image (AMI) of your choice, either based on Linux or Windows, create a running EC2 instance to meet the following objectives:

  * The instance should  be of type t2.micro
  * The instance should reside within region us-west-2
  * The instance should use a 1 GB attached EBS volume and contain a valid partition table with one partition. The partition should contain a valid file system.
  * The filesystem residing on the EBS volume should be mounted automatically upon reboot of the EC2 instance.
  * The instance should serve web pages via an appropriate service such as apache or IIS. This service should start automatically upon boot.
  * The instance should serve a web page index.html containing the text "Hello AWS World". This file should reside on the filesystem within the EBS volume and be served from the Document Root directory. 
  * The instance should effectively use security groups to restrict traffic to HTTP and either RDP or SSH
  * The instance should be associated with an Elastic IP (EIP) address 
