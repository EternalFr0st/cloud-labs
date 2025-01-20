# Setup infrasturcture

Originally lab developed by Mai Do https://github.com/maiyuki .

## Assignment Part 1 - Networking

Manual setup infrastructure which includes networking, web servers, load balancing, and other necessary components.

For every configuration you do in Openstack there is a description that will explain the configuration. Read them to get a better understanding.

### Create a Key pair

Create a keypair on your machine and import the public key into Openstack. 

You can also create the keypair in Openstack and download the private key. This is considered less secure.

### Setup Network, Subnet, Router

Setup a Network with a Subnet and Router:
You can leave the configuration default, but highly recommend customizing it to understand how it works, how it looks.

- Network
    - name: `<name>_network`
- Subnet
    - name: `<name>_subnet`
    - range: `10.0.x.0/24`
    - dns: `8.8.8.8` and `8.8.4.4`

And you *MUST* add the router and select the external network. There should only be one external network.

### Security Groups

Create a Security Group with Rules for your Bastion host.

- Name: `<name>-bastion-sg`
- Create rule: Allow SSH from the Internet and a description

### Create a Bastion host

A Bastion host / Proxy server and allows the client machines to connect to the remote server.

- Instance
    - Name: `<name>-bastion-<az>` // ex. mai-bastion-sto1
    - AZ: Choose any zone
    - Boot Source: `Image`
    - Choose an Image (You will need to find what the default username is for the image you choose.)
    - Flavor: `m1.small`
    - Network: The Network you created in the earlier steps
    - Security Groups: The Security Group you created in the earlier steps
    - Key Pair: The key pair you created in the earlier steps
    - User Data: 
        ```
        #cloud-config
        final_message: "The system is finally up, after $UPTIME seconds"
        ```
    - Metadata: Add a Custom one. Ex: "Image used" : "ubuntu-20.04-server-latest"


### Floating IP

To be able to reach the Bastion host, we need a Floating IP.

- Allocate a Floating IP from a given floating IP pool
- Associate the IP with your Subnet's port

### View the Network Topology

You should be able to see your created resources in the topology. Have a look around and explain "to a rubber duck" how traffic flows to your instance.

### View Instance Log

Head to Instance and View Log on your instance. You will see the message from User Data.

### SSH into Bastion host

- Change permissions on your key on your local host to rw for user
- `ssh <username>@<floating-ip> -i <key>`

Pro tip!
- Add you key to SSH authentication agent `ssh-add <key>`
- `ssh <username>@<floating-ip>`

## Assignment Part 2 -  Web server and Load balancing

### Security Groups

Create a Security Group with Rules for your Web Servers.

- Name: `<name>-web-server-sg`
- Create rule: Allow SSH from the Bastion Security Group and a description
- Create rule: Allow HTTP from the Internet and a description

### Create a Web Server

Create a new Instance and make sure you can SSH to it only from Bastion host.

- Instance:
    - Name: `<name>-web-<number>` // ex. jonas-web-1
    - AZ: Choose any zone
    - Boot Source: `Image`
    - Choose an Image (You will need to find what the default username is for the image you choose.)
    - Flavor: `m1.small`
    - Network: The Network you created in the earlier steps
    - Security Groups: The Security Group you created for the web server
    - Key Pair: The key pair you created in the earlier steps
    - User Data: 
        ```
        #cloud-config
        package_update: true
        package_upgrade: true
        packages:
        - python3-minimal
        - apache2
        - jq
        runcmd:
        - curl -s http://169.254.169.254/latest/meta-data/hostname >/var/www/html/index.html
        - echo >>/var/www/html/index.html 
        - curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone >>/var/www/html/index.html
        - echo >>/var/www/html/index.html 
        - echo >>/var/www/html/index.html
        - echo "OK" >/var/www/html/health.html
        final_message: "The system is finally up, after $UPTIME seconds"
        ```
    - Metadata: Add a Custom one. Ex: "group" : "web"

Repeat this step for 2 instances (or simply increase the count when creating).

### Create a Floating IP

Create a Floating IP.

### Create a Load balancer

Create a Load balancer to load the load between the web servers.
In a normal scenario the load balancer would be provided by the cloud environment, in our case we need to deploy our own.

- Instance:
    - Name: `<name>-lb-<number>` // ex. jonas-lb-1
    - AZ: Choose any zone
    - Boot Source: `Image`
    - Choose an Image (You will need to find what the default username is for the image you choose.)
    - Flavor: `m1.small`
    - Network: The Network you created in the earlier steps
    - Security Groups: The Security Group you created for the web server
    - Key Pair: The key pair you created in the earlier steps
    - Metadata: Add a Custom one. Ex: "group" : "lb"

Challenge here! Setup a basic HAProxy load balancer for HTTP to send balance traffic between the earlier 2 web server nodes.

HAProxy configuration should be very minimal and basic. One frontend and one backend (these are HAProxy configuration terms) to balance load between the 2 earlier VMs.

### Associate Floating IP to Load balancer

Associate Floating IP to Load balancer instance.

### Verify the setup

- SSH to the Bastion host
- SSH to the Web servers
- Copy and past Floating IP for the Load balancer instance in the web browser and refresh - you should see the content switching
