# jthurteau.github.io
It's my personal page(s), It's also a Vagrant/Podman build for quick PHP development access

## Standup Procedure

You can use the provided Vagrantfile to stand up a local-dev PHP container. This will be refered to as the "__Pod VM__" since it hosts the `podman` application and provides the Linux Kernel needed for the container.

You'll need Vagrant and VirtualBox:

https://www.vagrantup.com/

https://www.virtualbox.org/

### Precautions

Always be careful with trusting externally sourced code. Vagrant provisoners are no different. `Vagrantfiles` triggered indirectly by running `vagrant` in a folder run as the user, so the Ruby code and any host scripts that get triggered could be destructive or expose local information on the computer.

### Public Provisioner (Alpine Vagrant + Podman)

Vagrant should be fairly cross-platform compatible with this minimal setup (but it has been primairly tested from a Windows host). If you already have Docker or Podman setup on the host computer, and an HTTP server capable of providing the FCGI frontend to a PHP-FPM container, it should be possible to [bypass the Vagrant/VirtualBox requirement entirely](#dockerfile-setup). 

Vagrant and Virtualbox are used to create a Linux Pod VM (which provides the Linux Kernal) suitable to spin up OCI Containers (which require a Linux Kernal). This build uses Alpine Linux because of its small size. There is little need for anything more full-featured as the Pod VM, because any Linux OS can provide the kernal for any other Linux OS container. That means if you want to test PHP running on Ubuntu, you only need to focus on the Dockerfile, not the Vagrantfile.

The whole build process takes 2 minutes or less on a reasonably fast home internet connection and computer. Less than a minute for the VM disk image download and then over a minute for setup of the VM and container. Once created, just bring the container back up is much faster.

To setup the local-dev VM, open a command prompt (e.g. powershell), navigate (cd) to the root folder of the code (where the "Vagrantfile" is) and type:

> `vagrant up`

This will download an Alpine VM disk image (a large file) and attempt to build the VM.

The process of downloading the disk image takes around a minute and doesn't provide progress tracking. Once that is done, the rest of the process generally provides more active progress updates. Vagrant will install Nginx (a web server) and Podman (a container manager) in the VM. Podman will then use the provided Dockerfile to create a container capable of serving PHP based applications through the Nginx server.

When you're done with the Containers and VM you can stop the whole system with:

> `vagrant halt`

Bring it back up at any time with:

> `vagrant up --provision-with start`

(vagrant up brings up the VM, building it if it doesn't exist. building the VM automatically starts the container, but on subsequent `up`s it must be started explicitly)

To leave the VM running and just stop the container:

> `vagrant provision --provision-with stop`

To just bring up the container (if it isn't running, but the VM is):

> `vagrant provision --provision-with start`

If you're completely done with the VM you can destroy it:

> `vagrant destroy`

(you'll need to confirm by entering `y` at the prompt)

You can verify the state of the container (while the VM is running) with:

> `vagrant provision --provision-with list`

If it's not running you can make sure to clear out any failing containers and bring up a new one with:

> `vagrant provision --provision-with clean,start`

Most Nginx and PHP related log information should be reported back out to the "project directory" but other relevant information about what's going wrong with the the container with:

> `vagrant provision --provision-with logs`

You can remote into the VM with:

> `vagrant ssh`

You can remote into a container to explore around with:

> `sudo /vagrant/src/install/shell/vagrant-int.sh <project>`

Note that this isn't __the__ container, it is an "identical" container to the one responding to web requests.

Where `<project>` is the "app_name" from the `Vagrantfile` (so the default would be `sudo /vagrant/src/install/shell/vagrant-int.sh test`)

For more information about built in configuration options see [Vagrant Configuration](#vagrant-configuration). 

More specific Vagrant learning resources are available from HashiCorp.

[Introduction to Vagrant](https://www.vagrantup.com/intro)

[General Vagrant Documentation](https://www.vagrantup.com/docs)

More information about using Podman:

[About Podman](https://docs.podman.io/)

[Containerfile Documentation](https://docs.docker.com/engine/reference/builder/) (Podman is almost completely interoperable with Docker, so so this build uses Dockerfiles for configuration)

### Notes about the Vagrant

This is designed to create an environment for development and debugging, so logging and error reporting is turned way up and exposed. By default the web server (Nginx) running in the VM is exposed to the host computer, but not the host computer's network. PHP-FPM should never be directly exposed to the host computer's network.

Nginx is configured to serve static content hosted on the VM in /var/www/html and any requests that don't match an existing file are coerced into a '.php' URL passed to PHP-FPM. This setup aproximates Apache's Multiviews behavior, which is a simpler alternative to complex URL rewrite rules used by many PHP frameworks.

Whatever PHP you want to serve out via PHP-FPM can be placed in a `/public` folder at the root of the cloned repo (the same folder the Vagrantfile is in). 

The logs for Nginx and PHP-FPM are available in a `/podvan/local-dev.<project>` folder.

Generally, the __VM provisioner__ (named "Tm") will try to avoid writing outside of /podvan unless explicitly allowed to write in the root of the repo for a specific operation, but this is not a strongly enforced precation.

#### Vagrant Configuration

The Vagrantfile contains several options for managing the Pod VM. Vagrantfiles are a Ruby script to manage VMs using Vagrant.

`app_name` determines how the code of the repo gets deployed internally to the VM and then container. This won't affect a whole lot, but can be used to more clearly indicate what is being built and served.

`web_port` determines the port Vagrant will use to expose Nginx (a web server) to the host computer.

`allow_outside_http` determines if web_port is open to the outside world, off by default. You can access Nginx and PHP through your own browser without turning this option on.

`ms_config` is a map of options used to configure provisioners for the Pod VM. These generally map to files in /src/install/shell. The first value in each line is a provisioner name that can be accessed through the `vagrant` command with the option `--provision-with <name>`. If there is a second value and it is a string, that is the file name (without the .sh extension) of the shell script that is used. In the case that there is no second string, the provisioner name and script file name are the same. 

The last, optional, value is an array (note it should not be a Hash). If present, it will include strings passed as commandline arguments to the shell script. If none are specified, the unique "secret" autogenerated when the VM is created and stored in `/podvan/local-dev.<project>/secret.txt` is passed. Strings that include the "@" symbol and that map to special "vars" registered with the provisioner will be substituted at build time, some examples include:

- @project, replaced with the <project> name, e.g. "test"
- @project_path, replaced with the project shared across host computer, Pod VM, and container, e.g. "/podvan/local-dev.<project>" in the repo on the host and "/opt/project" in the VM and container.
- @secret, replaced with the unique autogenerated secret

### Dockerfile Setup
  
The Dockerfile is placed in /src/install/ so some Dockerfile operations like COPY are (intentionally) limited to that scope. The default Dockerfile includes some examples of fullfilling basic needs (like adding a php-extension, fetching additional dependencies via git, etc.). 

Two mount points are included, the first mounts the root of the repo (indirectly) to /opt/application/<project> (and /var/www/html is linked, indirectly, to /opt/appliction/<project>/public). The second mount connects files in both the container and the Pod VM to the host computer through the "project_path" (/podvan/local-dev.<project> in the repo on the host and /opt/project in the VM and container). The project_path is used to access Nginx and PHP-FPM logs, but PHP scripts can also read and write there as well.

PHP-FPM normally serves out of 9000 and is intentionally local-host traffic only. Because PHP-FPM is in the container, which is effectivelty a separate "local-host" from the host VM, it must be explicitly linked using podman. This build connects the container's port 9000 to the Pod VM's port 8090, and does not expose PHP-FPM directly to the host computer. Nginx accepts requests on th host computer's port 8080, and relays anything looking like a legit PHP request to PHP-FPM.

### Additional options not covered in the Vagrant or Podman Configuration

While there are a variey of ways to hook up other facilities (like a Database) using an additional container, that isn't included yet.


### Basic Use

This build setup is very much a work in progress, put files in /public and run them. As time allows I'll be adding additional tooling for Composer, SAF, MySQL/MariaDB and more.
