# ubuntu-devops-01

## Purpose
Main learning ubuntu server

## IP address
10.0.0.23

## OS Version
Ubuntu Server

## Installed Services
- SSH
- Nginx

## Firewall Rules
```bash
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     ALLOW IN    Anywhere                  
[ 2] 80/tcp                     ALLOW IN    Anywhere                  
[ 3] 22/tcp (v6)                ALLOW IN    Anywhere (v6)             
[ 4] 80/tcp (v6)                ALLOW IN    Anywhere (v6)             
```
## SSH Configuration

```bash
port 22
permitrootlogin prohibit-password
pubkeyauthentication yes
passwordauthentication yes
gatewayports no
LISTEN 0      4096         0.0.0.0:22        0.0.0.0:*    users:(("sshd",pid=1569,fd=3),("systemd",pid=1,fd=261))                        
LISTEN 0      4096            [::]:22           [::]:*    users:(("sshd",pid=1569,fd=4),("systemd",pid=1,fd=263))                        
```
