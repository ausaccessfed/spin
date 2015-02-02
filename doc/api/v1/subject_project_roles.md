# Subject / ProjectRole association)

## Associate Subject with Project Roles

```
POST /api/organisations/:id/projects/:id/roles/:id/members
Content-Type: application/json
{ "subject_project_roles":  { "subject_id": "1" } }
```

### Response

```
Status: 200 OK
Response: Subject 1 granted
```

## Disassociate Subject and Project Roles

```
DELETE /api/organisations/:id/projects/:id/roles/:id/members/:subject_id
```
### Response

```
Status: 200 OK
Response: Subject 1 revoked
```
