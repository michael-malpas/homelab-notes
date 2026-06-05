# Day 2

## Daily Goals
- Create users
- Create Groups
- Add users to groups
- Understand ownership
- Understand Permissions
- use chmod
- grant sudo access
- write a basic provisioning script
- forced password expiration
- locked account
- unlocked account
- use chage
- configured permissions
- installed acl tools
- granting access with setfacl
- removing acls
- building multi-department access structure
- testing
- documenting everything
- committing and pushing to github

## User Management

Commands practiced:
- whoami
- id
- cat /etc/passwd
- grep

## Created test users jsmith and msmith
```bash
sudo useradd -m jsmith
sudo useradd -m msmith
```

## Set password for new user
```bash
sudo passwd jsmith
```

## Verified new user/password set
```bash
grep jsmith /etc/passwd
```

## Checked Home Directories
```bash
ls /home
```

## Created Test Department Groups
```bash
sudo groupadd accounting
sudo groupadd hr
sudo groupadd it
```

## Verified test groups
```bash
grep accounting /etc/group
grep hr /etc/group
grep it/etc/group
cat /etc/group
```

## Added user to group
```bash
sudo usermod -aG accounting jsmith
```

## Verified user groups
```bash
groups jsmith
```

## Created Shared Department Folders
```bash
sudo mkdir /shared
sudo mkdir /shared/accounting
```

## Assigned group ownership
```bash
sudo chown root:accounting /shared/accounting
```

## Verified group ownership
```bash
ls -ld /shared/account
```

## Testing permissions with test.txt file
```bash
touch test.txt
ls -l test.txt
chmod 000 test.txt
ls -l test.txt
chmod 644 test.txt
ls -l test.txt
chmod 755 test.txt
ls -l test.txt
```

Standard permissions
644 = standard files
755 = executable/script
700 = owner only
600 = private file

## Created an admin user
```bash
sudo useradd -m adminuser
sudo passwd adminuser
```

## Added sudo access
```bash
sudo  usermod -aG sudo adminuser
groups adminuser

## Tested admin account
```bash
su - adminuser
whoami
sudo apt update
exit
```

## Employee Onboarding Simulation Exercise
Employee: Mary Smith
Department: Accounting
Needs:
- User account
- Password
- Group membership
```bash
sudo useradd -m msmith
sudo passwd msmith
sudo usermod -aG accounting msmith
groups msmith
```

## Create Provisioning Script
```bash
nano ~/scripts/create_user.sh
#!/bin/bash

USERNAME=$1

sudo useradd -m $USERNAME

echo "Created user: $USERNAME"
```

## Make Script Executable
```bash
chmod +x ~/scripts/create_user.sh
```

## Test Script will run
```bash
./scripts/create_user.sh testuser
grep testuser /etc/passwd
```

## Created linux vs ad document comparing linux vs AD perms/groups/users
see homelab-notes/week1/linux-vs-ad.md

## User Administration Exercise

Discovered typo in GECOS field for primary account.

Investigated using:

```bash
grep michael /etc/passwd
```

Corrected account information using:

```bash
sudo chfn michael
```

Verified correction:

```bash
grep michael /etc/passwd
```

Corrected account information usingL:

```bash
sudo vipw
```

Result:

```text
michael:x:1000:1000:Michael:/home/michael:/bin/bash
```

## Installed Tree
```bash
sudo apt install tree
```


## Testing/exploring Tree
```bash
tree /home
```

## Inspeting Shadow Passwords
```bash
sudo grep michael /etc/shadows
```
Did some further research on how shadow passwords are used and learning about how linux uses hashes


## Password Expiration

used:

```bash
sudo passwd -e tempuser
```

purpose:
Force password chagne at next login.

## Checking password expiration info
```bash
sudo chage -l tempuser
```

shows password expiration information, showed account was pending a password change

## Logging into tempuser account to see how password change requirement behaves
```bash
su - tempuser
```

changed password.


## Test Lock/unlock account
```bash
sudo passwd -l tempuser
sudo passwd -S tempuser
su - tempuser
```

Locked account, reviewed the status of the account showing it was "L" locked. attempted to switch to the tempuser account and it failed as expected.

Unlocked account:
```bash
sudo passwd -u tempuser
sudo passwd -S tempuser
```

Reviewed account info and it now showed "P" for password set
Attempted login again and was successful.

## Create test shared directory and apply group permissions
Scenario:
Accounting Department Shared Folder with only Accounting members having access
```bash
sudo mkdir -p /shared/accounting
sudo chown root:accounting /shared/accounting
sudo chmod 770 /shared/accounting
ls -ld /shared/accounting
```

Creating shared folder, changing ownership/permissions and verifying that permissions display as expected.

## Testing access to shared directories
```bash
sudo usermod -aG accounting jsmith
sudo usermod -aG accounting msmith
```

Using jsmith or msmith account I was able to switch to the user and access /shared/accounting
testing with tempuser account I was able to access /shared directory but not /accounting directory


## Access Control List (ACLs) practice
Installed ACL tools
```bash
sudo apt install acl
```

Verified:
```bash
which setfacl
```

Created "Projects" folder
```bash
sudo mkdir /projects
```

Granted adminuser permissions to projects folder
```bash
sudo setfacl -m u:adminuser:rwx /projects
```

Verified
```bash
getfacl /projects
```

Removed permission
```bash
sudo setfacl -x u:adminuser /projects
```

Verified
```bash
getfacl /projects
```


## Department Share challenge
Structure:
/shared
|- accounting
|- hr
|- it

Requirements:
- Accounting users can only access accounting
- HR users can only access HR
- IT users can only access IT
- adminuser can access everything via ACLs
- others have no access

created directors:
```bash
sudo mkdir /shared/hr
sudo mkdir /shared/it
```

changed ownership of folders
```bash
sudo chown root:hr /shared/hr
sudo chown root:it /shared/it
```

set permissions on folders
```bash
sudo chmod 770 /shared/hr
sudo chmod 770 /shared/it
```

added users to groups
```bash
sudo usermod -aG hr jsmith
sudo usermod -aG it msmith
```

Created facl for adminuser
```bash
sudo setfacl -R -d -m u:adminuser:rwx /shared
```

used -d flag to set as default so new folders/files will be included
used -R flag on the shared folder as in scenario adminuser should have access to everything in shared
rather than individual perms for each folder

Verified acl for adminuser
```bash
getfacl /shared
getfacl /shared/hr
getfacl /shared/account
getfacl /shared/it
```

Created new /shared folder /shared/finance to test recursion/default ACL applies
```bash
sudo mkdir /shared/finance
getfacl /shared/finance
```
