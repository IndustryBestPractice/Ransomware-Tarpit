# Ransomware-Tarpit
Quick and dirty powershell script to generate random files when files within a monitored path are modified.

The idea of this script is to trap an active ransomware infection into encrypting useless files until the infection can be shutdown. The intended purpose is to stand up a honeypot file server in your environment that will run this script as a service. You can then setup hidden drive mappings on your workstations to point to this honeypot fileserver. As ransomware encrypts files on this honeypot server the script will generate additional files, hopefully resulting in the ransomware never running out of files to encrypt, effectively trapping it and preventing it from reacing your legitimate data.
