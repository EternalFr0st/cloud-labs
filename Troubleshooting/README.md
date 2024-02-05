# Lab - Troubleshooting
## Vagrant

Creates three VMs

`server01`

`client01`

`db01`

password for vagrant user: `vagrant`

## Challenges

### Cannot access the server

Seems like `client01` can't SSH into `server01` over the network! There seems to be some networking problem, investigate and figure it out!
Think about: IPs, Firewalls, Services, Routes...

### The web server seems to be down

The web server is normally shown on localhost:8080 in the browser (on your host machine). It used to work but now it does no longer.... Maybe there's some error in the application? Does the website load or show some error? Does the website load on the server itself but not when accessed on the host?

There's a service installed in there:
`systemctl status flaskapp`

And the application file/configuration:
`/opt/app/flaskapp/__init__.py`

Hints: Firewalls, Networking, Configuration

### BONUS!!! The database is exposed - alert! security risk

Oh my goodness, the person who configured this is mad! `client01` can access the database without any issue, we should really fix that!
You should move `server01` and `db01` into their own subnet - so reconfigure eth2 on `server01` and eth1 on `db01` to move to a completely separate private subnet. (Don't worry about changing any VirtualBox settings here)
So the only way `client01` can access the `db01` server is first accessing/jumping through `server01`.
Hmmm - the app might've stopped working after this, odd......?

## Some hints/guardrails
All changes should be done within the VMs themselves, do not modify the Vagrantfile or it's associated scripts/directories.
The application on `server01` lives in `/opt/app/flaskapp/__init__.py` and it's associated service `flaskapp`.
Firewall rules are controlled and configured with `firewall-cmd`.
Network interfaces controlled by `NetworkManager` - hint `nmcli` or `nmtui`
You can check the bootstrapping scripts under `"scripts/"` directory to see additional details on how the systems are configured/installed.

Reminder for vagrant commands:
 - vagrant up - bring up the lab
 - vagrant destroy - destroy the lab completely
 - vagrant ssh `<server name>` - SSH into one of the servers
