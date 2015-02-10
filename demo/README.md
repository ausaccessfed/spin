# Overview

This document provides an overview of the [Example SPIN API client](spin_api_client.thor).
It's strongly recommended to get an understanding of the [SPIN API](../doc/api/v1/README.md) before continuing.

This client is intended for ad-hoc testing and demonstration of the SPIN API only.

# Pre-requisites

* [Ruby](https://www.ruby-lang.org/en/downloads/) (verified with 2.1.5)
* [rest-client](https://github.com/rest-client/rest-client) (Install with ```gem install 'rest-client'```)
* [thor](https://github.com/erikhuda/thor) (Install with ```gem install 'thor'```)

# Commands

A full list of available commands can found as follows:

```
~/spin/demo $ thor list
spin_api_client
---------------
thor spin_api_client:create_organisation --external-id=EXTERNAL_ID --name=NAME                                                                             # POST /organisations
thor spin_api_client:create_project --name=NAME --organisation-id=ORGANISATION_ID --provider-arn=PROVIDER_ARN                                              # POST /organisations/<organisation_id>/projects
thor spin_api_client:create_role --name=NAME --organisation-id=ORGANISATION_ID --project-id=PROJECT_ID --role-arn=ROLE_ARN                                 # POST /organisations/<organisation_id>/projects/<project_id>/roles/
thor spin_api_client:delete_organisation --organisation-id=ORGANISATION_ID                                                                                 # DELETE /organisations/<organisation_id>
thor spin_api_client:delete_project --organisation-id=ORGANISATION_ID --project-id=PROJECT_ID                                                              # DELETE /organisations/<organisation_id>/projects/<project_id>
thor spin_api_client:delete_role --organisation-id=ORGANISATION_ID --project-id=PROJECT_ID --role-id=ROLE_ID                                               # DELETE /organisations/<organisation_id>/projects/<project_id>/roles/<role_id>
thor spin_api_client:delete_subject --subject-id=SUBJECT_ID                                                                                                # DELETE /subjects/<subject_id>
thor spin_api_client:get_organisations                                                                                                                     # GET /organisations
thor spin_api_client:get_projects --organisation-id=ORGANISATION_ID                                                                                        # GET /organisations/<organisation_id>/projects
thor spin_api_client:get_roles --organisation-id=ORGANISATION_ID --project-id=PROJECT_ID                                                                   # GET /organisations/<organisation_id>/projects/<project_id>/roles
thor spin_api_client:get_subjects                                                                                                                          # GET /subjects
thor spin_api_client:grant_project_role_to_subject --organisation-id=ORGANISATION_ID --project-id=PROJECT_ID --role-id=ROLE_ID --subject-id=SUBJECT_ID     # POST /organisations/<organisation_id>/projects/<project_id>/roles/<role_id>/members
thor spin_api_client:revoke_project_role_from_subject --organisation-id=ORGANISATION_ID --project-id=PROJECT_ID --role-id=ROLE_ID --subject-id=SUBJECT_ID  # DELETE /organisations/<organisation_id>/projects/<project_id>/roles/<role_id>/members/<subject_id>
```

# Example usage

After executing a thor command you will see the following:
 - The request method and path generated i.e. ```GET https://spin-demo.test.aaf.edu.au/api/organisations```
 - The response code i.e. ```200```
 - The response body (if present)

## Subjects
### ```get_subjects```
```
$ thor spin_api_client:get_subjects
GET https://spin-demo.test.aaf.edu.au/api/subjects
-->
200
{
  "subjects": [
    {
      "id": 1,
      "shared_token": "aqgzEjiju0OqhE4Y2WCjB-k9mu0",
      "mail": "russell.ianniello@aaf.edu.au",
      "name": "Russell Ianniello"
    }
  ]
}
```
### ```delete_subject```
```
$ thor spin_api_client:delete_subject --subject-id 1
DELETE https://spin-demo.test.aaf.edu.au/api/subjects/1
-->
200
```

## Organisations
### ```get_organisations```
```
$ thor spin_api_client:get_organisations
GET https://spin-demo.test.aaf.edu.au/api/organisations
-->
200
{
  "organisations": [
    {
      "id": 1,
      "name": "My Organisation",
      "external_id": "ExternalID1"
    },
    {
      "id": 2,
      "name": "My Second Organisation",
      "external_id": "ExternalID2"
    }
  ]
}
```

### ```create_organisation```
```
$ thor spin_api_client:create_organisation --name 'My New Organisation' --external_id 'ExternalID3'
POST https://spin-demo.test.aaf.edu.au/api/organisations
{
  "organisation": {
    "name": "My New Organisation",
    "external_id": "ExternalID3"
  }
}
-->
201
```

### ```delete_organisation```
```
$ thor spin_api_client:delete_organisation --organisation-id 3
DELETE https://spin-demo.test.aaf.edu.au/api/organisations/3
-->
200
```

## Projects
### ```get_projects```
```
$ thor spin_api_client:get_projects --organisation-id 3
GET https://spin-demo.test.aaf.edu.au/api/organisations/3/projects
-->
200
{
  "projects": [
    {
      "id": 1,
      "name": "My Project",
      "provider_arn": "arn:aws:iam::1:saml-provider/abc",
      "active": true
    }
  ]
}
```

### ```create_project```
```
$ thor spin_api_client:create_project --organisation-id 3 --name 'My Project' --provider-arn 'arn:aws:iam::1:saml-provider/abc'
POST https://spin-demo.test.aaf.edu.au/api/organisations/3/projects
{
  "project": {
    "name": "My Project",
    "provider_arn": "arn:aws:iam::1:saml-provider/abc",
    "active": "true"
  }
}
-->
201
```

### ```delete_project```
```
$ thor spin_api_client:delete_project --organisation-id 3 --project-id 1
DELETE https://spin-demo.test.aaf.edu.au/api/organisations/3/projects/1
-->
200
```

## Roles

### ```get_roles```
```
$ thor spin_api_client:get_roles --organisation-id 3 --project-id 2
GET https://spin-demo.test.aaf.edu.au/api/organisations/3/projects/2/roles
-->
200
{
  "project_roles": [
    {
      "id": 1,
      "name": "My Role",
      "role_arn": "arn:aws:iam::1:role/1",
      "granted_subjects": [

      ]
    }
  ]
}
```

### ```create_role```
```
$ thor spin_api_client:create_role --organisation-id 3 --project-id 2 --name 'My Role' --role-arn 'arn:aws:iam::1:role/1'
POST https://spin-demo.test.aaf.edu.au/api/organisations/3/projects/2/roles
{
  "project_role": {
    "name": "My Role",
    "role_arn": "arn:aws:iam::1:role/1"
  }
}
-->
201
```

### ```delete_role```
```
$ thor spin_api_client:delete_role --organisation-id 3 --project-id 2 --role-id 1
DELETE https://spin-demo.test.aaf.edu.au/api/organisations/3/projects/2/roles/1
-->
200
```

## Grant / Revoke Roles

### ```grant_project_role_to_subject```
```
$ thor spin_api_client:grant_project_role_to_subject --organisation-id 3 --project-id 2 --role-id 2 --subject-id 1
POST https://spin-demo.test.aaf.edu.au/api/organisations/3/projects/2/roles/2/members
{
  "subject_project_roles": {
    "subject_id": "1"
  }
}
-->
201
```
### ```revoke_project_role_from_subject```
```
$ thor spin_api_client:revoke_project_role_from_subject --organisation-id 3 --project-id 2 --role-id 2 --subject-id 1
DELETE https://spin-demo.test.aaf.edu.au/api/organisations/3/projects/2/roles/2/members/1
-->
200
```


