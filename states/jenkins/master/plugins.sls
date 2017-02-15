# Install set of plugins on local Jenkins instance via Jenkins cli
{% from 'jenkins/master/plugins.jinja' import plugins with context %}

{% set jenkins_cli = "/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar"  %}
{% set default_url = "http://updates.jenkins-ci.org/download/plugins/{plugin_name}/{plugin_version}/{plugin_name}.hpi" %}

{% for plugin in plugins %}

{% set plugin_url = plugin.get('url', default_url.format(plugin_name=plugin.name, plugin_version=plugin.version)) %}

jenkins_plugin {{ plugin.name }}:
  cmd.run:
    - name: "java -jar {{ jenkins_cli }} -s http://localhost:8080/ install-plugin {{ plugin_url }}"
    - unless: |
         version_string=`java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080/ list-plugins {{ plugin.name }}` && version=`echo ${version_string%(*)} | awk '{print $NF}'` && [ "$version" == "{{ plugin.version }}" ]
    - runas: jenkins
    - shell: /bin/bash
    - watch_in:
        - service: jenkins_restart
{% endfor %}

jenkins_restart:
  service.running:
    - name: jenkins
    - init_delay: 60 # Jenkins start is slow
