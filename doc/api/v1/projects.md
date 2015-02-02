# Projects

## List Projects

List all Projects

```
GET /api/organisations/:id/projects/
```

### Response

```
Status: 200 OK
```

```json
{
   "projects":[
      {
         "id":1,
         "provider_arn":"arn:aws:iam::1:saml-provider/12321"
         "state":"true",
         "name":"Project X"
      },
      {
         "id":2,
         "provider_arn":"arn:aws:iam::1:saml-provider/123115"
         "state":"true",
         "name":"Project Z"
      }
   ]
}
```

## Delete Project

Delete Project by id

```
DELETE /api/organisations/:id/projects/:id
```
### Response

```
Status: 200 OK
Response: Project <id> deleted
```

## Create Project

```
POST /api/organisations/:id/projects/
Content-Type: application/json
```
Request Body:
```json
{ "project":  { "name": "Proj 1", "provider_arn": "arn:aws:iam::1:saml-provider/5112", "state": "true" } }
```

### Response

```
Status: 200 OK
Response: Project <id> created
```

## Update Project

```
PATCH /api/organisations/:id/projects/:id
Content-Type: application/json
```
Request Body:
```json
{ "project":  { "name": "Proj 2", "provider_arn": "arn:aws:iam::1:saml-provider/4", "state": "false"  } }
```

### Response

```
Status: 200 OK
Response: Project <id> updated
```
