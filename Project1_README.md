## Automated ELK Stack Deployment

  -Enter the playbook file._
  ---
- name: Configure Elk VM with Docker
  hosts: elk
  remote_user: sysadmin
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present

      # Use apt module
    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present

      # Use pip module (It will default to pip3)
    - name: Install Docker module
      pip:
        name: docker
        state: present

      # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144

      # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: 262144
        state: present
        reload: yes

      # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        # Please list the ports that ELK runs on
        published_ports:
          -  5601:5601
          -  9200:9200
          -  5044:5044

      # Use systemd module
    - name: Enable service docker on boot
      systemd:
        name: docker
        enabled: yes
		
Filebeat Playbook
---
- name: installing and launching filebeat
  hosts: webservers
  become: yes
  tasks:
  - name: download filebeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.1-amd64.deb
  - name: install filebeat deb
    command: dpkg -i filebeat-7.6.1-amd64.deb
  - name: drop in filebeat.yml
    copy:
      src: /etc/ansible/files/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml
  - name: enable and configure system module
    command: filebeat modules enable system
  - name: setup filebeat
    command: filebeat setup
  - name: start filebeat service
    command: service filebeat start
  - name: enable service filebeat on boot
    systemd:
      name: filebeat
      enabled: yes

Metricbeat Playbook

---
- name: Install metric beat
  hosts: webservers
  become: true
  tasks:
    # Use command module
  - name: Download metricbeat
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.6.1-amd64.deb

    # Use command module
  - name: install metricbeat
    command: dpkg -i metricbeat-7.6.1-amd64.deb

    # Use copy module
  - name: drop in metricbeat config
    copy:
      src: /etc/ansible/files/metricbeat-config.yml
      dest: /etc/metricbeat/metricbeat.yml

    # Use command module
  - name: enable and configure docker module for metric beat
    command: metricbeat modules enable docker

    # Use command module
  - name: setup metric beat
    command: sudo metricbeat setup

    # Use command module
  - name: start metric beat
    command: sudo service metricbeat start

    # Use systemd module
  - name: enable service metricbeat on boot
    systemd:
      name: metricbeat
      enabled: yes
	  
### Description of the Topology

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.
- What aspect of security do load balancers protect? To balance the load fro Web-1 and Web-2 and also fro redundancy. 

What is the advantage of a jump box?_ Only jump box hass access to web-1 and web-2 server. Attacker cannot cannot easily access inter web server. 

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the _logs and system _traffic.
- What does Filebeat watch for?_ Generate light weight logs so that can easily read the logs.
- What does Metricbeat record?_ Record the metricbeat docker utilization of the server. Also show how many server is running, pause and stop. Show alo network 

The configuration details of each machine may be found below.

| Name     | Function | IP Address | Operating System |
|----------|----------|------------|------------------|
| Jump Box | Gateway  | 10.0.0.4   | Linux            |
| Web-1    |          | 10.0.0.5   | Linux            |
| Web-2    |          | 10.0.0.6   | Linux            |
| Elk-Ser  |          | 10.1.0.4   | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump box machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- Add whitelisted IP addresses_ Jump Box use my home public IP Address which is white listed in Azure NSG. 

Machines within the network can only be accessed by Jump Box.
- Which machine did you allow to access your ELK VM? What was its IP address?_ We use Jump Box to ssh on the ELK server and deploy Ansible playbook. To access via HTTP I use my personal web browser on my personal workstation.

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses |
|----------|---------------------|----------------------|
| Jump Box | Yes                 | My public IP 10.0.0.4|
| Web-1    | No                  | 10.0.0.5             |
| Web-2    | No                  | 10.0.0.6             |
| ELK Serv | Yes                 | My public IP 10.1.0.4|

### Elk Configuration

The playbook implements the following tasks:
- ...Install python3-pip
- ...Increase virtual memory
- ...Download and launch a docker elk container
- ...Enable service docker
- ...published_ports ELK will use. 

### Target Machines & Beats

This ELK server is configured to monitor the following machines:
- List the IP addresses of the machines you are monitoring_
Web-1 - 10.0.0.5
Web-2 - 10.0.0.6

### Using the Playbook

SSH into the control node and follow the steps below:
- Copy the _config file to _/etc/ansible.
- Update the _host file to include...
- Run the playbook, and navigate to web-1, web-2 and Kibana website to check that the installation worked as expected.

Answer the following questions to fill in the blanks:_
- _Which file is the playbook? Where do you copy it?_ All the files with file extension ended in .yml. Files are copy to /etc/ansible directory
- _Which file do you update to make Ansible run the playbook on a specific machine? Host file
How do I specify which machine to install the ELK server on versus which to install Filebeat on?_ Nano to the host file and add the 2 IP address of web-1 and web-2 to the webservers host. Add the elk host on the host file and add the elk server IP address.  
- _Which URL do you navigate to in order to check that the ELK server is running? http://20.185.182.32:5601/app/kibana#/home

_ provide the specific commands the user will need to run to download the playbook, update the files, etc._ curl -L -O