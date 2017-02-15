# Initial configuration for Jenkins master service
# Provides unsecured Jenkins instance

{% set jenkins = salt['pillar.get']('jenkins') %}

# add parameter to skip SetupWizard
{% set java_args = "-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false" %}
jenkins_java_args:
  file.replace:
    - name: /etc/default/jenkins
    - pattern: "^JAVA_ARGS=.*$"
    - repl: 'JAVA_ARGS="{{ java_args }}"'

jenkins_master_ssh_directory:
  file.directory:
    - name: /var/lib/jenkins/.ssh
    - user: jenkins
    - mode: 0700

# Configure jenkins user SSH key
# yaml_encode helps passing multiline contents variables
jenkins_master_ssh_private_key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_rsa
    - contents: {{ jenkins.private_key | yaml_encode }}
    - makedirs: True
    - replace: True
    - user: jenkins
    - mode: 600
    - require:
        - file: jenkins_master_ssh_directory

jenkins_master_ssh_public_key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_rsa.pub
    - contents: {{ jenkins.public_key | yaml_encode }}
    - makedirs: True
    - replace: True
    - user: jenkins
    - mode: 644
    - require:
        - file: jenkins_master_ssh_directory

jenkins_service:
  service.running:
    - name: jenkins
    - enable: True
    - init_delay: 60 # Jenkins start is slow
