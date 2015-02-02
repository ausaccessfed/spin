# Project Roles

## List Project Roles

List all Project Roles

```
GET /api/organisations/:id/projects/:id/roles
```

### Response

```
Status: 200 OK
```

```json
{
    "project_roles": [
        {
            "id": 1,
            "name": "Role 1",
            "role_arn": "arn:aws:iam::1:role/SADADSZ"
            "granted_subjects": [5, 3, 9]
        }
    ]
}
```

## Delete Project Role

Delete Project Role by id

```
DELETE /api/organisations/:id/projects/:id/roles/:id
```
### Response

```
Status: 200 OK
Response: ProjectRole :id deleted
```

## Create Project Role

```
POST /api/organisations/:id/projects/:id/roles
Content-Type: application/json
{ "project_role":  { "name": "Proj Role 1", "role_arn": "arn:aws:iam::1:role/5112" } }
```

### Response

```
Status: 200 OK
Response: ProjectRole <id> created
```

## Update Project Role

```
PATCH /api/organisations/:id/projects/:id/roles/:id
Content-Type: application/json
{ "project_role":  { "name": "Proj Role 2", "role_arn": "arn:aws:iam::1:role/5f2" } }
```

### Response

```
Status: 200 OK
Response: ProjectRole :id updated
```
