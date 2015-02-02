# Subject / ProjectRole association)

## Associate Subject with Project Roles

```
POST /api/organisations/:id/projects/:id/roles/:id/members
Content-Type: application/json
```
Request Body:
```json
{ "subject_project_roles":  { "subject_id": "<id>" } }
```

### Response

```
Status: 200 OK
Response: Subject <id> granted
```

## Disassociate Subject and Project Roles

```
DELETE /api/organisations/:id/projects/:id/roles/:id/members/:subject_id
```
### Response

```
Status: 200 OK
Response: Subject <id> revoked
```
