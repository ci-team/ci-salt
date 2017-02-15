# Install jenkins package from official Jenkins LTS repositories

{% set jenkins_version = "2.32.1" %}


apt-transport-https:
  pkg.installed

jenkins_repo:
  pkgrepo.managed:
    - name: deb https://pkg.jenkins.io/debian-stable binary/
    - file: /etc/apt/sources.list.d/jenkins.list
    - key_url: https://pkg.jenkins.io/debian-stable/jenkins.io.key
    - require:
        - pkg: apt-transport-https

prevent_startup_on_install:
  file.managed:
    - name: /usr/sbin/policy-rc.d
    - contents: |
        #!/bin/bash

        exit 101
    - mode: 0700

jenkins:
  pkg.installed:
    - version: {{ jenkins_version }}
    - require:
        - pkgrepo: jenkins_repo
        - file: prevent_startup_on_install
