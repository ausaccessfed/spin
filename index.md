---
---

### This document describes how to install and configure a new SPIN instance.

If you have any problems please contact your technical support team for SPIN.

---

## Deployment configuration

Begin with a minimal CentOS 7 installation. Recommended machine specifications
are:

* 2 CPU
* 4GB RAM
* 10GB+ partition for OS + SPIN
* Public IP address, with inbound access on ports 80, 443 and 8443
* Internet access (the installation process automatically fetches dependencies
  over HTTP / HTTPS)

Steps:

1.  Register your service with AAF Rapid Connect
    ([test](https://rapid.test.aaf.edu.au) /
    [production](https://rapid.aaf.edu.au))

    NB: Ensure your SECRET **does not contain a ' character** as this is used within configuration files
    as a delimiter and will cause startup to fail.

    After registration, please contact AAF to request that your registration be
    converted to an `auresearch` service to ensure SPIN works correctly.

2.  Install SPIN.

    If you have a zip archive, extract it to `/opt`. This will create `/opt/spin` with the necessary directory structure beneath.

    Alternatively, you clone from git directly:

    ```bash
    git clone https://github.com/ausaccessfed/spin.git /opt/spin/app
    ```
    N.B. The destination path of `/opt/spin/app` is required.

3.  Install site-specific assets.

    Create the following files with customised versions for your SPIN instance.
    Templates are provided with a `.dist` suffix.
      - `/opt/spin/app/setup/spin.config`
      - `/opt/spin/app/setup/assets/app/support.md`
      - `/opt/spin/app/setup/assets/app/consent.md`
      - `/opt/spin/app/setup/assets/app/welcome.md`
      - `/opt/spin/app/setup/assets/app/new_invitation_body.md`
      - `/opt/spin/app/setup/assets/app/logo.png`
      - `/opt/spin/app/setup/assets/app/email_branding.png`
      - `/opt/spin/app/setup/assets/app/favicon.png`

    Install your SSL key, certificate and intermediate CA in these locations:
      - `/opt/spin/app/setup/assets/apache/server.key`
      - `/opt/spin/app/setup/assets/apache/server.crt`
      - `/opt/spin/app/setup/assets/apache/intermediate.crt`

4.  Bootstrap the platform:

    ```bash
    [root@spin ~]$ cd /opt/spin/app/setup
    [root@spin setup]$ sh init.sh
    ```

    This will install some dependencies from YUM, and then proceed to configure
    SPIN using your provided settings.

5.  Additional platform configuration.

    The SPIN installation provides no backup or monitoring of the platform. It
    is strongly suggested that deployers configure:
    - Regular backups
    - Monitoring of service availability
    - Monitoring of platform concerns, such as disk space and load average

6.  Reboot server.

    Verify that the service is started correctly after a reboot by rebooting the
    server.

[rapid-test]: https://rapid.test.aaf.edu.au
[rapid-prod]: https://rapid.aaf.edu.au

---

## Initial setup of a new SPIN instance

A blank SPIN instance is not able to be used for anything until an initial
administrator is set up. To do this, first log in to SPIN by accessing it in
your web browser.

After logging in to SPIN, your details will be automatically provisioned in the
database, and you can grant yourself permission to act as a global
administrator:

```sql
[root@spin setup]# mysql spin

MariaDB [spin]> select id, name, mail from subjects;
+----+-------------------+------------------------------+
| id | name              | mail                         |
+----+-------------------+------------------------------+
|  1 | Example User ABCD | example.user.abcd@aaf.edu.au |
+----+-------------------+------------------------------+
1 row in set (0.00 sec)

MariaDB [spin]> select id, name from roles;
+----+----------------------+
| id | name                 |
+----+----------------------+
|  1 | Global Administrator |
+----+----------------------+
1 row in set (0.00 sec)

MariaDB [spin]> insert into subject_roles (subject_id, role_id) values (1, 1);
Query OK, 1 row affected (0.02 sec)
```

The `root` user on the SPIN server has the database credentials configured for
local access, to ease this process.

**Note:** After the first administrator is created, it is highly recommended
that the web interface be used for all further operations. Operations performed
directly against the database are not subject to application logic, and can
result in an invalid database state.

---

## Configure an AWS Project

These instructions will create a minimal configuration which provides
administrative rights within the AWS Project to users. Further enhancement can
be done by creating additional roles with differing permissions. Refer to AWS
documentation for information about their access control.

Before beginning, ensure you have a working deployment of SPIN. You should
download your SPIN IdP's metadata document from:

```
https://<<your spin host>>/idp/profile/Metadata/SAML
```

1. Under the root account visit the "Identity & Access Management" page.
2. Click 'Identity Providers' in the left navigation menu.
3. Click 'Create Provider', and create a provider as follows:
    - Provider Type: **SAML**
    - Provider Name: **SPIN**
    - Metadata Document: The document you downloaded above
4. Click 'Next Step' and then 'Create'
5. Click 'Roles' in the left navigation menu.
6. Click 'Create New Role', and create a role as follows:
    - Role Name: **Administrator**
    - Click 'Next Step'
    - Under **Role for Identity Provider Access**, select
        **Grant Web Single Sign-On (WebSSO) access to SAML providers**
    - SAML provider: **SPIN**
    - Attribute: **SAML:aud** *(this is automatically set)*
    - Value: **https://signin.aws.amazon.com/saml**
        *(this is automatically set)*
    - Click 'Next Step'
    - Trust Policy Document: *(no modifications required)*
    - Click 'Next Step'
    - Policy Template: Select **Administrator Access**
    - Policy Document: *(no modifications required)*
    - Click 'Next Step'
    - Click 'Create Role'
7. Under **Identity Providers** / **SPIN**, the **Provider ARN** shown should be
   assigned to the project in SPIN.
8. Under **Roles** / **Administrator**, the **Role ARN** shown should be
   assigned to the project role in SPIN.

---

## Issuing an API Certificate

A simple tool is provided to help with issuing API certificates. As part of
installation, a CA is created for you in `/opt/spin/ca`. The tool accepts an
X.509 Certificate Signing Request, and uses it to issue a certificate with a
random CN for use with SPIN.

To run the tool, execute the following command **as the `root` user**:

```
/opt/spin/app/bin/api-ca sign
```

After pasting the CSR, the details will be printed out and confirmation
requested. Type `yes` when asked, and the certificate will be signed and printed
out.

**Note:** This command relies on the `SPIN_CA_DIR` environment variable, which
is set during installation. If you're having issues, ensure this environment
variable has been correctly set.

Once the API certificate has been issued there are 3 further steps to undertake:

1. Provide the created certificate to the user requesting access to the SPIN API
1. Within SPIN create a new API subject to represent this certificate under the Administration menu.
You'll require the value for CN for this certificate which was output on completion the signing command above.
1. Add the API account to the Global Administrator role so it can control all aspects of SPIN

Example of retrieving correct CN value to create API account within SPIN

```
$>/opt/spin/app/bin/api-ca sign
...
Do you wish to sign this request? (yes/no) yes
...
     Subject: CN=2AC8MfGxTR40WRmLw6H8ZNyjPcRqsmLNdX_DK0-c
...
```
You would enter **`2AC8MfGxTR40WRmLw6H8ZNyjPcRqsmLNdX_DK0-c`** into the UI when requested.
