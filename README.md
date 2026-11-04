# shielden
Guided Cloud Security Suite for Small Businesses and Students Working title: Shielden – an open-source wizard that automatically deploys and configures a cloud-hosted security monitoring suite for small businesses and students.

1.	Summary
Small businesses and students rarely have the time, budget or knowledge to deploy and operate defensive cyber security tools, and typically rely on the default protections built into their OS or cloud products. This project will develop a free, open-source tool with a guided setup wizard that deploys a security suite into the user’s own AWS cloud. The suite will run on an Ubuntu Server instance in AWS and will be tested by a separate Kali Linux instance in the same isolated network.

2. Platforms and architecture
Component	Platform	Role
Setup wizard	Python, on the users own computer	Guides the user through setup and deploys the suite to AWS
Suite instance	AWS EC2, Ubuntu Server 24.04	Runs the security suite; also the target during testing
Attacker instance	AWS EC2, Kali Linux	Runs simulated attacks; switched on only during testing
Network	AWS VPC (Virtual Private Cloud)	Isolated network connecting the two instances

 
3. Core scope
The suite must contain a firewall, intrusion detection/prevention, centralised log management (SIEM), and a wizard to guide users through setup:
•	Setup wizard (Python): guides users through the setup.
•	Firewall (UFW, Uncomplicated Firewall): controls traffic to the suite instance.
•	Intrusion Detection/Prevention System (Snort): detects attacks on the network.
•	Centralised logging / SIEM (Wazuh): collects logs and alerts in one place.

4. Extended scope (if time permits)
If time permits, the suite can include a vulnerability scanner, and agentic AI to triage alerts discovered by the vulnerability scanner and suggest actions to mitigate vulnerabilities.
•	Vulnerability scanner (Nmap)
•	Agentic AI triage: a Python script takes the raw Nmap data, extracts the relevant information and structures it into a JSON file. The script then gives the information to a local Ollama model, which cross-references the discoveries against common vulnerability databases (CVE, NVD), prioritises them, and outputs its findings in a readable format with suggested mitigations. The user will confirm whether the agent can fix the vulnerabilities or guide the user on how to fix it themselves.
5. Evaluation
The project solution will be evaluated using the following techniques:
1.	Setup time: comparing the time it takes to set up the suite tools manually on a Virtual Machine vs with the wizard.
2.	Usability: how easy it is for a group of non-technical users to understand and use.
3.	Detection rate: the percentage of common simulated attacks from the MITRE ATT&CK framework that the system detects or blocks. The attacking machine will run Kali Linux on a separate instance within the same isolated AWS VPC, so no testing takes place outside that network.
4.	AI Accuracy: Purposely include vulnerabilities within the host system and see if the AI accurately identifies the vulnerability and correct mitigation technique.

6. Cost
The project cost should be free however AWS provides only 100$ of free credit. To prevent the cost from going over the free 100$ limit the following cost controls will be in place:
1.	I have alerts set up for when I reach 20$ usage and a “cost guard” to track my usage.
2.	Set up a script to automatically destroy the cloud instance when finished.
3.	Use a local virtual machine with kali linux when testing/practicing using tools like NMAP, Wazuh, UFW that do not require the cloud instance to be initialised 
