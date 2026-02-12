# Setup infrasturcture

This serves as both the lab requirements and a simple base to start working from.

It configures the absolute minimum, mainly the provider version and the basic provider configuration.

To see how that looks check the `terraform/provider.tf` for the content within.

The declarations are very basic and all the necessary information will be sourced from within your shell environment variables, when you source the RC file.

And a few notes:
 - Terraform commands need to be run from within the `terraform/` folder
 - State is stored locally, so if you remove everything to start from scratch, you will lose it as well. Before removing anything backup the `terraform/.terraform` folder or make a VM snapshot.
 - Sourcing the RC file is a must before running any terraform commands otherwise they will fail. To do that simply run `source /path/to/rcfile`

## Assignment Part 1 - Terraform initialization

Clone this repository with git clone (Command to do that: git clone https://github.com/EternalFr0st/cloud-labs.git) and enter the `terraform/` directory.

Make sure to source the RC file you have downloaded from DarkSnow/Openstack

And both steps are done and run `terraform init` and it should return an output similar to this:

```
 ❯ terraform init                                                              
Initializing the backend...

Initializing provider plugins...
- Finding terraform-provider-openstack/openstack versions matching "~> 1.53.0"...
- Installing terraform-provider-openstack/openstack v1.53.0...
- Installed terraform-provider-openstack/openstack v1.53.0 (self-signed, key ID 4F80527A391BEFD2)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

If you a similar output, you're ready to proceed to part 2 of actually configuring the infrastructure.

## Assignment Part 2 - Terraform

!!! IMPORTANT - It's highly recommended to first remove all the resources you have created by hand from the account before proceeding.

- With terraform setup infrastructure that we have created manually before:
  - A network
  - A subnet
  - A router, that is both connected externally and to the subnet
  - A VM, m1.small
  - A floating IP associated with the VM

All of this should lead to the same setup as before, just all automatically configured by Terraform.
You should be able to SSH into the VM, same as before.

The main idea here is to create the exact same resources that we did by hand just in terraform.

This looks like by you creating terraform files ( ones that end with a .tf ) with certain resources configured.
File structure doesn't matter, you can put it all in a single file or in multiple ones.

As a guiding example, here's how you create a simple floating IP resource:
```bash
resource "openstack_networking_floatingip_v2" "my_float_ip" {
  pool = "external-net"
}
```

Essentially we are creating a `resource` of type `openstack_networking_floatingip_v2` with the name `my_float_ip`.

From this docs page, we can see that there's a mandatory argument for `pool`: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs/resources/networking_floatingip_v2

Pool refers to the external network that the cloud provider configures, which is called "external-net" in our environment.

If you run `terraform apply` after creating that file and approve the changes, you will have a floating IP created and you can check that in the Web GUI.

To destroy all of your terraform, use `terraform destroy`

To understand more of the language and syntax you can find the link to the language explanation here: https://developer.hashicorp.com/terraform/language

Some links to help you get some additional context and walk through the different concepts:

- Highly recommend starting with terraform documentation/tutorial here: 
  - https://developer.hashicorp.com/terraform/tutorials/aws-get-started
    - It's AWS focused, but the key points are still the same, you can see resources configuration, data sources and so on.
- https://developer.hashicorp.com/terraform/tutorials/cli
  - This is a very comprehensive overview of the CLI and different options, I wouldn't start here, but they are very useful resources especially when you need more information around a certain subject.
- https://developer.hashicorp.com/terraform/language
  - This should provide the most context of figuring out how to read some of those examples and understanding syntax and language
- Documentation for the provider can be found here: https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
  - This has every possible resource definition and example you can create in Openstack. This like routers, subnets and so on. "Argument reference" refers to what you can provide in the resource and "Attribute reference" shows what you can look up about the resource, for example the IP address after it's been created, or it's ID and many other things. A simple way to look at it is Argument is input, Attribute is output.

And a quick reminder:
- `terraform plan` - shows the plan but does not execute.
- `terraform apply` - shows the plans and executes once confirmed
- `terraform destroy` - destroy all resources defined in the terraform files
