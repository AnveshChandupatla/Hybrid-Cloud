# Hybrid-Cloud Task

Create a web portal with all the security as much as possible.

So, we use WordPress software with dedicated database server.
Database should not be accessible from the outside world for security purposes.
We only need to public the WordPress to clients.

Steps to be followed:
1) Write a Infrastructure as code using Terraform, which automatically create a VPC.

2) In that VPC we have to create 2 subnets:

  a) public subnet [ Accessible for Public World! ] 

  b) private subnet [ Restricted for Public World! ]

3) Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.

4) Create a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.

5) Launch an EC2 instance which has WordPress setup already having the security group allowing port 80 so that our client can connect to our WordPress site.

Also attach the key to instance for further login into it.

6) Launch an EC2 instance which has MySQL setup already with security group allowing port 3306 in private subnet so that our WordPress VM can connect with the same. Also attach the key with the same.

Note: WordPress instance has to be part of public subnet so that our client can connect our site and MySQL instance has to be part of private sub net so that the outside world can’t connect to it.
