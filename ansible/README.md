# Ansible testing on GCP

## TODO Get GCloud CLI and IAP tunneling going

GCloud CLI IAP authentication/ssh technique copied from https://binx.io/2021/03/10/how-to-tell-ansible-to-use-gcp-iap-tunneling/

**Almost there, these ran fine:**

ansible-inventory all -i misc/inventory.gcp.yaml --list

ansible all -m setup -i misc/inventory.gcp.yaml

**This however doesn't:**

ansible-playbook misc/playbook.yaml -i misc/inventory.gcp.yaml

_fatal: [compute-instance-0-vm]: FAILED! => {"ansible_facts": {}, "changed": false, "failed_modules": {"ansible.legacy.setup": {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "failed": true, "module_stderr": "ERROR: (gcloud.compute.ssh) Underspecified resource [compute-instance-0-vm]. Specify the [--zone] flag.\n", "module_stdout": "", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1, "warnings": ["Platform unknown on host compute-instance-0-vm is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.14/reference_appendices/interpreter_discovery.html for more information."]}}, "msg": "The following modules failed to execute: ansible.legacy.setup\n"}_

- So looks like zone isn't getting passed on even though adding group_vars/all.yml fixed the same problem with one of the other commands
- The article refers https://unix.stackexchange.com/questions/545034/with-ansible-is-it-possible-to-connect-connect-to-hosts-that-are-behind-cloud-i to which someone has posted quite a different looking solution after the article, probably just going to try that

Decided to give this another go and hardcoding --zone to the ssh wrapper command got 7 tasks to run but then again ansible gave an error:

```
TASK [google-cloud-ops-agents-ansible : Download script] **********************************************************************************************************************************************************
fatal: [compute-instance-0-vm]: FAILED! => {"changed": false, "dest": "/tmp/ansible.q4rzisd3_cloud_ops_shell_scripts/add-google-cloud-ops-agent-repo.sh", "elapsed": 40, "msg": "Request failed: <urlopen error [Errno 101] Network is unreachable>", "url": "https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh"}

PLAY RECAP ********************************************************************************************************************************************************************************************************
compute-instance-0-vm      : ok=7    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

**Which is no wonder as the VM has no external IP or a cloud nat to use.**

**So next problem after adding a cloud nat**

```
TASK [google-cloud-ops-agents-ansible : Add repo and install agent or remove repo and uninstall agent] ************************************************************************************************************
FAILED - RETRYING: [compute-instance-0-vm]: Add repo and install agent or remove repo and uninstall agent (5 retries left).
FAILED - RETRYING: [compute-instance-0-vm]: Add repo and install agent or remove repo and uninstall agent (4 retries left).
FAILED - RETRYING: [compute-instance-0-vm]: Add repo and install agent or remove repo and uninstall agent (3 retries left).
FAILED - RETRYING: [compute-instance-0-vm]: Add repo and install agent or remove repo and uninstall agent (2 retries left).
FAILED - RETRYING: [compute-instance-0-vm]: Add repo and install agent or remove repo and uninstall agent (1 retries left).
fatal: [compute-instance-0-vm]: FAILED! => {"attempts": 5, "changed": true, "cmd": ["bash", "add-google-cloud-ops-agent-repo.sh", "--also-install", "--version=latest"], "delta": "0:00:01.644274", "end": "2023-02-07 18:45:48.199926", "msg": "non-zero return code", "rc": 1, "start": "2023-02-07 18:45:46.555652", "stderr": "E: The repository 'https://packages.cloud.google.com/apt google-cloud-ops-agent-kinetic-all Release' does not have a Release file.\n[2023-02-07T18:45:48+0000] Could not refresh the google-cloud-ops-agent apt repositories.\nPlease check your network connectivity and make sure you are running a supported\nubuntu distribution. See https://cloud.google.com/stackdriver/docs/solutions/ops-agent/#supported_operating_systems\nfor a list of supported platforms.", "stderr_lines": ["E: The repository 'https://packages.cloud.google.com/apt google-cloud-ops-agent-kinetic-all Release' does not have a Release file.", "[2023-02-07T18:45:48+0000] Could not refresh the google-cloud-ops-agent apt repositories.", "Please check your network connectivity and make sure you are running a supported", "ubuntu distribution. See https://cloud.google.com/stackdriver/docs/solutions/ops-agent/#supported_operating_systems", "for a list of supported platforms."], "stdout": "Hit:1 http://us-central1.gce.archive.ubuntu.com/ubuntu kinetic InRelease\nHit:2 http://us-central1.gce.archive.ubuntu.com/ubuntu kinetic-updates InRelease\nHit:3 http://us-central1.gce.archive.ubuntu.com/ubuntu kinetic-backports InRelease\nIgn:4 https://packages.cloud.google.com/apt google-cloud-ops-agent-kinetic-all InRelease\nErr:5 https://packages.cloud.google.com/apt google-cloud-ops-agent-kinetic-all Release\n  404  Not Found [IP: 172.253.119.100 443]\nHit:6 http://security.ubuntu.com/ubuntu kinetic-security InRelease\nReading package lists...", "stdout_lines": ["Hit:1 http://us-central1.gce.archive.ubuntu.com/ubuntu kinetic InRelease", "Hit:2 http://us-central1.gce.archive.ubuntu.com/ubuntu kinetic-updates InRelease", "Hit:3 http://us-central1.gce.archive.ubuntu.com/ubuntu kinetic-backports InRelease", "Ign:4 https://packages.cloud.google.com/apt google-cloud-ops-agent-kinetic-all InRelease", "Err:5 https://packages.cloud.google.com/apt google-cloud-ops-agent-kinetic-all Release", "  404  Not Found [IP: 172.253.119.100 443]", "Hit:6 http://security.ubuntu.com/ubuntu kinetic-security InRelease", "Reading package lists..."]}

PLAY RECAP ********************************************************************************************************************************************************************************************************compute-instance-0-vm      : ok=8    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0
```

**Which indeed was fixed by swapping over to a supported VM image**

