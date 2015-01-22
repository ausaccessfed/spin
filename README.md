# SPIN

SPIN provides a means for researchers to authenticate via the AAF to access to a project account in Amazon Web Services (AWS)

## Testing

Here is some rails/console scripts to test with ...

```ruby
o = Organisation.create!(name: "Test Org", external_id: "ID1" )
p = Project.create!(name:"Test Proj 1", provider_arn: "AWS_ACC1", state: "A", organisation_id: o.id)
s = Subject.create!(mail: "russell.ianniello@aaf.edu.au", name: "Russell Ianniello", targeted_id: "https://rapid.test.aaf.edu.au!http://localhost:8080!sVU8U1bEIkdK+FTWuGQEv9aEJ+o=", shared_token: nil)
pr = ProjectRole.create!(name:"ALL for Test Proj 1", role_arn: "TP1", project_id: p.id)
spr = SubjectProjectRole.create!(subject_id: s.id, project_role_id: pr.id)

r = Role.create!(name: 'Admin')
pm = Permission.create!(role_id:r.id, value:'*')
sr = SubjectRole.create!(subject_id:Subject.last.id, role_id:r.id)
```

## Deployment configuration

The SPIN logo is configured by overwriting the files
* app/assets/images/logo.png
* app/assets/images/favicon.png

Configure the user consent and support text
* config/support.md
* config/consent.md

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

1. Under the root account visit the Security Credentials page.
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
