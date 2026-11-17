# Decision log

Every time I make a design choice or change my mind, it gets an entry here.
Each entry links to the Jira item (NP-xx) and, where there is one, the GitHub issue.
Open decisions are GitHub issues with the `decision` label; when one is closed, its outcome is copied here.

## Open decisions

| GitHub | Jira | Question |
|---|---|---|
| #17 | NP-19 | Which project methodology, and why |
| #11 | NP-54 | Wazuh vulnerability detection on or off |
| #12 | NP-48 | How to store and hand over the Wazuh admin password |
| #13 | NP-108 | Language for the connect script |
| #14 | NP-126 | Remove the GUI and DCV from the template |
| #15 | NP-127 | Instance size |
| #18 | NP-74 | Does the usability test need ethics approval |

## Decided

### D1. CloudFormation instead of Terraform
- **Date:** agreed with Andrew 9 Nov 2026
- **Jira:** NP-41 · **Status:** decided
- **Options:** CloudFormation, Terraform
- **Chose:** CloudFormation
- **Why:** the user doesn't have to download or install any extra tools, it can deploy from a quick-create link, failed deploys roll back; the whole stack deletes in one click.

### D2. AWS only, no Azure version
- **Date:** Decided on 9 Nov 2026
- **Jira:** NP-85 (Won't have) · **Status:** decided
- **Chose:** build for AWS only
- **Why:** AWS appears to have more flexibility when it comes to tools and customization whereas Azure you are tied to primarily using microsoft products 

### D3. Changed: SSH from my IP → no inbound ports, connect through SSM
- **Date:** Decided on 12 Nov 2026
- **Jira:** NP-35, NP-36 (old way) → NP-44, NP-49 (new way) · **Status:** changed
- **Before:** security group allowed SSH from my IP only, and a script added my new IP when it changed
- **After:** security group has no inbound rules; I connect with AWS Systems Manager Session Manager
- **Why:** SSM is technically more secure as no keys are transferred over to the user whereas with SSH I would risk accidentally exposing the key to malicious actors while attempting to give the key to the user. 
  
### D4. Changed: t3.medium (manual build) → t3.large (template)
- **Date:** Decided 12 Nov 2026
- **Jira:** NP-33 → NP-127 · **GitHub:** #15 (still open) · **Status:** changed, under review
- **Why:** Needed more compute power to run Wazuh and GUI

### D5. Changed: 30 GB → 50 GB disk, Wazuh vulnerability detection switched off
- **Date:** 12 Nov 2026
- **Jira:** NP-87 · **GitHub:** #2, follow-up #11 · **Status:** changed
- **Why:** the vulnerability database filled /var/ossec and the 30 GB disk before the GUI finished installing. While I added to the script to uninstall the vulnerability database the instance still needs the 50gb to complete the full Wazuh install before deleteing the component

### D6. Removed the Availability Zone selection from the template
- **Date:** 12 Nov 2026
- **Jira:** NP-86 · **GitHub:** #1 · **Status:** changed
- **Why:** `Fn::Select` needs `ec2:DescribeAvailabilityZones`, which my IAM user doesn't have; AWS picks the default AZ instead. AWS requires you to have the account for 6 months before allowing you to change zones.

### D7. Kept the Wazuh install file, root-only, instead of deleting it
- **Date:** 12 Nov 2026
- **Jira:** NP-89 · **GitHub:** #4, follow-up #12 · **Status:** temporary
- **Why:** deleting `wazuh-install-files.tar` lost the admin password; it now lives in /root with chmod 600 until #12 is decided. Need to figure out a way to prompt user to change password. Should be possible in wizard.

### D8. Raised the AWS spending limit (for now)
- **Date:** 13 Nov 2026
- **Jira:** NP-90 → NP-91 · **GitHub:** #5 → #6 · **Status:** temporary
- **Why:** `ec2:StartInstances` was blocked after about $2.50 in one day. Raising the limit unblocked me; the real fix is cutting cost (#6).

### D9. Stack updates from GitHub with CloudFormation Git sync
- **Date:** _add date_
- **Jira:** NP-143 · **GitHub:** #7 · **Status:** decided
- **Chose:** AWS CodeConnections + "Sync from Git", so pushing the template to GitHub updates the stack
- **Why:** No longer need to manually update stack every commit. This saves me time and ensures version control.
  
### D10. Jira instead of Trello for the project board
- **Date:** 16 Nov 2026
- **Jira:** NP-18 · **Status:** decided
- **Options:** Jira (Scrum board with sprints, backlog, epics), Trello
- **Why:** Started with a Trello board, however the trello board started becoming too messy and convoluted. Switching ti Jira did take some time however everything is much more organised.  

---

### Template
```
### Dn. <short title>
- **Date:**
- **Jira:** NP-xx · **GitHub:** #xx · **Status:** decided / changed / temporary
- **Options:**
- **Chose:**
- **Why:** (my own words)
- **What changed because of it:**
```
