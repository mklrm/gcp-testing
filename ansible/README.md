# Ansible testing on GCP

## TODO Get GCloud CLI and IAP tunneling going

GCloud CLI IAP authentication/ssh technique copied from https://binx.io/2021/03/10/how-to-tell-ansible-to-use-gcp-iap-tunneling/

**Almost there, these ran fine:**

ansible-inventory all -i misc/inventory.gcp.yaml --list

ansible all -m setup -i misc/inventory.gcp.yaml

**This however doesn't:**

ansible-playbook misc/playbook.yaml -i tutorial/inventory.gcp.yaml

_fatal: [compute-instance-0-vm]: FAILED! => {"ansible_facts": {}, "changed": false, "failed_modules": {"ansible.legacy.setup": {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "failed": true, "module_stderr": "ERROR: (gcloud.compute.ssh) Underspecified resource [compute-instance-0-vm]. Specify the [--zone] flag.\n", "module_stdout": "", "msg": "MODULE FAILURE\nSee stdout/stderr for the exact error", "rc": 1, "warnings": ["Platform unknown on host compute-instance-0-vm is using the discovered Python interpreter at /usr/bin/python, but future installation of another Python interpreter could change the meaning of that path. See https://docs.ansible.com/ansible-core/2.14/reference_appendices/interpreter_discovery.html for more information."]}}, "msg": "The following modules failed to execute: ansible.legacy.setup\n"}_

- So looks like zone isn't getting passed on even though adding group_vars/all.yml fixed the same problem with one of the other commands
- The article refers https://unix.stackexchange.com/questions/545034/with-ansible-is-it-possible-to-connect-connect-to-hosts-that-are-behind-cloud-i to which someone has posted quite a different looking solution after the article, probably just going to try that

